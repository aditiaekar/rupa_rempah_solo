import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/app_theme.dart';
import '../utils/currency_format.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onDetails;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Material(
                    color: const Color(0xFFF1F3ED),
                    child: InkWell(
                      onTap: onAdd,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          product.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.sage,
                              size: 48,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (quantity > 0)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.forest,
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const Positioned(
                  bottom: 8,
                  right: 9,
                  child: Icon(
                    Icons.add_circle,
                    color: AppColors.forest,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: onDetails,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 38,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.forest,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatRupiah(product.price),
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
