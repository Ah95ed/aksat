import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/view_state.dart';
import '../../domain/entities/customer.dart';
import '../controllers/customers_controller.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CustomersController>().load(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _form([Customer? customer]) async {
    final value = await showDialog<Customer>(
      context: context,
      builder: (_) => CustomerFormDialog(customer: customer),
    );
    if (!mounted || value == null) return;
    final controller = context.read<CustomersController>();
    if (!await controller.save(value) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'تعذر الحفظ.')),
      );
    }
  }

  Future<void> _remove(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المشتري'),
        content: Text(
          'سيتم حذف مبيعات وأقساط «${customer.name}» أيضاً. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف نهائياً'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final controller = context.read<CustomersController>();
    if (!await controller.remove(customer.id) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'تعذر الحذف.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomersController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المشترون')),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: TextField(
                controller: _search,
                onChanged: controller.search,
                decoration: const InputDecoration(
                  hintText: 'بحث بالاسم أو الهاتف',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: _CustomerList(
                controller: controller,
                onEdit: _form,
                onDelete: _remove,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _form(),
          icon: const Icon(Icons.person_add_alt_rounded),
          label: const Text('مشتري جديد'),
        ),
      ),
    );
  }
}

class _CustomerList extends StatelessWidget {
  const _CustomerList({
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomersController controller;
  final ValueChanged<Customer> onEdit;
  final ValueChanged<Customer> onDelete;

  @override
  Widget build(BuildContext context) {
    if (controller.state.isLoading && controller.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.state.isError && controller.customers.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh),
          label: Text(controller.errorMessage ?? 'إعادة المحاولة'),
        ),
      );
    }
    if (controller.customers.isEmpty) {
      return const Center(child: Text('لا يوجد مشترون بعد.'));
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 96.h),
        itemCount: controller.customers.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (_, index) {
          final customer = controller.customers[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(customer.name.characters.first),
              ),
              title: Text(customer.name),
              subtitle: Text(
                '${customer.phone}\nمبيعات: ${customer.salesCount}  |  متأخرة: ${customer.lateCount}',
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (value) =>
                    value == 'edit' ? onEdit(customer) : onDelete(customer),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomerFormDialog extends StatefulWidget {
  const CustomerFormDialog({super.key, this.customer});
  final Customer? customer;

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _name = TextEditingController(text: customer?.name);
    _phone = TextEditingController(text: customer?.phone);
    _address = TextEditingController(text: customer?.address);
    _notes = TextEditingController(text: customer?.notes);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.customer == null ? 'إضافة مشترٍ' : 'تعديل مشترٍ'),
    content: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'الاسم'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'اكتب الاسم.' : null,
            ),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'الهاتف'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'اكتب الهاتف.' : null,
            ),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'العنوان'),
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
      FilledButton(
        onPressed: () {
          if (!_key.currentState!.validate()) return;
          Navigator.pop(
            context,
            Customer(
              id: widget.customer?.id ?? '',
              name: _name.text.trim(),
              phone: _phone.text.trim(),
              address: _address.text.trim(),
              notes: _notes.text.trim(),
            ),
          );
        },
        child: const Text('حفظ'),
      ),
    ],
  );
}
