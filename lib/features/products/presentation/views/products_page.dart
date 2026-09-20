import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/view_state.dart';
import '../../domain/entities/product.dart';
import '../controllers/products_controller.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProductsController>().load(),
    );
  }

  Future<void> _openForm([Product? product]) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => ProductFormDialog(product: product),
    );
    if (!mounted || result == null) return;
    final controller = context.read<ProductsController>();
    final saved = await controller.save(result);
    if (!mounted || saved || controller.errorMessage == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(controller.errorMessage!)));
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المادة'),
        content: Text('هل تريد حذف «${product.name}»؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final controller = context.read<ProductsController>();
    final deleted = await controller.remove(product.id);
    if (!mounted || deleted || controller.errorMessage == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(controller.errorMessage!)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductsController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المواد')),
        body: RefreshIndicator(
          onRefresh: controller.load,
          child: _ProductsBody(
            controller: controller,
            onEdit: _openForm,
            onDelete: _delete,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('مادة جديدة'),
        ),
      ),
    );
  }
}

class _ProductsBody extends StatelessWidget {
  const _ProductsBody({
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductsController controller;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  @override
  Widget build(BuildContext context) {
    if (controller.state.isLoading && controller.products.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 260),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (controller.state.isError && controller.products.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 180.h),
          Center(child: Text(controller.errorMessage ?? 'تعذر تحميل المواد.')),
          Center(
            child: TextButton.icon(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
        ],
      );
    }
    if (controller.products.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 180.h),
          const Center(child: Icon(Icons.inventory_2_outlined, size: 48)),
          SizedBox(height: 12.h),
          const Center(child: Text('لا توجد مواد بعد.')),
        ],
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
      itemCount: controller.products.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return Card(
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 6.h,
            ),
            leading: CircleAvatar(child: Text(product.name.characters.first)),
            title: Text(product.name),
            subtitle: Text(
              '${product.currency} ${product.price.toStringAsFixed(2)}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) =>
                  value == 'edit' ? onEdit(product) : onDelete(product),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('تعديل')),
                PopupMenuItem(value: 'delete', child: Text('حذف')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _cost;
  late final TextEditingController _notes;
  late String _currency;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name);
    _price = TextEditingController(text: product?.price.toString());
    _cost = TextEditingController(text: product?.costPrice.toString());
    _notes = TextEditingController(text: product?.notes);
    _currency = product?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Product(
        id: widget.product?.id ?? '',
        name: _name.text.trim(),
        price: double.parse(_price.text),
        costPrice: double.tryParse(_cost.text) ?? 0,
        currency: _currency,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'إضافة مادة' : 'تعديل المادة'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'اسم المادة'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'اكتب اسم المادة.'
                    : null,
              ),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'سعر البيع'),
                validator: (value) => double.tryParse(value ?? '') == null
                    ? 'اكتب سعراً صحيحاً.'
                    : null,
              ),
              TextFormField(
                controller: _cost,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'سعر الشراء'),
                validator: (value) =>
                    value != null &&
                        value.isNotEmpty &&
                        double.tryParse(value) == null
                    ? 'اكتب رقماً صحيحاً.'
                    : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(labelText: 'العملة'),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'LOCAL', child: Text('LOCAL')),
                ],
                onChanged: (value) =>
                    setState(() => _currency = value ?? 'USD'),
              ),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _save, child: const Text('حفظ')),
      ],
    );
  }
}
