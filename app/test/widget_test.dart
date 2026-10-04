import 'package:flutter_test/flutter_test.dart';
import 'package:pos360tech/core/l10n.dart';
import 'package:pos360tech/core/money.dart';

void main() {
  test('english and urdu labels and money formatting', () {
    expect(const L10n('en').t('ledger'), 'Inventory event ledger');
    expect(const L10n('ur').isRtl, isTrue);
    expect(const L10n('ur').t('stock'), 'اسٹاک');
    expect(Fixed.rs(-12.5), '-Rs 12.50');
  });
}
