import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
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
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/state/view_state.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_movement.dart';
import '../controllers/inventory_controller.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _searchController = TextEditingController();
  String _search = '';
  String _filter = 'all'; // all, tracked, low_stock, out_of_stock, not_tracked

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryController>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStockModal(InventoryItem item) {
    final isTracked = item.stockStatus != 'not_tracked';
    String action = isTracked ? 'add' : 'set';
    final qtyCtrl = TextEditingController(text: isTracked ? '' : '0');
    final thresholdCtrl = TextEditingController(
      text: isTracked ? item.lowStockThreshold.toString() : '3',
    );
    final notesCtrl = TextEditingController();
    bool isSaving = false;

    AppModal.show(
      context: context,
      maxWidth: AppModalMaxWidth.md,
      child: StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isTracked ? '📦 تحديث المخزن' : '📦 تفعيل المخزن',
                style: AppTextStyles.xxlBold(AppColors.gray800),
              ),
              const SizedBox(height: 4),
              Text(
                item.productName,
                style: AppTextStyles.base(AppColors.gray600),
              ),
              const SizedBox(height: 16),

              if (isTracked) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: AppDimens.borderLg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الكمية الحالية:', style: AppTextStyles.baseMedium(AppColors.blue700)),
                      Text(
                        '${item.quantity}',
                        style: AppTextStyles.xlBold(AppColors.blue700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Operation type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نوع العملية', style: AppTextStyles.smSemibold(AppColors.gray700)),
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
                        value: action,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'set',
                            child: Text(
                              isTracked
                                  ? 'تعيين الكمية (استبدال بـ)'
                                  : 'تعيين الكمية (البدء بـ)',
                            ),
                          ),
                          const DropdownMenuItem(
                            value: 'add',
                            child: Text('إضافة للكمية الحالية'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => action = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantity field
              AppTextField(
                label: action == 'add' ? 'الكمية المراد إضافتها *' : 'الكمية الجديدة *',
                controller: qtyCtrl,
                hintText: 'مثال: 10',
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Threshold field
              AppTextField(
                label: 'حد التنبيه (عند الوصول لهذا الرقم)',
                controller: thresholdCtrl,
                hintText: 'مثال: 3',
                helperText: 'سيظهر تنبيه عندما تصل الكمية لهذا الحد أو أقل',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                label: 'ملاحظات',
                controller: notesCtrl,
                hintText: 'اختياري',
                maxLines: 2,
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
                              final q = int.tryParse(qtyCtrl.text.trim());
                              final t = int.tryParse(thresholdCtrl.text.trim()) ?? 3;

                              if (q == null || q < 0) {
                                AppDialogs.alert(context, 'الكمية يجب أن تكون 0 أو أكثر');
                                return;
                              }

                              setModalState(() => isSaving = true);
                              final ctrl = context.read<InventoryController>();
                              final ok = await ctrl.save(
                                productId: item.productId,
                                quantity: q,
                                action: action,
                                lowStockThreshold: t,
                                notes: notesCtrl.text.trim(),
                              );

                              if (modalCtx.mounted) {
                                setModalState(() => isSaving = false);
                              }

                              if (ok) {
                                if (modalCtx.mounted) Navigator.of(modalCtx).pop();
                              } else if (mounted) {
                                AppDialogs.alert(context, 'فشل: ${ctrl.errorMessage ?? 'حدث خطأ'}');
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

  void _viewMovements(InventoryItem item) async {
    final ctrl = context.read<InventoryController>();
    List<InventoryMovement>? movements;
    bool loading = true;

    AppModal.show(
      context: context,
      maxWidth: AppModalMaxWidth.xl2,
      child: StatefulBuilder(
        builder: (modalCtx, setModalState) {
          if (loading) {
            ctrl.movements(item.productId).then((list) {
              if (modalCtx.mounted) {
                setModalState(() {
                  movements = list;
                  loading = false;
                });
              }
            }).catchError((_) {
              if (modalCtx.mounted) {
                setModalState(() {
                  loading = false;
                  movements = [];
                });
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '📋 حركات المخزن',
                style: AppTextStyles.xxlBold(AppColors.gray800),
              ),
              const SizedBox(height: 4),
              Text(
                item.productName,
                style: AppTextStyles.base(AppColors.gray600),
              ),
              const SizedBox(height: 16),

              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: AppSpinner(size: 32)),
                )
              else if (movements == null || movements!.isEmpty)
                const EmptyView(message: 'لا توجد حركات بعد', inCard: false, compact: true)
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: movements!.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final m = movements![i];
                      String typeEmoji = '📝';
                      String typeLabel = 'حركة';
                      Color typeBg = AppColors.gray50;

                      switch (m.type) {
                        case 'add':
                          typeEmoji = '➕';
                          typeLabel = 'إضافة';
                          typeBg = AppColors.green50;
                          break;
                        case 'subtract':
                          typeEmoji = '➖';
                          typeLabel = 'بيع/خصم';
                          typeBg = AppColors.red50;
                          break;
                        case 'return':
                          typeEmoji = '↩️';
                          typeLabel = 'استرجاع (حذف بيع)';
                          typeBg = AppColors.blue50;
                          break;
                        case 'adjustment':
                          typeEmoji = '✏️';
                          typeLabel = 'تعديل';
                          typeBg = AppColors.amber50;
                          break;
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: typeBg,
                          borderRadius: AppDimens.borderLg,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$typeEmoji $typeLabel ${m.quantity}',
                                  style: AppTextStyles.baseBold(AppColors.gray800),
                                ),
                                if (m.notes != null && m.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    m.notes!,
                                    style: AppTextStyles.xs(AppColors.gray600),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              DateFormatter.formatDateShort(m.createdAt),
                              style: AppTextStyles.xs(AppColors.gray500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),
              AppButton(
                text: 'إغلاق',
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => Navigator.of(modalCtx).pop(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _stopTracking(InventoryItem item) async {
    final confirmed = await AppDialogs.confirm(
      context,
      'إيقاف تتبع المخزن لـ "${item.productName}"؟\n\nسيتم حذف بيانات الكمية والحركات.',
    );
    if (!confirmed || !mounted) return;

    final ctrl = context.read<InventoryController>();
    final ok = await ctrl.disable(item.productId);
    if (!ok && mounted) {
      AppDialogs.alert(context, 'فشل: ${ctrl.errorMessage ?? 'حدث خطأ'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();
    final settingsCtrl = context.watch<SettingsController>();
    final settings = settingsCtrl.settings;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppDimens.breakpointMd;

    final allItems = controller.items;
    final trackedCount = allItems.where((i) => i.stockStatus != 'not_tracked').length;
    final lowStockCount = allItems.where((i) => i.stockStatus == 'low_stock').length;
    final outOfStockCount = allItems.where((i) => i.stockStatus == 'out_of_stock').length;
    final notTrackedCount = allItems.where((i) => i.stockStatus == 'not_tracked').length;

    final q = _search.toLowerCase();
    final filtered = allItems.where((item) {
      if (_filter == 'tracked' && item.stockStatus == 'not_tracked') return false;
      if (_filter == 'low_stock' && item.stockStatus != 'low_stock') return false;
      if (_filter == 'out_of_stock' && item.stockStatus != 'out_of_stock') return false;
      if (_filter == 'not_tracked' && item.stockStatus != 'not_tracked') return false;

      if (q.isNotEmpty) {
        return item.productName.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header & Filter Pills
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📦 المخزن', style: AppTextStyles.xxxlBold(AppColors.gray800)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterPill(
                    label: 'الكل (${allItems.length})',
                    isSelected: _filter == 'all',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  FilterPill(
                    label: '📊 مُتتبَّع ($trackedCount)',
                    isSelected: _filter == 'tracked',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'tracked'),
                  ),
                  FilterPill(
                    label: '⚠️ منخفض ($lowStockCount)',
                    isSelected: _filter == 'low_stock',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'low_stock'),
                  ),
                  FilterPill(
                    label: '🚫 نفد ($outOfStockCount)',
                    isSelected: _filter == 'out_of_stock',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'out_of_stock'),
                  ),
                  FilterPill(
                    label: '⏸️ غير مُتتبَّع ($notTrackedCount)',
                    isSelected: _filter == 'not_tracked',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'not_tracked'),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📦 المخزن', style: AppTextStyles.xxxlBold(AppColors.gray800)),
              Wrap(
                spacing: 8,
                children: [
                  FilterPill(
                    label: 'الكل (${allItems.length})',
                    isSelected: _filter == 'all',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  FilterPill(
                    label: '📊 مُتتبَّع ($trackedCount)',
                    isSelected: _filter == 'tracked',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'tracked'),
                  ),
                  FilterPill(
                    label: '⚠️ منخفض ($lowStockCount)',
                    isSelected: _filter == 'low_stock',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'low_stock'),
                  ),
                  FilterPill(
                    label: '🚫 نفد ($outOfStockCount)',
                    isSelected: _filter == 'out_of_stock',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'out_of_stock'),
                  ),
                  FilterPill(
                    label: '⏸️ غير مُتتبَّع ($notTrackedCount)',
                    isSelected: _filter == 'not_tracked',
                    size: FilterPillSize.medium,
                    onTap: () => setState(() => _filter = 'not_tracked'),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 24),

        // Info Banner
        InfoBanner(
          backgroundColor: AppColors.blue50,
          borderColor: AppColors.blue400,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المخزن اختياري:', style: AppTextStyles.smBold(AppColors.gray700)),
                    const SizedBox(height: 4),
                    Text(
                      'المواد التي تُفعّل تتبع المخزن لها سيتم خصم الكمية تلقائياً عند البيع.',
                      style: AppTextStyles.sm(AppColors.gray700),
                    ),
                    Text(
                      'المواد غير المُتتبَّعة تُباع بدون أي تأثير على المخزن.',
                      style: AppTextStyles.sm(AppColors.gray700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

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

        // Table Card
        AppCard(
          padding: EdgeInsets.zero,
          child: controller.state.isLoading && allItems.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: AppSpinner(size: 32)),
                )
              : filtered.isEmpty
                  ? const EmptyView(message: 'لا توجد نتائج', inCard: false)
                  : AppTable(
                      minWidth: 700,
                      columns: const [
                        AppTableColumn(title: '#', width: 48),
                        AppTableColumn(title: 'المادة'),
                        AppTableColumn(title: 'السعر'),
                        AppTableColumn(title: 'الكمية'),
                        AppTableColumn(title: 'حد التنبيه'),
                        AppTableColumn(title: 'الحالة'),
                        AppTableColumn(title: 'الإجراءات', width: 110),
                      ],
                      rows: List.generate(filtered.length, (i) {
                        final item = filtered[i];
                        final isNotTracked = item.stockStatus == 'not_tracked';
                        final isOutOfStock = item.stockStatus == 'out_of_stock';
                        final isLowStock = item.stockStatus == 'low_stock';

                        Color? rowBg;
                        if (isOutOfStock) rowBg = AppColors.red50;
                        if (isLowStock) rowBg = AppColors.amber50;

                        Color qtyColor = AppColors.green700;
                        if (item.quantity <= 0) {
                          qtyColor = AppColors.red700;
                        } else if (item.quantity <= item.lowStockThreshold) {
                          qtyColor = AppColors.amber700;
                        }

                        final statusInfo = AppColors.getStockStatus(item.stockStatus);

                        return AppTableRow(
                          backgroundColor: rowBg,
                          cells: [
                            AppTableCell(
                              child: Text('${i + 1}', style: AppTextStyles.sm(AppColors.gray600)),
                              width: 48,
                            ),
                            AppTableCell(
                              child: Text(
                                item.productName,
                                style: AppTextStyles.baseMedium(AppColors.gray800),
                              ),
                            ),
                            AppTableCell(
                              child: Text(
                                '${MoneyFormatter.formatAmount(item.price)} ${item.currency == 'USD' ? '\$' : MoneyFormatter.currencySymbol('LOCAL', settings.currencySymbol)}',
                                style: AppTextStyles.base(AppColors.green700),
                              ),
                            ),
                            AppTableCell(
                              child: isNotTracked
                                  ? Text(
                                      'غير مُتتبَّع',
                                      style: AppTextStyles.sm(AppColors.gray400).copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  : Text(
                                      '${item.quantity}',
                                      style: AppTextStyles.lgBold(qtyColor),
                                    ),
                            ),
                            AppTableCell(
                              child: Text(
                                isNotTracked ? '-' : '${item.lowStockThreshold}',
                                style: AppTextStyles.base(AppColors.gray600),
                              ),
                            ),
                            AppTableCell(
                              child: AppBadge(
                                text: statusInfo.fullText,
                                customBg: statusInfo.badgeBg,
                                customFg: statusInfo.badgeText,
                              ),
                            ),
                            AppTableCell(
                              width: 110,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ➕ button
                                  _tableActionButton(
                                    label: '➕',
                                    bg: AppColors.green600,
                                    onTap: () => _openStockModal(item),
                                  ),
                                  if (!isNotTracked) ...[
                                    const SizedBox(width: 4),
                                    // 📋 button
                                    _tableActionButton(
                                      label: '📋',
                                      bg: AppColors.blue500,
                                      onTap: () => _viewMovements(item),
                                    ),
                                    const SizedBox(width: 4),
                                    // ⏹️ button
                                    _tableActionButton(
                                      label: '⏹️',
                                      bg: AppColors.red500,
                                      onTap: () => _stopTracking(item),
                                    ),
                                  ],
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

  Widget _tableActionButton({
    required String label,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: AppDimens.borderSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimens.borderSm,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
