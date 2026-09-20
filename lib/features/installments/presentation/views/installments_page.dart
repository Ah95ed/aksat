import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/view_state.dart';
import '../../domain/entities/installment.dart';
import '../controllers/installments_controller.dart';

class InstallmentsPage extends StatefulWidget {
  const InstallmentsPage({super.key});

  @override
  State<InstallmentsPage> createState() => _InstallmentsPageState();
}

class _InstallmentsPageState extends State<InstallmentsPage> {
  static const _filters = {
    'all': 'الكل',
    'late': 'متأخرة',
    'upcoming_week': 'هذا الأسبوع',
    'upcoming_month': 'هذا الشهر',
    'paid': 'مدفوعة',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<InstallmentsController>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InstallmentsController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الأقساط')),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: _filters.entries
                    .map(
                      (entry) => Padding(
                        padding: EdgeInsetsDirectional.only(end: 6.w),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: controller.filter == entry.key,
                          onSelected: (_) => controller.load(entry.key),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(child: _InstallmentList(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _InstallmentList extends StatelessWidget {
  const _InstallmentList({required this.controller});
  final InstallmentsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.state.isLoading && controller.installments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.state.isError && controller.installments.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh),
          label: Text(controller.errorMessage ?? 'إعادة المحاولة'),
        ),
      );
    }
    if (controller.installments.isEmpty) {
      return const Center(child: Text('لا توجد أقساط في هذا الفلتر.'));
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        itemCount: controller.installments.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (context, index) =>
            _InstallmentTile(installment: controller.installments[index]),
      ),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  const _InstallmentTile({required this.installment});
  final Installment installment;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<InstallmentsController>();
    final paid = installment.status == 'paid';
    final late = installment.status == 'late';
    final color = paid
        ? Colors.green
        : late
        ? Colors.red
        : Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    installment.customerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${installment.currency} ${installment.amount.toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '${installment.productName}  |  الاستحقاق: ${installment.dueDate}',
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  late
                      ? 'متأخر'
                      : paid
                      ? 'مدفوع'
                      : 'معلّق',
                  style: TextStyle(color: color),
                ),
                const Spacer(),
                if (!paid)
                  TextButton(
                    onPressed: () => controller.update(installment, 'pay'),
                    child: const Text('تسجيل الدفع'),
                  ),
                if (paid)
                  TextButton(
                    onPressed: () => controller.update(installment, 'unpay'),
                    child: const Text('إلغاء الدفع'),
                  ),
                IconButton(
                  onPressed: () => _editNote(context, controller),
                  icon: const Icon(Icons.notes_outlined),
                  tooltip: 'ملاحظة',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNote(
    BuildContext context,
    InstallmentsController controller,
  ) async {
    final notes = TextEditingController(text: installment.notes);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ملاحظة على القسط'),
        content: TextField(
          controller: notes,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'اكتب ملاحظة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, notes.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    notes.dispose();
    if (value != null) {
      await controller.update(installment, 'update_notes', notes: value);
    }
  }
}
