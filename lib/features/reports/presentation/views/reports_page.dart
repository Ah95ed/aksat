import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/view_state.dart';
import '../controllers/reports_controller.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const _types = {
    'summary': 'الملخص',
    'by_product': 'حسب المادة',
    'top_selling': 'الأكثر مبيعاً',
    'timeline': 'الخط الزمني',
  };
  static const _periods = {
    'today': 'اليوم',
    'week': 'هذا الأسبوع',
    'month': 'هذا الشهر',
    'last_month': 'الشهر الماضي',
    'year': 'السنة',
    'all': 'الكل',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReportsController>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportsController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التقارير')),
        body: Column(
          children: [
            _Filters(controller: controller, types: _types, periods: _periods),
            Expanded(child: _ReportBody(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.controller,
    required this.types,
    required this.periods,
  });
  final ReportsController controller;
  final Map<String, String> types;
  final Map<String, String> periods;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
    child: Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: controller.type,
          decoration: const InputDecoration(labelText: 'نوع التقرير'),
          items: types.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) =>
              value == null ? null : controller.load(selectedType: value),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: controller.period,
                decoration: const InputDecoration(labelText: 'الفترة'),
                items: periods.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    value == null ? null : controller.setPeriod(value),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: controller.currency,
                decoration: const InputDecoration(labelText: 'العملة'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'LOCAL', child: Text('LOCAL')),
                ],
                onChanged: (value) =>
                    value == null ? null : controller.setCurrency(value),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.state.isError) {
      return Center(
        child: TextButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh),
          label: Text(controller.errorMessage ?? 'إعادة المحاولة'),
        ),
      );
    }
    final data = controller.result?.data;
    if (data == null) {
      return const Center(child: Text('لا توجد بيانات للتقرير.'));
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [_buildContent(context, controller.type, data)],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String type, dynamic data) {
    return switch (type) {
      'summary' => _SummaryReport(data: data),
      'timeline' => _TimelineReport(data: data),
      _ => _ListReport(data: data),
    };
  }
}

class _SummaryReport extends StatelessWidget {
  const _SummaryReport({required this.data});
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final map = data is Map ? data : const {};
    final cards = <Widget>[];
    for (final currency in ['USD', 'LOCAL']) {
      final values = map[currency] is Map ? map[currency] as Map : const {};
      cards.add(
        Card(
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(currency, style: Theme.of(context).textTheme.titleMedium),
                _Metric(label: 'الإيراد', value: values['total_revenue']),
                _Metric(label: 'التكلفة', value: values['total_cost']),
                _Metric(
                  label: 'الربح المتوقع',
                  value: values['expected_profit'],
                ),
                _Metric(label: 'المحصّل', value: values['total_collected']),
                _Metric(label: 'الربح الفعلي', value: values['actual_profit']),
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: cards);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value?.toString() ?? '0'),
      ],
    ),
  );
}

class _ListReport extends StatelessWidget {
  const _ListReport({required this.data});
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final rows = data is List ? data : const [];
    if (rows.isEmpty) return const Center(child: Text('لا توجد بيانات.'));
    return Column(
      children: rows
          .whereType<Map>()
          .map(
            (row) => Card(
              child: ListTile(
                title: Text(
                  (row['product_name'] ?? row['name'] ?? 'مادة').toString(),
                ),
                subtitle: Text(
                  'الكمية: ${(row['total_quantity'] ?? row['items_sold'] ?? 0)} | المبيعات: ${(row['sales_count'] ?? 0)}',
                ),
                trailing: Text((row['total_revenue'] ?? 0).toString()),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TimelineReport extends StatelessWidget {
  const _TimelineReport({required this.data});
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final rows = data is List ? data.whereType<Map>().toList() : <Map>[];
    final spots = rows
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            _number(entry.value['total_revenue']),
          ),
        )
        .toList();
    if (spots.isEmpty) {
      return const Center(child: Text('لا توجد بيانات زمنية.'));
    }
    return Column(
      children: [
        SizedBox(
          height: 260.h,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
            ),
          ),
        ),
        ...rows.map(
          (row) => ListTile(
            title: Text((row['period'] ?? '').toString()),
            trailing: Text((row['total_revenue'] ?? 0).toString()),
          ),
        ),
      ],
    );
  }

  static double _number(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;
}
