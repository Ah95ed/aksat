import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/view_state.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customers_repository.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/products_repository.dart';
import '../../domain/entities/sale.dart';
import '../controllers/sales_controller.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key, this.openCreate = false});

  final bool openCreate;

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesController>().load();
      if (widget.openCreate) _create();
    });
  }

  Future<void> _create() async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _SaleFormDialog(),
    );
    if (!mounted || data == null) return;
    final controller = context.read<SalesController>();
    if (!await controller.create(data) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'تعذر التسجيل.')),
      );
    }
  }

  Future<void> _delete(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف البيع'),
        content: const Text('سيتم حذف البيع وأقساطه وإعادة الكمية للمخزن.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await context.read<SalesController>().remove(sale.id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SalesController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المبيعات')),
        body: _SalesList(controller: controller, onDelete: _delete),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _create,
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: const Text('بيع جديد'),
        ),
      ),
    );
  }
}

class _SalesList extends StatelessWidget {
  const _SalesList({required this.controller, required this.onDelete});
  final SalesController controller;
  final ValueChanged<Sale> onDelete;

  @override
  Widget build(BuildContext context) {
    if (controller.state.isLoading && controller.sales.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.state.isError && controller.sales.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh),
          label: Text(controller.errorMessage ?? 'إعادة المحاولة'),
        ),
      );
    }
    if (controller.sales.isEmpty) {
      return const Center(child: Text('لا توجد مبيعات بعد.'));
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
        itemCount: controller.sales.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (_, index) {
          final sale = controller.sales[index];
          return Card(
            child: ListTile(
              title: Text(sale.productName),
              subtitle: Text(
                '${sale.customerName}\n${sale.status} | ${sale.installmentsCount} أقساط | ${sale.saleDate}',
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${sale.currency} ${sale.totalPrice.toStringAsFixed(2)}',
                  ),
                  IconButton(
                    onPressed: () => onDelete(sale),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'حذف',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SaleFormDialog extends StatefulWidget {
  const _SaleFormDialog();
  @override
  State<_SaleFormDialog> createState() => _SaleFormDialogState();
}

class _SaleFormDialogState extends State<_SaleFormDialog> {
  final _key = GlobalKey<FormState>();
  final _customerId = TextEditingController();
  final _productId = TextEditingController();
  final _productName = TextEditingController();
  final _customerSearch = TextEditingController();
  final _total = TextEditingController();
  final _down = TextEditingController(text: '0');
  final _count = TextEditingController(text: '1');
  final _quantity = TextEditingController(text: '1');
  List<Product> _products = const [];
  List<Customer> _suggestions = const [];
  Product? _selectedProduct;
  Customer? _selectedCustomer;
  bool _loadingProducts = true;
  bool _searchingCustomers = false;
  String? _loadError;
  DateTime? _lastSearch;
  String _currency = 'USD';
  String _type = 'monthly';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    try {
      final products = await context.read<ProductsRepository>().fetchAll();
      if (!mounted) return;
      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _loadError = 'تعذر تحميل المواد.';
      });
    }
  }

  Future<void> _searchCustomers(String value) async {
    final query = value.trim();
    _selectedCustomer = null;
    if (query.length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    final stamp = DateTime.now();
    _lastSearch = stamp;
    setState(() => _searchingCustomers = true);
    try {
      final customers = await context.read<CustomersRepository>().fetchAll(
        search: query,
      );
      if (!mounted || _lastSearch != stamp) return;
      setState(() {
        _suggestions = customers;
        _searchingCustomers = false;
      });
    } catch (_) {
      if (mounted && _lastSearch == stamp) {
        setState(() => _searchingCustomers = false);
      }
    }
  }

  void _selectProduct(Product? product) {
    if (product == null) return;
    setState(() {
      _selectedProduct = product;
      _productId.text = product.id;
      _productName.text = product.name;
      _total.text = product.price.toString();
      _currency = product.currency;
    });
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _customerId.text = customer.id;
      _customerSearch.text = customer.name;
      _suggestions = const [];
    });
  }

  @override
  void dispose() {
    for (final field in [
      _customerId,
      _productId,
      _productName,
      _total,
      _down,
      _count,
      _quantity,
      _customerSearch,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  double get _preview {
    final total = double.tryParse(_total.text) ?? 0;
    final down = double.tryParse(_down.text) ?? 0;
    final count = int.tryParse(_count.text) ?? 1;
    return count > 0 ? (total - down) / count : 0;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('بيع جديد'),
    content: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loadError != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  _loadError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            TextFormField(
              controller: _customerSearch,
              decoration: InputDecoration(
                labelText: 'اسم المشتري',
                hintText: 'اكتب حرفين على الأقل للبحث',
                suffixIcon: _searchingCustomers
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
              ),
              onChanged: _searchCustomers,
              validator: (_) => _selectedCustomer == null
                  ? 'اختر مشترياً من نتائج البحث.'
                  : null,
            ),
            if (_suggestions.isNotEmpty)
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: _suggestions
                      .take(5)
                      .map(
                        (customer) => ListTile(
                          dense: true,
                          title: Text(customer.name),
                          subtitle: Text(customer.phone),
                          onTap: () => _selectCustomer(customer),
                        ),
                      )
                      .toList(),
                ),
              ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<Product>(
              initialValue: _selectedProduct,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'اختر المادة'),
              items: _products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product,
                      child: Text(
                        '${product.name} - ${product.price.toStringAsFixed(2)} ${product.currency}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _loadingProducts ? null : _selectProduct,
              validator: (_) => _selectedProduct == null ? 'اختر مادة.' : null,
            ),
            if (_loadingProducts)
              const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              ),
            _field(_total, 'السعر الكلي', number: true),
            _field(_down, 'الدفعة المقدمة', number: true),
            _field(_count, 'عدد الأقساط', number: true),
            _field(_quantity, 'الكمية', number: true),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'نوع القسط'),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('شهري')),
                DropdownMenuItem(value: 'weekly', child: Text('أسبوعي')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'monthly'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'العملة'),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'LOCAL', child: Text('LOCAL')),
              ],
              onChanged: (value) => setState(() => _currency = value ?? 'USD'),
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'المعاينة: ${_preview.toStringAsFixed(2)} $_currency لكل قسط',
              ),
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
      FilledButton(onPressed: _save, child: const Text('تسجيل')),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    decoration: InputDecoration(labelText: label),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب.' : null,
    onChanged: (_) => setState(() {}),
  );

  void _save() {
    if (!_key.currentState!.validate()) return;
    final total = double.tryParse(_total.text) ?? 0;
    final down = double.tryParse(_down.text) ?? 0;
    final count = int.tryParse(_count.text) ?? 0;
    if (total <= 0 || down < 0 || down >= total || count < 1 || count > 120) {
      return;
    }
    Navigator.pop(context, {
      'customer_id': _customerId.text.trim(),
      'product_id': _productId.text.trim(),
      'product_name': _productName.text.trim(),
      'total_price': total,
      'down_payment': down,
      'installments_count': count,
      'installment_type': _type,
      'currency': _currency,
      'sale_date': DateTime.now().toIso8601String().substring(0, 10),
      'quantity': int.tryParse(_quantity.text) ?? 1,
    });
  }
}
