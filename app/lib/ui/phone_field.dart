import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CountryFlag extends StatelessWidget {
  const CountryFlag(this.code, {super.key, this.width = 24});

  final String code;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SvgPicture.asset(
        'assets/flags/${code.toLowerCase()}.svg',
        width: width,
        height: width * 3 / 4,
        fit: BoxFit.cover,
      ),
    );
  }
}

class PhoneCountry {
  const PhoneCountry(this.code, this.name, this.dial);

  final String code;
  final String name;
  final String dial;

  String get flag {
    final upper = code.toUpperCase();
    return String.fromCharCodes(upper.codeUnits.map((c) => 0x1F1E6 + (c - 0x41)));
  }
}

const phoneCountries = <PhoneCountry>[
  PhoneCountry('AE', 'United Arab Emirates', '+971'),
  PhoneCountry('AF', 'Afghanistan', '+93'),
  PhoneCountry('AR', 'Argentina', '+54'),
  PhoneCountry('AT', 'Austria', '+43'),
  PhoneCountry('AU', 'Australia', '+61'),
  PhoneCountry('BD', 'Bangladesh', '+880'),
  PhoneCountry('BE', 'Belgium', '+32'),
  PhoneCountry('BH', 'Bahrain', '+973'),
  PhoneCountry('BR', 'Brazil', '+55'),
  PhoneCountry('CA', 'Canada', '+1'),
  PhoneCountry('CH', 'Switzerland', '+41'),
  PhoneCountry('CN', 'China', '+86'),
  PhoneCountry('DE', 'Germany', '+49'),
  PhoneCountry('DK', 'Denmark', '+45'),
  PhoneCountry('EG', 'Egypt', '+20'),
  PhoneCountry('ES', 'Spain', '+34'),
  PhoneCountry('FR', 'France', '+33'),
  PhoneCountry('GB', 'United Kingdom', '+44'),
  PhoneCountry('GR', 'Greece', '+30'),
  PhoneCountry('HK', 'Hong Kong', '+852'),
  PhoneCountry('ID', 'Indonesia', '+62'),
  PhoneCountry('IE', 'Ireland', '+353'),
  PhoneCountry('IN', 'India', '+91'),
  PhoneCountry('IT', 'Italy', '+39'),
  PhoneCountry('JP', 'Japan', '+81'),
  PhoneCountry('KE', 'Kenya', '+254'),
  PhoneCountry('KR', 'South Korea', '+82'),
  PhoneCountry('KW', 'Kuwait', '+965'),
  PhoneCountry('LK', 'Sri Lanka', '+94'),
  PhoneCountry('MY', 'Malaysia', '+60'),
  PhoneCountry('MX', 'Mexico', '+52'),
  PhoneCountry('NG', 'Nigeria', '+234'),
  PhoneCountry('NL', 'Netherlands', '+31'),
  PhoneCountry('NO', 'Norway', '+47'),
  PhoneCountry('NP', 'Nepal', '+977'),
  PhoneCountry('NZ', 'New Zealand', '+64'),
  PhoneCountry('OM', 'Oman', '+968'),
  PhoneCountry('PH', 'Philippines', '+63'),
  PhoneCountry('PK', 'Pakistan', '+92'),
  PhoneCountry('PL', 'Poland', '+48'),
  PhoneCountry('QA', 'Qatar', '+974'),
  PhoneCountry('SA', 'Saudi Arabia', '+966'),
  PhoneCountry('SE', 'Sweden', '+46'),
  PhoneCountry('SG', 'Singapore', '+65'),
  PhoneCountry('TH', 'Thailand', '+66'),
  PhoneCountry('TR', 'Turkey', '+90'),
  PhoneCountry('US', 'United States', '+1'),
  PhoneCountry('ZA', 'South Africa', '+27'),
];

PhoneCountry phoneCountryByName(String name) {
  final key = name.trim().toLowerCase();
  for (final country in phoneCountries) {
    if (country.name.toLowerCase() == key) return country;
  }
  return phoneCountries.firstWhere((country) => country.code == 'PK');
}

PhoneCountry phoneCountryByCode(String code) {
  for (final country in phoneCountries) {
    if (country.code == code) return country;
  }
  return phoneCountries.firstWhere((country) => country.code == 'PK');
}

String composePhone(String countryCode, String raw) {
  final dial = phoneCountryByCode(countryCode).dial;
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  final codeDigits = dial.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith(codeDigits)) digits = digits.substring(codeDigits.length);
  digits = digits.replaceFirst(RegExp(r'^0+'), '');
  if (digits.isEmpty) return '';
  return '$dial $digits';
}

class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCode,
  });

  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<String> onCountryCode;

  static const _border = Color(0xFFD5DBE5);
  static const _ink = Color(0xFF16233A);

  @override
  Widget build(BuildContext context) {
    final selected = phoneCountryByCode(countryCode);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mobile Number', style: TextStyle(fontSize: 13, color: Color(0xFF6B7A90))),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _openPicker(context),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryFlag(selected.code),
                        const SizedBox(width: 6),
                        Text(selected.dial, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _ink)),
                        const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF6B7A90)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 1, height: 28, child: ColoredBox(color: _border)),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 14.5, color: _ink),
                    decoration: const InputDecoration(
                      hintText: '202 555 0123',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => _DialCodePicker(selected: countryCode),
    );
    if (picked != null && picked != countryCode) onCountryCode(picked);
  }
}

class _DialCodePicker extends StatefulWidget {
  const _DialCodePicker({required this.selected});

  final String selected;

  @override
  State<_DialCodePicker> createState() => _DialCodePickerState();
}

class _DialCodePickerState extends State<_DialCodePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final rows = phoneCountries.where((country) {
      if (query.isEmpty) return true;
      return country.name.toLowerCase().contains(query) ||
          country.dial.contains(query) ||
          country.code.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search country or code',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final country = rows[index];
                  return ListTile(
                    leading: CountryFlag(country.code, width: 28),
                    title: Text(country.name),
                    trailing: Text(country.dial, style: const TextStyle(fontWeight: FontWeight.w700)),
                    selected: country.code == widget.selected,
                    onTap: () => Navigator.pop(context, country.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
