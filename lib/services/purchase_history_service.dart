import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/product_data.dart';
import '../models/purchase_record.dart';

class PurchaseHistoryService {
  PurchaseHistoryService._();

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const String _historyKey = 'purchase_history';

  static String _dateKey(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _invoiceNumber(DateTime date, int sequence) =>
      'INV-${_dateKey(date)}-${sequence.toString().padLeft(3, '0')}';

  static Future<List<PurchaseRecord>> getPurchases() async {
    final stored = await _prefs.getString(_historyKey);
    if (stored == null) return [];

    final decoded = jsonDecode(stored) as List<dynamic>;
    final history = decoded
        .map(
            (record) => PurchaseRecord.fromJson(record as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.purchasedAt.compareTo(b.purchasedAt));

    final dailyCounts = <String, int>{};
    var needsSave = false;
    final numberedHistory = history.map((record) {
      final dateKey = _dateKey(record.purchasedAt);
      final sequence = (dailyCounts[dateKey] ?? 0) + 1;
      dailyCounts[dateKey] = sequence;
      final invoiceNumber = _invoiceNumber(record.purchasedAt, sequence);
      if (record.invoiceNumber != invoiceNumber) needsSave = true;
      return PurchaseRecord(
        purchasedAt: record.purchasedAt,
        invoiceNumber: invoiceNumber,
        total: record.total,
        cashReceived: record.cashReceived,
        items: record.items,
      );
    }).toList();

    if (needsSave) await _saveHistory(numberedHistory);
    return numberedHistory.reversed.toList();
  }

  static Future<void> addPurchase({
    required Map<int, int> cart,
    required int total,
    required int cashReceived,
  }) async {
    final history = await getPurchases();
    final purchasedAt = DateTime.now();
    final todaysCount = history
        .where(
            (record) => _dateKey(record.purchasedAt) == _dateKey(purchasedAt))
        .length;
    final items = products
        .where((product) => (cart[product.id] ?? 0) > 0)
        .map((product) => PurchaseItem(
              name: product.name,
              price: product.price,
              quantity: cart[product.id]!,
            ))
        .toList();

    history.add(PurchaseRecord(
      purchasedAt: purchasedAt,
      invoiceNumber: _invoiceNumber(purchasedAt, todaysCount + 1),
      total: total,
      cashReceived: cashReceived,
      items: items,
    ));
    await _saveHistory(history);
  }

  static Future<void> _saveHistory(List<PurchaseRecord> history) async {
    await _prefs.setString(
      _historyKey,
      jsonEncode(history.map((record) => record.toJson()).toList()),
    );
  }
}
