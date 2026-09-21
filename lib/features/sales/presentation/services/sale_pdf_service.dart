import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../customers/domain/entities/customer_detail.dart';
import '../../../settings/domain/entities/store_settings.dart';

class SalePdfService {
  SalePdfService._();

  static Future<void> printSale({
    required CustomerDetail customer,
    required CustomerDetailSale sale,
    required StoreSettings settings,
  }) async {
    final pdf = pw.Document();

    // Load Cairo font for proper Arabic rendering
    final fontData = await rootBundle.load('assets/fonts/cairo-variable.ttf');
    final ttf = pw.Font.ttf(fontData);

    final sym = sale.currency == 'USD'
        ? '\$'
        : MoneyFormatter.currencySymbol('LOCAL', settings);
    final storeName = settings.storeName.isNotEmpty ? settings.storeName : 'نظام إدارة الأقساط';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Store Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 2)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      storeName,
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                    ),
                    pw.Text(
                      'وصل عملية بيع بالتقسيط',
                      style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Customer & Sale Info
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'المشتري: ${customer.name}',
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'الهاتف: ${customer.phone}',
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                          ),
                          if (customer.address != null && customer.address!.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'العنوان: ${customer.address}',
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'المادة: ${sale.productName} ${sale.quantity > 1 ? "(${sale.quantity}x)" : ""}',
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'تاريخ البيع: ${DateFormatter.formatDateNumeric(sale.saleDate)}',
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'نوع الأقساط: ${sale.installmentType == "weekly" ? "أسبوعي" : "شهري"} (${sale.installmentsCount} قسط)',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Summary 4 boxes
              pw.Row(
                children: [
                  _pdfSummaryBox('السعر الكلي', '${MoneyFormatter.formatAmount(sale.totalPrice)} $sym', PdfColors.grey200, PdfColors.black),
                  pw.SizedBox(width: 8),
                  _pdfSummaryBox('المقدمة', '${MoneyFormatter.formatAmount(sale.downPayment)} $sym', PdfColors.amber100, PdfColors.amber900),
                  pw.SizedBox(width: 8),
                  _pdfSummaryBox('المدفوع', '${MoneyFormatter.formatAmount(sale.paidAmount + sale.downPayment)} $sym', PdfColors.green100, PdfColors.green900),
                  pw.SizedBox(width: 8),
                  _pdfSummaryBox('المتبقي', '${MoneyFormatter.formatAmount(sale.remaining - sale.paidAmount)} $sym', PdfColors.blue100, PdfColors.blue900),
                ],
              ),
              pw.SizedBox(height: 20),

              // Installments table
              pw.Text(
                'جدول الأقساط (${sale.paidCount} من ${sale.installments.length} مدفوع)',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                  horizontalInside: pw.BorderSide(color: PdfColors.grey200),
                ),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _pdfTh('#'),
                      _pdfTh('تاريخ الاستحقاق'),
                      _pdfTh('المبلغ'),
                      _pdfTh('الحالة'),
                      _pdfTh('تاريخ الدفع'),
                    ],
                  ),
                  ...sale.installments.map((inst) {
                    final isPaid = inst.status == 'paid';
                    final isLate = inst.status == 'late';
                    final statusLabel = isPaid
                        ? 'مدفوع'
                        : isLate
                            ? 'متأخر'
                            : 'قادم';
                    final rowColor = isPaid
                        ? PdfColors.green50
                        : isLate
                            ? PdfColors.red50
                            : PdfColors.white;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: rowColor),
                      children: [
                        _pdfTd('${inst.installmentNumber}'),
                        _pdfTd(DateFormatter.formatDateShort(inst.dueDate)),
                        _pdfTd('${MoneyFormatter.formatAmount(inst.amount)} $sym', isBold: true),
                        _pdfTd(statusLabel),
                        _pdfTd(inst.paidDate != null ? DateFormatter.formatDateShort(inst.paidDate!) : '-'),
                      ],
                    );
                  }),
                ],
              ),

              if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    border: const pw.Border(right: pw.BorderSide(color: PdfColors.amber400, width: 4)),
                  ),
                  child: pw.Text(
                    'ملاحظات: ${sale.notes}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                  ),
                ),
              ],

              pw.Spacer(),

              // Signatures
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 24),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('توقيع المشتري', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 36),
                        pw.Container(width: 120, height: 1, color: PdfColors.grey400),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('ختم / توقيع المحل', style: const pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 36),
                        pw.Container(width: 120, height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'وصل_بيع_${customer.name}_${sale.productName}.pdf',
    );
  }

  static pw.Widget _pdfSummaryBox(String label, String value, PdfColor bg, PdfColor textCol) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            pw.SizedBox(height: 3),
            pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textCol)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _pdfTh(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _pdfTd(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.grey900,
        ),
      ),
    );
  }
}
