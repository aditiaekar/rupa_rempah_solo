import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class UpdateAccountPage extends StatefulWidget {
  const UpdateAccountPage({super.key});

  @override
  State<UpdateAccountPage> createState() => _UpdateAccountPageState();
}

class _UpdateAccountPageState extends State<UpdateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await AuthService.getUsername();
    if (mounted) setState(() => _usernameController.text = username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    try {
      await AuthService.updateCredentials(
        username: _usernameController.text,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data akun berhasil diperbarui.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui akun.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan akun')),
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
                      'Perbarui akun',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kosongkan password jika tidak ingin mengubahnya.',
                      style: TextStyle(color: AppColors.sage),
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username baru',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value == null || value.trim().length < 3
                          ? 'Minimal 3 karakter.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password baru (opsional)',
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
                      validator: (value) => value != null &&
                              value.isNotEmpty &&
                              value.length < 6
                          ? 'Password minimal 6 karakter.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _save,
                      child: Text(_busy ? 'Menyimpan...' : 'Simpan perubahan'),
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
