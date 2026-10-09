import 'package:flutter_test/flutter_test.dart';
import 'package:night_life/utilities/name_formatter.dart';

void main() {
  test('capitalizes the first letter of each word', () {
    expect(NameFormatter.capitalizeWords('sri'), 'Sri');
    expect(NameFormatter.capitalizeWords('sri harsha'), 'Sri Harsha');
  });

  test('trims and collapses spaces', () {
    expect(NameFormatter.capitalizeWords('  john   doe '), 'John Doe');
    expect(NameFormatter.capitalizeWords(''), '');
  });

  test('leaves the rest of each word as typed', () {
    expect(NameFormatter.capitalizeWords('mcDonald'), 'McDonald');
    expect(NameFormatter.capitalizeWords('JOHN'), 'JOHN');
  });
}
