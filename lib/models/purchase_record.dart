class PurchaseItem {
  final String name;
  final int price;
  final int quantity;

  const PurchaseItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, Object> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory PurchaseItem.fromJson(Map<String, dynamic> json) => PurchaseItem(
        name: json['name'] as String,
        price: json['price'] as int,
        quantity: json['quantity'] as int,
      );
}

class PurchaseRecord {
  final DateTime purchasedAt;
  final String? invoiceNumber;
  final int total;
  final int? cashReceived;
  final List<PurchaseItem> items;

  const PurchaseRecord({
    required this.purchasedAt,
    this.invoiceNumber,
    required this.total,
    this.cashReceived,
    required this.items,
  });

  int? get change => cashReceived == null ? null : cashReceived! - total;

  Map<String, Object?> toJson() => {
        'purchasedAt': purchasedAt.toIso8601String(),
        'invoiceNumber': invoiceNumber,
        'total': total,
        'cashReceived': cashReceived,
        'items': items.map((item) => item.toJson()).toList(),
      };

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
        purchasedAt: DateTime.parse(json['purchasedAt'] as String),
        invoiceNumber: json['invoiceNumber'] as String?,
        total: json['total'] as int,
        cashReceived: json['cashReceived'] as int?,
        items: (json['items'] as List<dynamic>)
            .map((item) => PurchaseItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
