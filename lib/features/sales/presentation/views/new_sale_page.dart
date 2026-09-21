import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customers_repository.dart';
import '../../../inventory/data/datasources/inventory_remote_datasource.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/products_repository.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/repositories/sales_repository.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({
    super.key,
    required this.onNavigateToCustomer,
    this.onNavigateToProducts,
  });

  final ValueChanged<String> onNavigateToCustomer;
  final VoidCallback? onNavigateToProducts;

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  // Customer state
  String? _selectedCustomerId;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _searchTimer;

  // Products & Inventory
  List<Product> _products = [];
  Product? _selectedProduct;
  InventoryItem? _productInventory;
  bool _loadingProducts = true;

  // Sale fields
  int _quantity = 1;
  final _quantityController = TextEditingController(text: '1');
  final _totalPriceController = TextEditingController(text: '0');
  final _downPaymentController = TextEditingController(text: '0');
  final _installmentsCountController = TextEditingController(text: '1');
  String _installmentType = 'monthly';
  DateTime _saleDate = DateTime.now();
  final _notesController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _quantityController.dispose();
    _totalPriceController.dispose();
    _downPaymentController.dispose();
    _installmentsCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final repo = context.read<ProductsRepository>();
      final list = await repo.fetchAll();
      if (mounted) setState(() => _products = list);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  void _onNameChanged(String val) {
    _selectedCustomerId = null;
    _searchTimer?.cancel();

    if (val.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final apiClient = context.read<ApiClient>();
        final res = await apiClient.get(
          ApiEndpoints.customers,
          query: {'search': val.trim()},
        );
        final data = res['data'];
        if (mounted && data is List) {
          setState(() {
            _suggestions = data;
            _showSuggestions = true;
          });
        }
      } catch (_) {}
    });
  }

  void _selectSuggestion(Map<String, dynamic> c) {
    setState(() {
      _selectedCustomerId = c['id']?.toString();
      _nameController.text = c['name']?.toString() ?? '';
      _phoneController.text = c['phone']?.toString() ?? '';
      _addressController.text = c['address']?.toString() ?? '';
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  Future<void> _onProductSelected(Product? p) async {
    setState(() {
      _selectedProduct = p;
      _quantity = 1;
      _quantityController.text = '1';
      _productInventory = null;
    });

    if (p != null) {
      _totalPriceController.text = MoneyFormatter.formatAmount(p.price);
      try {
        final invDataSource = context.read<InventoryRemoteDataSource>();
        final inv = await invDataSource.fetchOne(p.id);
        if (mounted) setState(() => _productInventory = inv);
      } catch (_) {}
    } else {
      _totalPriceController.text = '0';
    }
  }

  void _onQuantityChanged(String val) {
    final qty = int.tryParse(val) ?? 1;
    setState(() => _quantity = qty <= 0 ? 1 : qty);
    if (_selectedProduct != null) {
      final total = _selectedProduct!.price * _quantity;
      _totalPriceController.text = MoneyFormatter.formatAmount(total);
    }
  }

  double get _totalPrice {
    final clean = _totalPriceController.text.replaceAll(',', '');
    return double.tryParse(clean) ?? 0.0;
  }

  double get _downPayment {
    final clean = _downPaymentController.text.replaceAll(',', '');
    return double.tryParse(clean) ?? 0.0;
  }

  int get _installmentsCount {
    return int.tryParse(_installmentsCountController.text) ?? 1;
  }

  double get _remaining => (_totalPrice - _downPayment).clamp(0.0, double.infinity);

  double get _installmentValue {
    if (_installmentsCount <= 0) return 0.0;
    return _remaining / _installmentsCount;
  }

  double get _expectedProfit {
    if (_selectedProduct == null || _selectedProduct!.costPrice <= 0) return 0.0;
    final totalCost = _selectedProduct!.costPrice * _quantity;
    return _totalPrice - totalCost;
  }

  String get _profitPercentage {
    if (_selectedProduct == null || _selectedProduct!.costPrice <= 0) return '0';
    final totalCost = _selectedProduct!.costPrice * _quantity;
    if (totalCost == 0) return '0';
    return ((_expectedProfit / totalCost) * 100).toStringAsFixed(1);
  }

  bool get _canSubmit {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _selectedProduct != null &&
        _totalPrice > 0 &&
        _installmentsCount > 0 &&
        _remaining > 0;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      AppDialogs.alert(context, 'الرجاء إكمال جميع البيانات المطلوبة');
      return;
    }

    // Check inventory shortage warning
    final custRepo = context.read<CustomersRepository>();
    final salesRepo = context.read<SalesRepository>();

    if (_productInventory != null && _quantity > _productInventory!.quantity) {
      final diff = _productInventory!.quantity - _quantity;
      final proceed = await AppDialogs.confirm(
        context,
        '⚠️ تحذير: الكمية المطلوبة ($_quantity) أكبر من المتوفر في المخزن (${_productInventory!.quantity}).\n\n'
        'ستصبح الكمية في المخزن: $diff\n\n'
        'هل تريد المتابعة بالبيع رغم ذلك؟',
      );
      if (!proceed || !mounted) return;
    }

    setState(() => _submitting = true);

    try {
      String customerId = _selectedCustomerId ?? '';

      // If customer doesn't exist, create customer
      if (customerId.isEmpty) {
        final newCust = await custRepo.create(
          Customer(
            id: '',
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          ),
        );
        customerId = newCust.id;
      }

      final saleDateStr =
          '${_saleDate.year}-${_saleDate.month.toString().padLeft(2, '0')}-${_saleDate.day.toString().padLeft(2, '0')}';

      final saleRes = await salesRepo.create({
        'customer_id': customerId,
        'product_id': int.tryParse(_selectedProduct!.id) ?? _selectedProduct!.id,
        'product_name': _selectedProduct!.name,
        'quantity': _quantity,
        'total_price': _totalPrice,
        'down_payment': _downPayment,
        'installments_count': _installmentsCount,
        'installment_type': _installmentType,
        'currency': _selectedProduct!.currency,
        'sale_date': saleDateStr,
        'notes': _notesController.text.trim(),
      });

      String msg = '✅ تم تسجيل البيع بنجاح!';
      final stockWarning = saleRes['data']?['stock_warning'];
      if (stockWarning != null && stockWarning.toString().isNotEmpty) {
        msg += '\n$stockWarning';
      }

      if (mounted) {
        await AppDialogs.alert(context, msg);
        widget.onNavigateToCustomer(customerId);
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.alert(context, 'فشل: $e');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _resetForm() async {
    final confirmed = await AppDialogs.confirm(context, 'هل تريد مسح كل البيانات؟');
    if (!confirmed || !mounted) return;

    setState(() {
      _selectedCustomerId = null;
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _selectedProduct = null;
      _productInventory = null;
      _quantity = 1;
      _quantityController.text = '1';
      _totalPriceController.text = '0';
      _downPaymentController.text = '0';
      _installmentsCountController.text = '1';
      _installmentType = 'monthly';
      _saleDate = DateTime.now();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = context.watch<SettingsController>();
    final settings = settingsCtrl.settings;

    final sym = _selectedProduct != null
        ? (_selectedProduct!.currency == 'USD'
            ? '\$'
            : MoneyFormatter.currencySymbol('LOCAL', settings))
        : '';

    final firstDate = DateFormatter.previewFirstInstallmentDate(_saleDate, _installmentType);
    final lastDate = DateFormatter.previewLastInstallmentDate(_saleDate, _installmentType, _installmentsCount);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                '➕ إضافة عملية بيع جديدة',
                style: AppTextStyles.xxxlBold(AppColors.gray800),
              ),
              const SizedBox(height: 24),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Customer info
                    Text(
                      '👤 معلومات المشتري',
                      style: AppTextStyles.xlBold(AppColors.blue700),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.gray200),
                    const SizedBox(height: 16),

                    // Customer Name with search suggestions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اسم المشتري *', style: AppTextStyles.smBold(AppColors.gray700)),
                        const SizedBox(height: 6),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            TextField(
                              controller: _nameController,
                              onChanged: _onNameChanged,
                              onTap: () {
                                if (_suggestions.isNotEmpty) {
                                  setState(() => _showSuggestions = true);
                                }
                              },
                              style: AppTextStyles.base(AppColors.gray800),
                              decoration: InputDecoration(
                                hintText: 'ابدأ بكتابة الاسم...',
                                hintStyle: AppTextStyles.base(AppColors.gray400),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: AppDimens.borderMd),
                              ),
                            ),
                            if (_showSuggestions && _suggestions.isNotEmpty)
                              Positioned(
                                top: 52,
                                left: 0,
                                right: 0,
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: AppDimens.borderLg,
                                    border: Border.all(color: AppColors.gray300),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _suggestions.length,
                                    itemBuilder: (ctx, i) {
                                      final s = _suggestions[i] as Map<String, dynamic>;
                                      return InkWell(
                                        onTap: () => _selectSuggestion(s),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(s['name']?.toString() ?? '', style: AppTextStyles.baseMedium(AppColors.gray800)),
                                              Text('📞 ${s['phone'] ?? ''}', style: AppTextStyles.sm(AppColors.gray500), textDirection: TextDirection.ltr),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    AppTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف *',
                      hint: '07X XXX XXXX',
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 16),

                    // Address
                    AppTextField(
                      controller: _addressController,
                      label: 'العنوان',
                      hint: 'اختياري',
                    ),

                    if (_selectedCustomerId != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: AppDimens.borderMd,
                          border: Border.all(color: AppColors.green200),
                        ),
                        child: Text(
                          '✅ مشتري موجود مسبقاً - سيتم استخدام بياناته',
                          style: AppTextStyles.smBold(AppColors.green800),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Section 2: Sale Info
                    Text(
                      '🛒 معلومات البيع',
                      style: AppTextStyles.xlBold(AppColors.blue700),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.gray200),
                    const SizedBox(height: 16),

                    // Product select
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اختر المادة *', style: AppTextStyles.smBold(AppColors.gray700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppDimens.borderMd,
                            border: Border.all(color: AppColors.gray300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Product?>(
                              value: _selectedProduct,
                              isExpanded: true,
                              hint: const Text('-- اختر مادة --'),
                              items: [
                                const DropdownMenuItem<Product?>(
                                  value: null,
                                  child: Text('-- اختر مادة --'),
                                ),
                                ..._products.map((p) {
                                  final pSym = p.currency == 'USD'
                                      ? '\$'
                                      : MoneyFormatter.currencySymbol('LOCAL', settings);
                                  return DropdownMenuItem<Product?>(
                                    value: p,
                                    child: Text('${p.name} - ${MoneyFormatter.formatAmount(p.price)} $pSym'),
                                  );
                                }),
                              ],
                              onChanged: _onProductSelected,
                            ),
                          ),
                        ),
                        if (_products.isEmpty && !_loadingProducts) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('⚠️ لا توجد مواد. ', style: AppTextStyles.sm(AppColors.amber700)),
                              if (widget.onNavigateToProducts != null)
                                InkWell(
                                  onTap: widget.onNavigateToProducts,
                                  child: Text(
                                    'أضف مادة أولاً',
                                    style: AppTextStyles.smBold(AppColors.blue600).copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    if (_selectedProduct != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.blue50,
                          borderRadius: AppDimens.borderLg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Inventory status box
                            if (_productInventory != null) ...[
                              _buildInventoryStatusBox(_productInventory!),
                              const SizedBox(height: 16),
                            ],

                            // Quantity & Total price
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth >= 500;
                                final qtyField = AppTextField(
                                  controller: _quantityController,
                                  label: 'الكمية *',
                                  keyboardType: TextInputType.number,
                                  onChanged: _onQuantityChanged,
                                );

                                final priceField = AppTextField(
                                  controller: _totalPriceController,
                                  label: 'السعر الكلي ($sym) *',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                );

                                if (isWide) {
                                  return Row(
                                    children: [
                                      Expanded(child: qtyField),
                                      const SizedBox(width: 16),
                                      Expanded(child: priceField),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    qtyField,
                                    const SizedBox(height: 12),
                                    priceField,
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Down payment
                    AppTextField(
                      controller: _downPaymentController,
                      label: 'المقدمة ($sym)',
                      hint: '0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Installments count & type
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 500;
                        final countField = AppTextField(
                          controller: _installmentsCountController,
                          label: 'عدد الأقساط *',
                          hint: '1',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        );

                        final typeField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('نوع الأقساط *', style: AppTextStyles.smBold(AppColors.gray700)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: AppDimens.borderMd,
                                border: Border.all(color: AppColors.gray300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _installmentType,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'monthly', child: Text('شهري')),
                                    DropdownMenuItem(value: 'weekly', child: Text('أسبوعي')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _installmentType = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        );

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: countField),
                              const SizedBox(width: 16),
                              Expanded(child: typeField),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            countField,
                            const SizedBox(height: 12),
                            typeField,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sale date picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تاريخ البيع *', style: AppTextStyles.smBold(AppColors.gray700)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _saleDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) setState(() => _saleDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: AppDimens.borderMd,
                              border: Border.all(color: AppColors.gray300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_saleDate.year}-${_saleDate.month.toString().padLeft(2, '0')}-${_saleDate.day.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.base(AppColors.gray800),
                                ),
                                const Text('📅'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    AppTextField(
                      controller: _notesController,
                      label: 'ملاحظات',
                      hint: 'اختياري...',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // Section 3: Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppDimens.borderLg,
                        border: Border.all(color: AppColors.blue200, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('📋 ملخص العملية', style: AppTextStyles.lgBold(AppColors.blue800)),
                          const SizedBox(height: 12),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 500;
                              final s1 = _summaryItem('قيمة القسط الواحد', '${MoneyFormatter.formatAmount(_installmentValue)} $sym');
                              final s2 = _summaryItem('المبلغ المتبقي تقسيطه', '${MoneyFormatter.formatAmount(_remaining)} $sym');
                              final s3 = _summaryItem('تاريخ أول قسط', firstDate);
                              final s4 = _summaryItem('تاريخ آخر قسط', lastDate);

                              if (isWide) {
                                return Column(
                                  children: [
                                    Row(children: [Expanded(child: s1), const SizedBox(width: 8), Expanded(child: s2)]),
                                    const SizedBox(height: 8),
                                    Row(children: [Expanded(child: s3), const SizedBox(width: 8), Expanded(child: s4)]),
                                  ],
                                );
                              }
                              return Column(children: [s1, const SizedBox(height: 8), s2, const SizedBox(height: 8), s3, const SizedBox(height: 8), s4]);
                            },
                          ),

                          if (_selectedProduct != null && _selectedProduct!.costPrice > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.green50,
                                borderRadius: AppDimens.borderMd,
                                border: Border.all(color: AppColors.green200),
                              ),
                              child: Text(
                                '💰 الربح المتوقع من هذه البيعة: ${MoneyFormatter.formatAmount(_expectedProfit)} $sym (نسبة الربح: $_profitPercentage%)',
                                style: AppTextStyles.smBold(AppColors.green800),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 4: Action Buttons
                    AppButton(
                      text: _submitting ? 'جاري التسجيل...' : '✅ تسجيل عملية البيع',
                      variant: AppButtonVariant.success,
                      size: AppButtonSize.large,
                      isLoading: _submitting,
                      onPressed: _canSubmit && !_submitting ? _submit : null,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'مسح البيانات',
                      variant: AppButtonVariant.secondary,
                      onPressed: _resetForm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryStatusBox(InventoryItem inv) {
    final qty = inv.quantity;
    final threshold = inv.lowStockThreshold;

    Color bg;
    Color border;
    Color textCol;
    String icon;
    String status;

    if (qty <= 0) {
      bg = AppColors.red100;
      border = AppColors.red400;
      textCol = AppColors.red800;
      icon = '🚫';
      status = '🚫 نفدت الكمية من المخزن (يمكن البيع لكنها ستصبح بالسالب)';
    } else if (qty <= threshold) {
      bg = AppColors.amber100;
      border = AppColors.amber400;
      textCol = AppColors.amber800;
      icon = '⚠️';
      status = '⚠️ المخزون منخفض';
    } else {
      bg = AppColors.green100;
      border = AppColors.green400;
      textCol = AppColors.green800;
      icon = '✅';
      status = '✅ المخزون متوفر';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimens.borderMd,
        border: Border.all(color: border, width: 2),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: AppTextStyles.smBold(textCol)),
                const SizedBox(height: 2),
                Text(
                  'الكمية المتوفرة في المخزن: $qty',
                  style: AppTextStyles.xs(textCol),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.borderMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.xs(AppColors.gray600)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.baseBold(AppColors.gray800)),
        ],
      ),
    );
  }
}
