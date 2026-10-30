import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/product_data.dart';
import '../models/product.dart';
import '../services/purchase_history_service.dart';
import '../utils/app_theme.dart';
import '../utils/currency_format.dart';

class CheckoutPage extends StatefulWidget {
  final Map<int, int> cart;
  final ValueChanged<Map<int, int>> onCartChanged;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.onCartChanged,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _cashController = TextEditingController();
  late final Map<int, int> _cart;
  int _cash = 0;

  @override
  void initState() {
    super.initState();
    _cart = Map<int, int>.from(widget.cart);
  }

  List<Product> get _selectedProducts =>
      products.where((product) => (_cart[product.id] ?? 0) > 0).toList();

  int get _total => _selectedProducts.fold<int>(
        0,
        (sum, product) => sum + product.price * (_cart[product.id] ?? 0),
      );

  int get _change => _cash - _total;
  bool get _canPay => _total > 0 && _cash >= _total;

  void _changeQuantity(Product product, int change) {
    setState(() {
      final quantity = (_cart[product.id] ?? 0) + change;
      if (quantity <= 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = quantity;
      }
    });
    widget.onCartChanged(Map<int, int>.from(_cart));
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_canPay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang pembayaran belum mencukupi.')),
      );
      return;
    }

    await PurchaseHistoryService.addPurchase(
      cart: _cart,
      total: _total,
      cashReceived: _cash,
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          size: 44,
          color: AppColors.sage,
        ),
        title: const Text('Pembayaran berhasil'),
        content: Text('Kembalian: ${formatRupiah(_change)}'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isShort = _cashController.text.isNotEmpty && _cash < _total;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                Text(
                  'Ringkasan transaksi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Periksa pesanan sebelum menyelesaikan pembayaran.',
                  style: TextStyle(color: AppColors.sage),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      for (final product in _selectedProducts) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Harga satuan ${formatRupiah(product.price)}',
                                      style: const TextStyle(
                                        color: AppColors.sage,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatRupiah(
                                  product.price * _cart[product.id]!,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _QuantityButton(
                                icon: Icons.remove,
                                label: 'Kurangi ${product.name}',
                                onPressed: () => _changeQuantity(product, -1),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '${_cart[product.id]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              _QuantityButton(
                                icon: Icons.add,
                                label: 'Tambah ${product.name}',
                                onPressed: () => _changeQuantity(product, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total pembayaran'),
                          Text(
                            formatRupiah(_total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 19,
                              color: AppColors.forest,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Uang diterima (Rp)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cashController,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Contoh: 100000',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    errorText: isShort
                        ? 'Uang kurang ${formatRupiah(-_change)}'
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _cash = int.tryParse(value) ?? 0);
                  },
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Uang kembalian'),
                      Text(
                        formatRupiah(_change > 0 ? _change : 0),
                        style: const TextStyle(
                          color: AppColors.forest,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _canPay ? _pay : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Konfirmasi pembayaran'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onPressed,
        tooltip: label,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 20),
      );
}
