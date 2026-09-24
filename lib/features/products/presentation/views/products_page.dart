import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/app_spinner.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/state/view_state.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/product.dart';
import '../controllers/products_controller.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({
    super.key,
    this.onNavigateToInventory,
  });

  final VoidCallback? onNavigateToInventory;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsController>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddModal() {
    _showProductModal(null);
  }

  void _openEditModal(Product product) {
    _showProductModal(product);
  }

  void _showProductModal(Product? editing) {
    final settingsCtrl = context.read<SettingsController>();
    final localName = settingsCtrl.settings.currencyName.isNotEmpty
        ? settingsCtrl.settings.currencyName
        : 'دينار';

    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final costCtrl = TextEditingController(
      text: editing != null && editing.costPrice > 0
          ? editing.costPrice.toString()
          : '',
    );
    final priceCtrl = TextEditingController(
      text: editing != null && editing.price > 0
          ? editing.price.toString()
          : '',
    );
    final notesCtrl = TextEditingController(text: editing?.notes ?? '');
    String selectedCurrency = editing?.currency ?? 'LOCAL';
    bool isSaving = false;

    AppModal.show(
      context: context,
      maxWidth: AppModalMaxWidth.md,
      child: StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final p = double.tryParse(priceCtrl.text) ?? 0.0;
          final c = double.tryParse(costCtrl.text) ?? 0.0;
          final showProfit = c > 0 && p > 0;
          final profit = p - c;
          final pct = c > 0 ? ((profit / c) * 100).toStringAsFixed(1) : '0';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                editing != null ? '✏️ تعديل المادة' : '➕ إضافة مادة جديدة',
                style: AppTextStyles.xxlBold(AppColors.gray800),
              ),
              const SizedBox(height: 24),

              // Product name *
              AppTextField(
                label: 'اسم المادة *',
                controller: nameCtrl,
                hintText: 'مثال: ثلاجة LG',
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Cost and Sale price (2 cols)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'سعر الشراء',
                      controller: costCtrl,
                      hintText: 'السعر الذي اشتريت به',
                      helperText: 'للتقارير والأرباح فقط',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setModalState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: 'سعر البيع *',
                      controller: priceCtrl,
                      hintText: 'السعر الذي تبيع به',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setModalState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Expected profit preview
              if (showProfit) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: AppDimens.borderLg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الربح المتوقع:', style: AppTextStyles.sm(AppColors.gray700)),
                      Text(
                        '${MoneyFormatter.formatAmount(profit)} ($pct%)',
                        style: AppTextStyles.smBold(AppColors.green700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Currency *
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('العملة *', style: AppTextStyles.smSemibold(AppColors.gray700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppDimens.borderLg,
                      border: Border.all(color: AppColors.gray300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(value: 'USD', child: Text('دولار \$')),
                          DropdownMenuItem(value: 'LOCAL', child: Text(localName)),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedCurrency = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'ملاحظات',
                controller: notesCtrl,
                hintText: 'ملاحظات اختيارية',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: isSaving ? '⏳ جاري الحفظ...' : '💾 حفظ',
                      isLoading: isSaving,
                      onPressed: isSaving
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              final price = double.tryParse(priceCtrl.text);
                              final cost = double.tryParse(costCtrl.text) ?? 0.0;

                              if (name.isEmpty || price == null || price <= 0) {
                                AppDialogs.alert(context, 'الرجاء إدخال الاسم والسعر');
                                return;
                              }

                              setModalState(() => isSaving = true);
                              final productToSave = Product(
                                id: editing?.id ?? '',
                                name: name,
                                costPrice: cost,
                                price: price,
                                currency: selectedCurrency,
                                notes: notesCtrl.text.trim(),
                              );

                              final ctrl = context.read<ProductsController>();
                              final success = await ctrl.save(productToSave);

                              if (modalCtx.mounted) {
                                setModalState(() => isSaving = false);
                              }

                              if (success) {
                                if (modalCtx.mounted) Navigator.of(modalCtx).pop();
                                await ctrl.load();
                                if (mounted) {
                                  AppDialogs.alert(
                                    context,
                                    editing != null
                                        ? '✅ تم تعديل المادة بنجاح'
                                        : '✅ تم حفظ المادة بنجاح',
                                  );
                                }
                              } else if (mounted) {
                                AppDialogs.alert(
                                  context,
                                  'فشل الحفظ: ${ctrl.errorMessage ?? 'حدث خطأ غير معروف'}',
                                );
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'إلغاء',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.of(modalCtx).pop(),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await AppDialogs.confirm(
      context,
      'هل تريد حذف "${product.name}"؟',
    );
    if (!confirmed || !mounted) return;

    final ctrl = context.read<ProductsController>();
    final success = await ctrl.remove(product.id);
    if (!success && mounted) {
      AppDialogs.alert(context, ctrl.errorMessage ?? 'فشل الحذف');
    } else if (mounted) {
      AppDialogs.alert(context, '✅ تم حذف المادة بنجاح');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductsController>();
    final settingsCtrl = context.watch<SettingsController>();
    final settings = settingsCtrl.settings;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppDimens.breakpointMd;

    final q = _search.toLowerCase();
    final filtered = controller.products.where((p) {
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.notes != null && p.notes!.toLowerCase().contains(q));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📦 إدارة المواد', style: AppTextStyles.xxxlBold(AppColors.gray800)),
              const SizedBox(height: 16),
              Row(
                children: [
                  AppButton(
                    text: '🏪 المخزن',
                    variant: AppButtonVariant.secondary,
                    onPressed: widget.onNavigateToInventory,
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: '➕ إضافة مادة جديدة',
                    variant: AppButtonVariant.primary,
                    onPressed: _openAddModal,
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📦 إدارة المواد', style: AppTextStyles.xxxlBold(AppColors.gray800)),
              Row(
                children: [
                  AppButton(
                    text: '🏪 المخزن',
                    variant: AppButtonVariant.secondary,
                    onPressed: widget.onNavigateToInventory,
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: '➕ إضافة مادة جديدة',
                    variant: AppButtonVariant.primary,
                    onPressed: _openAddModal,
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 24),

        // Search Card
        AppCard(
          padding: const EdgeInsets.all(AppDimens.p4),
          child: AppTextField(
            controller: _searchController,
            hintText: '🔍 بحث في المواد...',
            onChanged: (val) => setState(() => _search = val),
          ),
        ),
        const SizedBox(height: 16),

        // Products Table Card
        AppCard(
          padding: EdgeInsets.zero,
          child: controller.state.isLoading && controller.products.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: AppSpinner(size: 32)),
                )
              : filtered.isEmpty
                  ? const EmptyView(
                      message: 'لا توجد مواد. ابدأ بإضافة مادة جديدة.',
                      inCard: false,
                    )
                  : AppTable(
                      minWidth: 720,
                      columns: const [
                        AppTableColumn(title: '#', width: 48),
                        AppTableColumn(title: 'اسم المادة'),
                        AppTableColumn(title: 'سعر الشراء', hideOnMobile: true),
                        AppTableColumn(title: 'سعر البيع'),
                        AppTableColumn(title: 'الربح', hideOnMobile: true),
                        AppTableColumn(title: 'العملة'),
                        AppTableColumn(title: 'ملاحظات', hideOnMobile: true),
                        AppTableColumn(title: 'الإجراءات', width: 90),
                      ],
                      rows: List.generate(filtered.length, (i) {
                        final p = filtered[i];
                        final cost = p.costPrice;
                        final price = p.price;
                        final profit = price - cost;

                        Color profitColor = AppColors.gray400;
                        String profitStr = '-';
                        if (cost > 0) {
                          profitStr = MoneyFormatter.formatAmount(profit);
                          if (profit > 0) {
                            profitColor = AppColors.green700;
                          } else if (profit < 0) {
                            profitColor = AppColors.red700;
                          } else {
                            profitColor = AppColors.gray700;
                          }
                        }

                        final isUsd = p.currency == 'USD';
                        final currencyBadgeText = isUsd
                            ? '\$ دولار'
                            : '${MoneyFormatter.currencySymbol('LOCAL', settings.currencySymbol)} ${MoneyFormatter.currencyName('LOCAL', settings.currencyName)}';

                        return AppTableRow(
                          cells: [
                            AppTableCell(
                              child: Text('${i + 1}', style: AppTextStyles.sm(AppColors.gray600)),
                              width: 48,
                            ),
                            AppTableCell(
                              child: Text(p.name, style: AppTextStyles.baseMedium(AppColors.gray800)),
                            ),
                            AppTableCell(
                              child: Text(
                                cost > 0 ? MoneyFormatter.formatAmount(cost) : '-',
                                style: AppTextStyles.baseMedium(AppColors.amber700),
                              ),
                              hideOnMobile: true,
                            ),
                            AppTableCell(
                              child: Text(
                                MoneyFormatter.formatAmount(price),
                                style: AppTextStyles.baseBold(AppColors.green700),
                              ),
                            ),
                            AppTableCell(
                              child: Text(
                                profitStr,
                                style: AppTextStyles.baseBold(profitColor),
                              ),
                              hideOnMobile: true,
                            ),
                            AppTableCell(
                              child: AppBadge(
                                text: currencyBadgeText,
                                variant: isUsd ? AppBadgeVariant.info : AppBadgeVariant.warning,
                              ),
                            ),
                            AppTableCell(
                              child: Text(
                                p.notes != null && p.notes!.isNotEmpty ? p.notes! : '-',
                                style: AppTextStyles.sm(AppColors.gray600),
                              ),
                              hideOnMobile: true,
                            ),
                            AppTableCell(
                              width: 90,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _openEditModal(p),
                                    child: const Text('✏️', style: TextStyle(fontSize: 18)),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _deleteProduct(p),
                                    child: const Text('🗑️', style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
        ),
      ],
    );
  }
}
