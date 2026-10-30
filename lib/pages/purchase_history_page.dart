import 'package:flutter/material.dart';

import '../models/purchase_record.dart';
import '../services/purchase_history_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_format.dart';
import 'invoice_page.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late final Future<List<PurchaseRecord>> _purchases =
      PurchaseHistoryService.getPurchases();

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pembelian')),
      body: FutureBuilder<List<PurchaseRecord>>(
        future: _purchases,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Riwayat pembelian gagal dimuat.'));
          }
          final purchases = snapshot.data ?? [];
          if (purchases.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pembelian.',
                style: TextStyle(color: AppColors.sage),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: purchases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(purchase.purchasedAt),
                        style: const TextStyle(color: AppColors.sage),
                      ),
                      const SizedBox(height: 10),
                      for (final item in purchase.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(child: Text(item.name)),
                              Text(
                                  '${item.quantity} × ${formatRupiah(item.price)}'),
                            ],
                          ),
                        ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total pembayaran'),
                          Text(
                            formatRupiah(purchase.total),
                            style: const TextStyle(
                              color: AppColors.forest,
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => InvoicePage(purchase: purchase),
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Lihat invoice'),
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
    );
  }
}
