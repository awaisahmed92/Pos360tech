import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import 'company_logo.dart';

/// Accounts-style sign in: company code, user name, and password.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_restore);
  }

  Future<void> _restore() async {
    final store = ref.read(storeProvider);
    final company = await store.meta('login_company');
    final username = await store.meta('login_user');
    if (!mounted) return;
    setState(() {
      if (company != null && company.isNotEmpty) _company.text = company;
      if (username != null && username.isNotEmpty) _username.text = username;
    });
  }

  @override
  void dispose() {
    _company.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final store = ref.read(storeProvider);
    if (_remember) {
      await store.setMeta('login_company', _company.text.trim());
      await store.setMeta('login_user', _username.text.trim());
    }
    final error = await ref.read(sessionProvider.notifier).login(
          companyCode: _company.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Material(
                  color: Colors.white,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const CompanyLogo(size: 36),
                              const SizedBox(width: 10),
                              const Text('POS360tech', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text('Sign in to your account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 24),
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDECEC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFF3C0C0)),
                              ),
                              child: Text(_error!, style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13)),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _field(label: 'Company Name:', controller: _company, hint: 'demo001'),
                          _field(label: 'UserName:', controller: _username, hint: 'UserName'),
                          _field(
                            label: 'Password:',
                            controller: _password,
                            hint: '••••••••',
                            obscure: _obscure,
                            suffix: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                            ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                activeColor: const Color(0xFF3B82F6),
                                onChanged: (value) => setState(() => _remember = value ?? true),
                              ),
                              const Text('Remember me', style: TextStyle(fontSize: 13)),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ask your company admin to reset your password.')),
                                  );
                                },
                                child: const Text('Forgot password?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 44,
                            child: FilledButton(
                              onPressed: _busy ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _busy
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                              GestureDetector(
                                onTap: _busy ? null : () => context.go('/sign-up'),
                                child: const Text('Create one', style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffix,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
