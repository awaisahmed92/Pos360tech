class Fixed {
  static double n(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String qty(dynamic value) => n(value).toStringAsFixed(3);

  static String money(dynamic value) => n(value).toStringAsFixed(2);

  static String cost(dynamic value) => n(value).toStringAsFixed(4);

  static String rs(dynamic value, [String symbol = 'Rs']) {
    final amount = n(value);
    final sign = amount < 0 ? '-' : '';
    return '$sign$symbol ${amount.abs().toStringAsFixed(2)}';
  }
}
