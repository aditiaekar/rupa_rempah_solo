import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    try {
      final success = await AuthService.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username atau password salah.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membaca akun lokal.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openRegister() async {
    final username = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
    if (!mounted) return;
    if (username != null) {
      _usernameController.text = username;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun berhasil dibuat. Silakan masuk.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandLogo(size: 88)),
                    const SizedBox(height: 25),
                    Text(
                      'Masuk ke akun',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola penjualan produk Rupa Rempah Solo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.sage),
                    ),
                    const SizedBox(height: 34),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Username wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _hidePassword = !_hidePassword,
                          ),
                          icon: Icon(_hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                      onFieldSubmitted: (_) {
                        if (!_busy) _login();
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _login,
                      child: Text(_busy ? 'Memproses...' : 'Masuk'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : _openRegister,
                      child: const Text('Belum punya akun? Daftar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
