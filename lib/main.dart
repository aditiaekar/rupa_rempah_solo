import 'package:flutter/material.dart';

import 'pages/splash_page.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RupaRempahApp());
}

class RupaRempahApp extends StatelessWidget {
  const RupaRempahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rupa Rempah Solo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
