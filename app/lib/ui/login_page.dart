import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import 'company_logo.dart';

/// Split sign-in: company, user, and password on the left, shop story on the right.
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

  static const _teal = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final form = _formCard();
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3F7F6), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: wide
              ? Row(children: [Expanded(flex: 38, child: form), const Expanded(flex: 62, child: _PosHero())])
              : form,
        ),
      ),
    );
  }

  Widget _formCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CompanyLogo(size: 32),
                              SizedBox(width: 10),
                              Text('POS360tech', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                            ],
                          ),
                          const SizedBox(height: 26),
                          const Text('Welcome Back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text('Sign in to continue', style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
                          const SizedBox(height: 24),
                          if (_error != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDECEC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF3C0C0)),
                              ),
                              child: Text(_error!, style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13)),
                            ),
                            const SizedBox(height: 14),
                          ],
                          _field(label: 'Company Name', controller: _company, hint: 'demo001'),
                          _field(label: 'UserName', controller: _username, hint: 'UserName'),
                          _field(
                            label: 'Password',
                            controller: _password,
                            hint: 'Enter your password',
                            obscure: _obscure,
                            suffix: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                activeColor: _teal,
                                onChanged: (value) => setState(() => _remember = value ?? true),
                              ),
                              const Text('Remember me'),
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _busy ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: _teal,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _busy
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Log in'),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ask your company admin to reset your password.')),
                                );
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          Row(
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF6B7280))),
                              TextButton(onPressed: _busy ? null : () => context.go('/sign-up'), child: const Text('Create one')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const Text('© 2026 POS360tech. All Rights Reserved.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffix,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _teal, width: 1.4)),
            ),
            validator: (value) => (value == null || value.trim().isEmpty) ? '$label is required' : null,
          ),
        ],
      ),
    );
  }
}

class _PosHero extends StatelessWidget {
  const _PosHero();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(36, 30, 36, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sales, stock,\nand the counter\nmade simple',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 50, height: 1.15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
            ),
            SizedBox(height: 16),
            Text(
              'POS360tech helps shops take sales, track stock, and close the day in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 20),
            ),
            SizedBox(height: 34),
            _PosArt(),
          ],
        ),
      ),
    );
  }
}

class _PosArt extends StatelessWidget {
  const _PosArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 290),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF3FAF8), Color(0xFFE5F4F1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.15)),
      ),
      child: const Center(child: Icon(Icons.point_of_sale_outlined, size: 160, color: Color(0xFF0F766E))),
    );
  }
}
