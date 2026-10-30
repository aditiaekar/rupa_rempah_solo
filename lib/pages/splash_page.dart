import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'dashboard_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _openNextPage();
  }

  Future<void> _openNextPage() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    bool loggedIn = false;
    try {
      loggedIn = await AuthService.isLoggedIn();
    } catch (_) {
      // Jika penyimpanan lokal bermasalah, buka halaman masuk.
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => loggedIn ? const DashboardPage() : const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(size: 108),
                  const SizedBox(height: 24),
                  Text(
                    'Selamat Datang di Rupa Rempah Solo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Perawatan alami, pilihan istimewa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.sage),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
