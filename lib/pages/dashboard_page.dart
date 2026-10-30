import 'package:flutter/material.dart';

import '../data/product_data.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/contact_service.dart';
import '../utils/app_theme.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/product_card.dart';
import 'checkout_page.dart';
import 'login_page.dart';
import 'purchase_history_page.dart';
import 'product_detail_page.dart';
import 'update_account_page.dart';

enum DashboardMenu { call, sms, maps, purchaseHistory, account, logout }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Map<int, int> _cart = {};
  String _fullName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getFullName();
    if (mounted) setState(() => _fullName = name);
  }

  int get _totalQuantity =>
      _cart.values.fold<int>(0, (sum, quantity) => sum + quantity);

  int get _totalPrice => products.fold<int>(
        0,
        (sum, product) => sum + product.price * (_cart[product.id] ?? 0),
      );

  void _addProduct(Product product) {
    setState(() {
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan.'),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _updateCart(Map<int, int> cart) {
    setState(() {
      _cart
        ..clear()
        ..addAll(cart);
    });
  }

  void _showProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  Future<void> _openCheckout() async {
    if (_cart.isEmpty) return;

    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CheckoutPage(
          cart: Map<int, int>.from(_cart),
          onCartChanged: _updateCart,
        ),
      ),
    );
    if (!mounted) return;
    if (paid == true) {
      setState(_cart.clear);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi selesai. Keranjang direset.')),
      );
    }
  }

  Future<void> _openExternal(Future<bool> Function() launcher) async {
    try {
      final opened = await launcher();
      if (!mounted) return;
      if (!opened) {
        _showMessage(
            'Belum dapat dibuka. Periksa konfigurasi kontak dan aplikasi terkait.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Tidak ada aplikasi yang bisa membuka layanan ini.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleMenu(DashboardMenu value) async {
    switch (value) {
      case DashboardMenu.call:
        await _openExternal(ContactService.callSeller);
        return;
      case DashboardMenu.sms:
        await _openExternal(ContactService.smsSeller);
        return;
      case DashboardMenu.maps:
        await _openExternal(ContactService.openMaps);
        return;
      case DashboardMenu.purchaseHistory:
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PurchaseHistoryPage(),
          ),
        );
        return;
      case DashboardMenu.account:
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const UpdateAccountPage()),
        );
        return;
      case DashboardMenu.logout:
        await AuthService.logout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          (_) => false,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rupa Rempah Solo'),
        actions: [
          PopupMenuButton<DashboardMenu>(
            tooltip: 'Menu lainnya',
            onSelected: _handleMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: DashboardMenu.call,
                child:
                    _MenuItem(icon: Icons.call_outlined, text: 'Call Center'),
              ),
              PopupMenuItem(
                value: DashboardMenu.sms,
                child: _MenuItem(icon: Icons.sms_outlined, text: 'SMS Center'),
              ),
              PopupMenuItem(
                value: DashboardMenu.maps,
                child:
                    _MenuItem(icon: Icons.map_outlined, text: 'Lokasi / Maps'),
              ),
              PopupMenuItem(
                value: DashboardMenu.purchaseHistory,
                child: _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  text: 'Riwayat Pembelian',
                ),
              ),
              PopupMenuItem(
                value: DashboardMenu.account,
                child: _MenuItem(
                  icon: Icons.manage_accounts_outlined,
                  text: 'Update User & Password',
                ),
              ),
              PopupMenuItem(
                value: DashboardMenu.logout,
                child: _MenuItem(icon: Icons.logout, text: 'Logout'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: CartSummaryBar(
        quantity: _totalQuantity,
        total: _totalPrice,
        onTap: _cart.isEmpty ? null : _openCheckout,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $_fullName',
                    style: const TextStyle(color: AppColors.brown),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Pilihan perawatan alami',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ketuk gambar untuk menambah, nama untuk detail.',
                    style: TextStyle(color: AppColors.sage, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 760
                      ? 4
                      : width >= 500
                          ? 3
                          : 2;
                  const padding = 16.0;
                  const spacing = 12.0;
                  final cardWidth =
                      (width - padding * 2 - (columns - 1) * spacing) / columns;

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      mainAxisExtent: cardWidth + 105,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        quantity: _cart[product.id] ?? 0,
                        onAdd: () => _addProduct(product),
                        onDetails: () => _showProductDetails(product),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MenuItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Flexible(child: Text(text)),
      ],
    );
  }
}
