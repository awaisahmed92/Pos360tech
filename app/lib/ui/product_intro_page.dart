import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'company_logo.dart';

/// Public product page. Try now opens the login screen.
class ProductIntroPage extends StatelessWidget {
  const ProductIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3F7F6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 800;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 20, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bar(onTryNow: () => context.go('/login')),
                        const SizedBox(height: 56),
                        const Text(
                          'RETAIL CLOUD',
                          style: TextStyle(
                            color: Color(0xFF0F766E),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sales, stock, and cash\non one counter.',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: wide ? 52 : 36,
                            height: 1.08,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(
                          width: 560,
                          child: Text(
                            'Run the shop from the till: products, purchases, stock, parties, and the daily cash book in the same company workspace.',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 17, height: 1.55),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _Cta(label: 'Try now', filled: true, onPressed: () => context.go('/login')),
                            _Cta(label: 'Create an account', filled: false, onPressed: () => context.go('/sign-up')),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _Feature(step: '1', title: 'Sell', body: 'Take a sale at the counter with cash, credit, and the receipt your customer expects.'),
                            _Feature(step: '2', title: 'Stock', body: 'Purchases, transfers, and the godown stay in step with what the till sells.'),
                            _Feature(step: '3', title: 'Cash', body: 'Parties, cheques, and the daily book stay with the same company.'),
                            _Feature(step: '4', title: 'Company', body: 'A new shop is the same client record HR and Accounts already use.'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.onTryNow});

  final VoidCallback onTryNow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CompanyLogo(size: 36),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('POS360tech', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        _Cta(label: 'Try now', filled: true, onPressed: onTryNow),
      ],
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.label, required this.filled, required this.onPressed});

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: filled ? const Color(0xFF0F766E) : Colors.white,
        foregroundColor: filled ? Colors.white : const Color(0xFF0F766E),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: filled ? BorderSide.none : const BorderSide(color: Color(0xFF0F766E)),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.step, required this.title, required this.body});

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8EE)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0x140F766E), shape: BoxShape.circle),
                child: Text(step, style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(body, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
