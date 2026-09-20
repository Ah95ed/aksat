import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/view_state.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_movement.dart';
import '../controllers/inventory_controller.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<InventoryController>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InventoryController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المخزن'),
          actions: [
            IconButton(
              onPressed: () =>
                  controller.load(lowStock: !controller.lowStockOnly),
              icon: Icon(
                controller.lowStockOnly
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_outlined,
              ),
              tooltip: 'المخزون المنخفض',
            ),
          ],
        ),
        body: _InventoryBody(controller: controller),
      ),
    );
  }
}

class _InventoryBody extends StatelessWidget {
  const _InventoryBody({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.state.isLoading && controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.state.isError && controller.items.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(controller.errorMessage ?? 'إعادة المحاولة'),
        ),
      );
    }
    if (controller.items.isEmpty) {
      return Center(
        child: Text(
          controller.lowStockOnly
              ? 'لا توجد مواد منخفضة المخزون.'
              : 'لا توجد مواد في المخزن بعد.',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        itemCount: controller.items.length,
        separatorBuilder: (_, _) => SizedBox(height: 10.h),
        itemBuilder: (_, index) =>
            _InventoryCard(item: controller.items[index]),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<InventoryController>();
    final statusColor = switch (item.stockStatus) {
      'out_of_stock' => Colors.red,
      'low_stock' => Colors.orange,
      'in_stock' => Colors.green,
      _ => Theme.of(context).colorScheme.outline,
    };
    final statusText = switch (item.stockStatus) {
      'out_of_stock' => 'نفد المخزون',
      'low_stock' => 'مخزون منخفض',
      'in_stock' => 'متوفر',
      _ => 'غير مفعّل',
    };

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
                    item.productName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('${item.currency} ${item.price.toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: statusColor),
                SizedBox(width: 8.w),
                Text(
                  'الكمية: ${item.quantity}',
                  style: TextStyle(color: statusColor),
                ),
                const Spacer(),
                Text(statusText, style: TextStyle(color: statusColor)),
              ],
            ),
            if (item.stockStatus != 'not_tracked') ...[
              SizedBox(height: 4.h),
              Text('حد التنبيه: ${item.lowStockThreshold}'),
            ],
            OverflowBar(
              children: [
                TextButton.icon(
                  onPressed: () => _showMovements(context, controller),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('الحركات'),
                ),
                TextButton.icon(
                  onPressed: () => _showEditor(context, controller),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('تعديل'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    InventoryController controller,
  ) async {
    final result = await showDialog<_InventoryEdit>(
      context: context,
      builder: (_) => _InventoryEditDialog(item: item),
    );
    if (!context.mounted || result == null) return;
    final saved = await controller.save(
      productId: item.productId,
      quantity: result.quantity,
      action: result.action,
      lowStockThreshold: result.threshold,
      notes: result.notes,
    );
    if (!context.mounted || saved || controller.errorMessage == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(controller.errorMessage!)));
  }

  Future<void> _showMovements(
    BuildContext context,
    InventoryController controller,
  ) async {
    final movements = await controller.movements(item.productId);
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _MovementsSheet(movements: movements),
    );
  }
}

class _InventoryEdit {
  const _InventoryEdit({
    required this.quantity,
    required this.action,
    required this.threshold,
    this.notes,
  });
  final int quantity;
  final String action;
  final int threshold;
  final String? notes;
}

class _InventoryEditDialog extends StatefulWidget {
  const _InventoryEditDialog({required this.item});
  final InventoryItem item;

  @override
  State<_InventoryEditDialog> createState() => _InventoryEditDialogState();
}

class _InventoryEditDialogState extends State<_InventoryEditDialog> {
  late final TextEditingController _quantity;
  late final TextEditingController _threshold;
  late final TextEditingController _notes;
  String _action = 'set';

  @override
  void initState() {
    super.initState();
    _quantity = TextEditingController(text: widget.item.quantity.toString());
    _threshold = TextEditingController(
      text: widget.item.lowStockThreshold.toString(),
    );
    _notes = TextEditingController(text: widget.item.notes);
  }

  @override
  void dispose() {
    _quantity.dispose();
    _threshold.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.item.stockStatus == 'not_tracked'
          ? 'تفعيل تتبع المخزون'
          : 'تعديل المخزون',
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _quantity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'الكمية'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _action,
            decoration: const InputDecoration(labelText: 'طريقة التعديل'),
            items: const [
              DropdownMenuItem(value: 'set', child: Text('تحديد الكمية')),
              DropdownMenuItem(value: 'add', child: Text('إضافة إلى الكمية')),
            ],
            onChanged: (value) => setState(() => _action = value ?? 'set'),
          ),
          TextField(
            controller: _threshold,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'حد المخزون المنخفض'),
          ),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'ملاحظات'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () {
          final quantity = int.tryParse(_quantity.text);
          final threshold = int.tryParse(_threshold.text);
          if (quantity == null ||
              threshold == null ||
              quantity < 0 ||
              threshold < 0) {
            return;
          }
          Navigator.pop(
            context,
            _InventoryEdit(
              quantity: quantity,
              action: _action,
              threshold: threshold,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );
}

class _MovementsSheet extends StatelessWidget {
  const _MovementsSheet({required this.movements});
  final List<InventoryMovement> movements;

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return const SafeArea(child: Center(child: Text('لا توجد حركات.')));
    }
    return SafeArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: movements.length,
        itemBuilder: (_, index) {
          final movement = movements[index];
          return ListTile(
            leading: const Icon(Icons.swap_vert_rounded),
            title: Text('${movement.type}: ${movement.quantity}'),
            subtitle: Text(movement.createdAt),
          );
        },
      ),
    );
  }
}
