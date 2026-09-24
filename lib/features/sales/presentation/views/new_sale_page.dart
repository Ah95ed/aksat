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

  List<Map<String, dynamic>> _suggestions = [];
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
    _quantityController.addListener(_onFieldChanged);
    _totalPriceController.addListener(_onFieldChanged);
    _downPaymentController.addListener(_onFieldChanged);
    _installmentsCountController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _quantityController.removeListener(_onFieldChanged);
    _totalPriceController.removeListener(_onFieldChanged);
    _downPaymentController.removeListener(_onFieldChanged);
    _installmentsCountController.removeListener(_onFieldChanged);
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
    final query = val.trim();
    if (_selectedCustomerId != null && _nameController.text != val) {
      _selectedCustomerId = null;
    }
    _searchTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    _searchTimer = Timer(const Duration(milliseconds: 250), () async {
      try {
        final apiClient = context.read<ApiClient>();
        final res = await apiClient.get(
          ApiEndpoints.customers,
          query: {'search': query},
        );
        final data = res['data'];
        if (mounted && data is List) {
          final list = data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          setState(() {
            _suggestions = list;
            _showSuggestions = list.isNotEmpty;
          });
        }
      } catch (_) {}
    });
  }

  void _selectSuggestion(Map<String, dynamic> c) {
    FocusScope.of(context).unfocus();
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

  String _normalizeNumber(String s) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var res = s.trim();
    for (int i = 0; i < arabic.length; i++) {
      res = res.replaceAll(arabic[i], english[i]);
    }
    return res.replaceAll(',', '').replaceAll(' ', '');
  }

  void _onQuantityChanged(String val) {
    final clean = _normalizeNumber(val);
    final qty = int.tryParse(clean) ?? 1;
    setState(() => _quantity = qty <= 0 ? 1 : qty);
    if (_selectedProduct != null) {
      final total = _selectedProduct!.price * _quantity;
      _totalPriceController.text = MoneyFormatter.formatAmount(total);
    }
  }

  double get _totalPrice {
    final clean = _normalizeNumber(_totalPriceController.text);
    return double.tryParse(clean) ?? 0.0;
  }

  double get _downPayment {
    final clean = _normalizeNumber(_downPaymentController.text);
    return double.tryParse(clean) ?? 0.0;
  }

  int get _installmentsCount {
    final clean = _normalizeNumber(_installmentsCountController.text);
    return int.tryParse(clean) ?? 0;
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
    if (totalCost <= 0) return '0';
    return ((_expectedProfit / totalCost) * 100).toStringAsFixed(1);
  }

  bool get _hasTotalPrice => _totalPriceController.text.trim().isNotEmpty && _totalPrice > 0;
  bool get _hasDownPayment => _downPaymentController.text.trim().isNotEmpty;
  bool get _hasRemaining => _hasTotalPrice && _remaining > 0;
  bool get _hasInstallmentsCount => _installmentsCountController.text.trim().isNotEmpty && _installmentsCount > 0;
  bool get _hasInstallmentValue => _hasRemaining && _hasInstallmentsCount && _installmentValue > 0;

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
        : MoneyFormatter.currencySymbol('LOCAL', settings);

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('اسم المشتري *', style: AppTextStyles.smBold(AppColors.gray700)),
                            if (_selectedCustomerId != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCustomerId = null;
                                    _nameController.clear();
                                    _phoneController.clear();
                                    _addressController.clear();
                                  });
                                },
                                child: Text(
                                  'تغيير المشتري ✕',
                                  style: AppTextStyles.xsBold(AppColors.blue600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                            hintText: 'ابدأ بكتابة اسم المشتري للبحث...',
                            hintStyle: AppTextStyles.base(AppColors.gray400),
                            prefixIcon: const Icon(Icons.search, color: AppColors.gray400, size: 20),
                            suffixIcon: _nameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: AppColors.gray400),
                                    onPressed: () {
                                      setState(() {
                                        _nameController.clear();
                                        _selectedCustomerId = null;
                                        _suggestions = [];
                                        _showSuggestions = false;
                                      });
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: AppDimens.borderMd,
                              borderSide: const BorderSide(color: AppColors.gray300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppDimens.borderMd,
                              borderSide: const BorderSide(color: AppColors.gray300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppDimens.borderMd,
                              borderSide: const BorderSide(color: AppColors.blue600, width: 2),
                            ),
                          ),
                        ),
                        if (_showSuggestions && _suggestions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: AppDimens.borderLg,
                              border: Border.all(color: AppColors.blue500, width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: _suggestions.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.gray200),
                              itemBuilder: (ctx, i) {
                                final s = _suggestions[i];
                                final name = s['name']?.toString() ?? '';
                                final phone = s['phone']?.toString() ?? '';
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _selectSuggestion(s),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.blue50,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.person_outline, size: 18, color: AppColors.blue600),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: AppTextStyles.baseBold(AppColors.gray800),
                                                ),
                                                Text(
                                                  'مشتري مسجل مسبقاً',
                                                  style: AppTextStyles.xs(AppColors.gray500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (phone.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.gray100,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '📞 $phone',
                                                style: AppTextStyles.smBold(AppColors.blue700),
                                                textDirection: TextDirection.ltr,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.green600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تم تحديد المشتري تلقائياً: ${_nameController.text} (${_phoneController.text})',
                                style: AppTextStyles.smBold(AppColors.green800),
                              ),
                            ),
                          ],
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
                    _buildSummaryCard(
                      sym: sym,
                      firstDate: firstDate,
                      lastDate: lastDate,
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

  Widget _buildSummaryCard({
    required String sym,
    required String firstDate,
    required String lastDate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.borderLg,
        border: Border.all(color: AppColors.blue200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.blue50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blue600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📋 ملخص العملية المالية والأقساط', style: AppTextStyles.baseBold(AppColors.blue950)),
                      const SizedBox(height: 2),
                      Text('حساب مالي فوري وشامل لعملية البيع', style: AppTextStyles.xs(AppColors.blue700)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.green300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.green600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('حساب مباشر', style: AppTextStyles.xsBold(AppColors.green800)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 4 Highlight Stat Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 550;
                    final card1 = _buildStatCard(
                      'السعر الكلي',
                      _hasTotalPrice ? '${MoneyFormatter.formatAmount(_totalPrice)} $sym' : '—',
                      AppColors.blue600,
                      AppColors.blue50,
                      Icons.sell_outlined,
                    );
                    final card2 = _buildStatCard(
                      'المقدمة المستلمة',
                      _hasDownPayment ? '${MoneyFormatter.formatAmount(_downPayment)} $sym' : '—',
                      AppColors.amber600,
                      AppColors.amber50,
                      Icons.payments_outlined,
                    );
                    final card3 = _buildStatCard(
                      'المبلغ المتبقي',
                      _hasRemaining ? '${MoneyFormatter.formatAmount(_remaining)} $sym' : '—',
                      AppColors.purple600,
                      const Color(0xFFFAF5FF),
                      Icons.account_balance_wallet_outlined,
                    );
                    final card4 = _buildStatCard(
                      'قيمة القسط الواحد',
                      _hasInstallmentValue ? '${MoneyFormatter.formatAmount(_installmentValue)} $sym' : '—',
                      AppColors.emerald600,
                      const Color(0xFFECFDF5),
                      Icons.calendar_month_outlined,
                      isHighlighted: true,
                    );

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 8),
                          Expanded(child: card2),
                          const SizedBox(width: 8),
                          Expanded(child: card3),
                          const SizedBox(width: 8),
                          Expanded(child: card4),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: card1),
                            const SizedBox(width: 8),
                            Expanded(child: card2),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: card3),
                            const SizedBox(width: 8),
                            Expanded(child: card4),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.gray200),
                const SizedBox(height: 10),

                // Table Breakdown
                _buildDetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'المادة المباعة والكمية',
                  value: _selectedProduct != null ? '${_selectedProduct!.name} (${_quantity}x)' : '—',
                ),
                _buildDetailRow(
                  icon: Icons.sell_outlined,
                  label: 'سعر المفرد للمادة',
                  value: _selectedProduct != null ? '${MoneyFormatter.formatAmount(_selectedProduct!.price)} $sym' : '—',
                ),
                _buildDetailRow(
                  icon: Icons.format_list_numbered_rtl_rounded,
                  label: 'عدد الأقساط',
                  value: _hasInstallmentsCount ? '$_installmentsCount أقساط' : '—',
                ),
                _buildDetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'طريقة ونظام السداد',
                  value: _installmentType == 'weekly' ? 'أسبوعي (كل 7 أيام)' : 'شهري (كل شهر)',
                ),
                _buildDetailRow(
                  icon: Icons.payments_rounded,
                  label: 'قيمة كل قسط',
                  value: _hasInstallmentValue ? '${MoneyFormatter.formatAmount(_installmentValue)} $sym' : '—',
                  isBold: true,
                  valueColor: AppColors.emerald700,
                ),
                _buildDetailRow(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'إجمالي مبالغ الأقساط',
                  value: _hasRemaining ? '${MoneyFormatter.formatAmount(_remaining)} $sym' : '—',
                ),
                _buildDetailRow(
                  icon: Icons.event_available_outlined,
                  label: 'تاريخ استحقاق أول قسط',
                  value: _hasInstallmentsCount ? firstDate : '—',
                ),
                _buildDetailRow(
                  icon: Icons.event_busy_outlined,
                  label: 'تاريخ استحقاق آخر قسط',
                  value: _hasInstallmentsCount ? lastDate : '—',
                ),
                _buildDetailRow(
                  icon: Icons.today_outlined,
                  label: 'تاريخ تسجيل البيع',
                  value: '${_saleDate.year}/${_saleDate.month.toString().padLeft(2, '0')}/${_saleDate.day.toString().padLeft(2, '0')}',
                ),

                // Cost & Profit Breakdown
                if (_selectedProduct != null && _selectedProduct!.costPrice > 0) ...[
                  _buildDetailRow(
                    icon: Icons.shopping_bag_outlined,
                    label: 'إجمالي التكلفة (سعر الشراء)',
                    value: '${MoneyFormatter.formatAmount(_selectedProduct!.costPrice * _quantity)} $sym',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _expectedProfit >= 0 ? AppColors.green50 : AppColors.red50,
                      borderRadius: AppDimens.borderMd,
                      border: Border.all(
                        color: _expectedProfit >= 0 ? AppColors.green300 : AppColors.red300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _expectedProfit >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          color: _expectedProfit >= 0 ? AppColors.green700 : AppColors.red700,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _expectedProfit >= 0 ? 'الربح الإجمالي المتوقع' : 'خسارة في البيع',
                                style: AppTextStyles.xs(
                                  _expectedProfit >= 0 ? AppColors.green800 : AppColors.red800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${MoneyFormatter.formatAmount(_expectedProfit)} $sym (هامش الربح: $_profitPercentage%)',
                                style: AppTextStyles.baseBold(
                                  _expectedProfit >= 0 ? AppColors.green800 : AppColors.red800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  _buildDetailRow(
                    icon: Icons.trending_up_rounded,
                    label: 'الربح المتوقع',
                    value: '—',
                    note: _selectedProduct != null ? '(لم يُحدد سعر التكلفة)' : null,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    Color bg,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppDimens.borderMd,
        border: Border.all(
          color: isHighlighted ? color : color.withValues(alpha: 0.25),
          width: isHighlighted ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.xs(AppColors.gray600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.baseBold(color).copyWith(
              fontSize: isHighlighted ? 15 : 13.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? note,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: AppColors.gray500),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.sm(AppColors.gray700),
          ),
          if (note != null) ...[
            const SizedBox(width: 4),
            Text(note, style: AppTextStyles.xs(AppColors.gray400)),
          ],
          const Spacer(),
          Text(
            value,
            style: (isBold
                ? AppTextStyles.smBold(valueColor ?? AppColors.gray900)
                : AppTextStyles.sm(valueColor ?? AppColors.gray800)),
          ),
        ],
      ),
    );
  }
}
