import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/purchase_record.dart';
import '../utils/app_theme.dart';
import '../utils/currency_format.dart';

class InvoicePage extends StatefulWidget {
  final PurchaseRecord purchase;

  const InvoicePage({super.key, required this.purchase});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool _isDownloading = false;

  String get _invoiceNumber =>
      widget.purchase.invoiceNumber ??
      'INV-${_dateOnly(widget.purchase.purchasedAt)}-001';

  String _dateOnly(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }

  pw.Widget _pdfCell(String text, {pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        child: pw.Text(text, textAlign: align),
      );

  Future<Uint8List> _buildPdf() async {
    final purchase = widget.purchase;
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'Rupa Rempah Solo',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('INVOICE  $_invoiceNumber'),
          pw.Text('Tanggal: ${_formatDate(purchase.purchasedAt)}'),
          pw.SizedBox(height: 24),
          pw.Table(
            border: pw.TableBorder(
              top: const pw.BorderSide(),
              bottom: const pw.BorderSide(),
              horizontalInside: const pw.BorderSide(color: PdfColors.grey300),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(4),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                children: [
                  _pdfCell('Produk'),
                  _pdfCell('Jumlah', align: pw.TextAlign.right),
                  _pdfCell('Harga satuan', align: pw.TextAlign.right),
                  _pdfCell('Subtotal', align: pw.TextAlign.right),
                ],
              ),
              for (final item in purchase.items)
                pw.TableRow(
                  children: [
                    _pdfCell(item.name),
                    _pdfCell('${item.quantity}', align: pw.TextAlign.right),
                    _pdfCell(formatRupiah(item.price),
                        align: pw.TextAlign.right),
                    _pdfCell(
                      formatRupiah(item.price * item.quantity),
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total pembayaran: ${formatRupiah(purchase.total)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (purchase.cashReceived != null) ...[
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Tunai diterima: ${formatRupiah(purchase.cashReceived!)}',
              ),
            ),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Kembalian: ${formatRupiah(purchase.change!)}'),
            ),
          ],
          pw.SizedBox(height: 32),
          pw.Text('Terima kasih telah berbelanja.'),
        ],
      ),
    );
    return pdf.save();
  }

  Future<void> _downloadInvoice() async {
    setState(() => _isDownloading = true);
    try {
      await Printing.layoutPdf(
        name: 'invoice-$_invoiceNumber.pdf',
        onLayout: (_) => _buildPdf(),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice gagal diunduh.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchase = widget.purchase;
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rupa Rempah Solo',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Invoice: $_invoiceNumber'),
                        Text('Tanggal: ${_formatDate(purchase.purchasedAt)}'),
                        const Divider(height: 28),
                        for (final item in purchase.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity} × ${formatRupiah(item.price)}',
                                        style: const TextStyle(
                                          color: AppColors.sage,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(formatRupiah(item.quantity * item.price)),
                              ],
                            ),
                          ),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total pembayaran'),
                            Text(
                              formatRupiah(purchase.total),
                              style: const TextStyle(
                                color: AppColors.forest,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (purchase.cashReceived != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tunai diterima'),
                              Text(formatRupiah(purchase.cashReceived!)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kembalian'),
                              Text(formatRupiah(purchase.change!)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isDownloading ? null : _downloadInvoice,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  label: const Text('Unduh invoice PDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
