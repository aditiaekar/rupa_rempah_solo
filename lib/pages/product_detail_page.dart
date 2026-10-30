import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/currency_format.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail produk')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AspectRatio(
                  aspectRatio: 1.35,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3ED),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  formatRupiah(product.price),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ukuran: ${product.size}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Tentang produk',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(product.description),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali ke dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
