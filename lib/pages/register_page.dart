import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    try {
      await AuthService.register(
        fullName: _nameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(_usernameController.text.trim());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan akun.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar akun')),
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
                    Text(
                      'Buat akun baru',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Data akun disimpan secara lokal di perangkat.',
                      style: TextStyle(color: AppColors.sage),
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Nama lengkap wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) => value == null || value.trim().length < 3
                          ? 'Minimal 3 karakter.'
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
                      validator: (value) => value == null || value.length < 6
                          ? 'Password minimal 6 karakter.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _register,
                      child: Text(_busy ? 'Menyimpan...' : 'Buat akun'),
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
