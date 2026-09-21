import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_spinner.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/state/view_state.dart';
import '../controllers/customers_controller.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({
    super.key,
    this.onSelectCustomer,
  });

  final ValueChanged<String>? onSelectCustomer;

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _searchController = TextEditingController();
  String _search = '';
  String _filter = 'all'; // 'all', 'active', 'late'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersController>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomersController>();
    final allCustomers = controller.customers;

    final lateCount = allCustomers.where((c) => c.lateCount > 0).length;
    final activeCount = allCustomers.where((c) => c.activeSales > 0).length;

    // Filter
    final q = _search.toLowerCase();
    final filtered = allCustomers.where((c) {
      if (_filter == 'late' && c.lateCount <= 0) return false;
      if (_filter == 'active' && c.activeSales <= 0) return false;
      if (q.isNotEmpty) {
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesPhone = c.phone.contains(q);
        if (!matchesName && !matchesPhone) return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            '👥 المشترين',
            style: AppTextStyles.xxxlBold(AppColors.gray800),
          ),
          const SizedBox(height: 24),

          // Search and Filter Card
          AppCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                final searchField = TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _search = v.trim()),
                  style: AppTextStyles.base(AppColors.gray800),
                  decoration: InputDecoration(
                    hintText: '🔍 بحث بالاسم أو رقم الهاتف...',
                    hintStyle: AppTextStyles.base(AppColors.gray400),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: AppColors.white,
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
                );

                final filterDropdown = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppDimens.borderMd,
                    border: Border.all(color: AppColors.gray300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filter,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('الكل (${allCustomers.length})'),
                        ),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('نشط ($activeCount)'),
                        ),
                        DropdownMenuItem(
                          value: 'late',
                          child: Text('عنده متأخرات ($lateCount)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _filter = val);
                      },
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(flex: 2, child: searchField),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: filterDropdown),
                    ],
                  );
                }

                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    filterDropdown,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Loading / Content
          if (controller.state == ViewState.loading && allCustomers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: AppSpinner(size: 40)),
            )
          else if (filtered.isEmpty)
            AppCard(
              child: EmptyView(
                message: _search.isNotEmpty ? 'لا توجد نتائج' : 'لا يوجد مشترين بعد',
                inCard: false,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 1024
                    ? 3
                    : width >= 640
                        ? 2
                        : 1;

                // Simple grid using Wrap or Row/Column chunks
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 170,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final c = filtered[i];
                    final hasLate = c.lateCount > 0;

                    return InkWell(
                      onTap: () {
                        if (widget.onSelectCustomer != null) {
                          widget.onSelectCustomer!(c.id);
                        }
                      },
                      borderRadius: AppDimens.borderLg,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppDimens.borderLg,
                          border: Border.all(
                            color: hasLate ? AppColors.red300 : AppColors.gray200,
                            width: hasLate ? 2 : 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top row: Avatar + Info
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: AppColors.blue100,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('👤', style: TextStyle(fontSize: 24)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            style: AppTextStyles.lgBold(AppColors.gray800),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '📞 ${c.phone}',
                                            style: AppTextStyles.sm(AppColors.gray500),
                                            textDirection: TextDirection.ltr,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // 2 stats tiles
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.blue50,
                                          borderRadius: AppDimens.borderMd,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${c.salesCount}',
                                              style: AppTextStyles.baseBold(AppColors.blue700),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'إجمالي البيوع',
                                              style: AppTextStyles.xs(AppColors.gray600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.green50,
                                          borderRadius: AppDimens.borderMd,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${c.activeSales}',
                                              style: AppTextStyles.baseBold(AppColors.green700),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'نشط',
                                              style: AppTextStyles.xs(AppColors.gray600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Late badge at top-left (physical left)
                            if (hasLate)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: AppBadge(
                                  label: '⚠️ ${c.lateCount} متأخر',
                                  variant: AppBadgeVariant.danger,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
