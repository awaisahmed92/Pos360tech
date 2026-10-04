import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app.dart';
import '../core/api_client.dart';
import 'company_logo.dart';
import 'phone_field.dart';

/// Separate new-company form. The client row is written to the shared master database.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  static const _brand = Color(0xFF3B82F6);
  static const _ink = Color(0xFF16233A);

  static const _countries = [
    'Pakistan',
    'United Arab Emirates',
    'Saudi Arabia',
    'Qatar',
    'Oman',
    'Kuwait',
    'Bahrain',
    'United Kingdom',
    'United States',
    'Canada',
    'Australia',
  ];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _code = TextEditingController();
  final _designation = TextEditingController();
  final _industry = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _captcha = TextEditingController();

  String _country = 'Pakistan';
  String? _captchaToken;
  Uint8List? _captchaBytes;
  String _phoneCountry = 'US';
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  bool _codeTouched = false;
  bool _codeOk = false;
  String? _codeHint;
  String? _error;
  Map<String, dynamic>? _done;
  Timer? _codeDebounce;

  @override
  void initState() {
    super.initState();
    _company.addListener(_suggestCode);
    _code.addListener(_onCodeChanged);
    _loadCaptcha();
  }

  @override
  void dispose() {
    _codeDebounce?.cancel();
    for (final controller in [_name, _company, _code, _designation, _industry, _email, _phone, _password, _confirm, _captcha]) {
      controller.dispose();
    }
    super.dispose();
  }

  static String slug(String raw) {
    final cleaned = raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return cleaned.length > 40 ? cleaned.substring(0, 40) : cleaned;
  }

  void _suggestCode() {
    if (_codeTouched) return;
    final next = slug(_company.text);
    if (next == _code.text) return;
    _code.value = TextEditingValue(text: next, selection: TextSelection.collapsed(offset: next.length));
  }

  void _onCodeChanged() {
    _codeDebounce?.cancel();
    setState(() {
      _codeHint = null;
      _codeOk = false;
    });
    final code = _code.text.trim();
    if (code.length < 3) return;
    _codeDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final data = await ref.read(storeProvider).codeAvailability(code, companyName: _company.text);
        if (!mounted || _code.text.trim() != code) return;
        setState(() {
          _codeOk = data['available'] == true;
          _codeHint = _codeOk ? null : data['message']?.toString();
        });
      } catch (_) {}
    });
  }

  Future<void> _loadCaptcha() async {
    try {
      final data = await ref.read(storeProvider).captcha();
      final image = data['image']?.toString() ?? '';
      final comma = image.indexOf(',');
      final bytes = comma >= 0 ? base64Decode(image.substring(comma + 1)) : null;
      if (!mounted) return;
      setState(() {
        _captchaToken = data['token']?.toString();
        _captchaBytes = bytes;
        _captcha.clear();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = apiError(error));
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    final token = _captchaToken;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'The verification code is still loading. Please wait.');
      return;
    }
    setState(() => _busy = true);
    try {
      final data = await ref.read(storeProvider).signup({
        'name': _name.text.trim(),
        'company_name': _company.text.trim(),
        'company_code': slug(_code.text),
        'designation': _designation.text.trim(),
        'industry': _industry.text.trim(),
        'country': _country,
        'email': _email.text.trim(),
        'phone': composePhone(_phoneCountry, _phone.text),
        'password': _password.text,
        'captcha_token': token,
        'captcha_answer': _captcha.text.trim(),
      });
      if (!mounted) return;
      setState(() => _done = data);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = apiError(error));
      await _loadCaptcha();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              const Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.only(left: 72),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Let's get\nsigned up!",
                      style: TextStyle(fontSize: 48, height: 1.12, fontWeight: FontWeight.w700, color: _ink),
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(wide ? 40 : 18, 28, wide ? 40 : 18, 48),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 76),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Material(
                            color: Colors.white,
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                              child: _done == null ? _form() : _success(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: CompanyLogo(size: 56)),
          const SizedBox(height: 10),
          const Center(child: Text('POS360', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink))),
          const SizedBox(height: 4),
          const Center(child: Text('Create your POS360 account', style: TextStyle(fontSize: 13.5, color: Color(0xFF6B7A90)))),
          const SizedBox(height: 22),
          _input(_name, 'UserName *', empty: 'UserName is required'),
          _input(_company, 'Company Name *', empty: 'Company name is required'),
          _input(
            _code,
            'Company Code *',
            helper: _codeHint ?? (_codeOk ? 'Available — this is what you type at login.' : 'Lowercase letters and digits. You sign in with this code.'),
            helperError: _codeHint != null,
            onTap: () => _codeTouched = true,
            validate: (value) {
              if (slug(value ?? '').length < 3) return 'At least 3 letters or digits';
              if (_codeHint != null) return _codeHint;
              return null;
            },
          ),
          _input(_designation, 'Designation *', empty: 'Designation is required'),
          _input(_industry, 'Industry *', empty: 'Industry is required'),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: _decoration('Select your country *'),
              items: [for (final country in _countries) DropdownMenuItem(value: country, child: Text(country))],
              onChanged: (value) {
                final name = value ?? 'Pakistan';
                setState(() {
                  _country = name;
                  _phoneCountry = phoneCountryByName(name).code;
                });
              },
            ),
          ),
          _input(_email, 'Work Email *', keyboard: TextInputType.emailAddress, validate: (value) {
            final text = (value ?? '').trim();
            if (text.isEmpty) return 'Email is required';
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) return 'Enter a valid email address';
            return null;
          }),
          PhoneField(
            controller: _phone,
            countryCode: _phoneCountry,
            onCountryCode: (code) => setState(() => _phoneCountry = code),
          ),
          _input(_password, 'Password *', obscure: _obscure, suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          ), validate: (value) => (value ?? '').length < 6 ? 'Use at least 6 characters' : null),
          _input(_confirm, 'Confirm Password *', obscure: _obscureConfirm, suffix: IconButton(
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          ), validate: (value) => value != _password.text ? 'Passwords do not match' : null),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 168,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD5DBE5)),
                  ),
                  child: _captchaBytes == null
                      ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                      : Image.memory(_captchaBytes!, fit: BoxFit.cover, gaplessPlayback: true),
                ),
                IconButton(
                  tooltip: 'New code',
                  onPressed: _busy ? null : _loadCaptcha,
                  icon: const Icon(Icons.refresh, color: _brand),
                ),
              ],
            ),
          ),
          _input(
            _captcha,
            'Verification code *',
            empty: 'Type the characters shown above',
            validate: (value) => (value ?? '').trim().length < 4 ? 'Type the characters shown above' : null,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13)),
            ),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: _brand, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                  : const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : () => context.go('/login'),
            child: const Text('Already have an account? Sign in'),
          ),
        ],
      ),
    );
  }

  Widget _success() {
    final done = _done!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF2E9E5B), size: 56),
        const SizedBox(height: 16),
        Text('${done['company_name'] ?? 'Your company'} is ready', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 8),
        const Text('Keep these details — you need them to sign in.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7A90))),
        const SizedBox(height: 20),
        _summary('Company Name', '${done['organization'] ?? ''}'),
        _summary('UserName', _name.text.trim()),
        _summary('Password', 'The password you just chose'),
        const SizedBox(height: 18),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: () => context.go('/login'),
            style: FilledButton.styleFrom(backgroundColor: _brand),
            child: const Text('Go to Sign In', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _summary(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Color(0xFF6B7A90), fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink))),
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    String? empty,
    String? helper,
    bool helperError = false,
    bool requiredField = true,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
    VoidCallback? onTap,
    String? Function(String?)? validate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        onTap: onTap,
        decoration: _decoration(label).copyWith(
          suffixIcon: suffix,
          helperText: helper,
          helperStyle: TextStyle(
            color: helperError
                ? const Color(0xFFC0392B)
                : (helper != null && helper.startsWith('Available') ? const Color(0xFF2E9E5B) : const Color(0xFF6B7A90)),
            fontSize: 12,
          ),
        ),
        validator: validate ?? (requiredField ? (value) => (value ?? '').trim().isEmpty ? empty : null : null),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
