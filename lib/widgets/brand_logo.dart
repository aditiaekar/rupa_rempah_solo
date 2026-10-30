import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(color: AppColors.line),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}
