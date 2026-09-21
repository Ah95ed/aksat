import 'package:aksat/core/utils/parsers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsers - toNum', () {
    test('handles null and empty', () {
      expect(toNum(null), 0.0);
      expect(toNum(''), 0.0);
      expect(toNum('abc'), 0.0);
    });

    test('handles numeric types', () {
      expect(toNum(10), 10.0);
      expect(toNum(12.5), 12.5);
    });

    test('handles numeric strings with decimals and spaces', () {
      expect(toNum('25000'), 25000.0);
      expect(toNum('  120.75  '), 120.75);
      expect(toNum('-45.5'), -45.5);
    });
  });

  group('parsers - toInt', () {
    test('handles null and invalid strings', () {
      expect(toInt(null), 0);
      expect(toInt(''), 0);
      expect(toInt('invalid'), 0);
    });

    test('handles integers and doubles', () {
      expect(toInt(5), 5);
      expect(toInt(5.9), 5);
      expect(toInt('42'), 42);
    });
  });

  group('parsers - toId', () {
    test('parses positive integers', () {
      expect(toId(12), 12);
      expect(toId('456'), 456);
    });

    test('returns 0 for negative numbers or invalid input', () {
      expect(toId(-10), 0);
      expect(toId('-5'), 0);
      expect(toId(null), 0);
      expect(toId('abc'), 0);
    });
  });

  group('parsers - toStr', () {
    test('converts values to string or empty', () {
      expect(toStr(null), '');
      expect(toStr(123), '123');
      expect(toStr('hello'), 'hello');
      expect(toStr(true), 'true');
    });
  });

  group('parsers - toBool', () {
    test('parses booleans correctly', () {
      expect(toBool(true), isTrue);
      expect(toBool(false), isFalse);
      expect(toBool(null), isFalse);
    });

    test('parses truthy strings and numbers', () {
      expect(toBool(1), isTrue);
      expect(toBool(0), isFalse);
      expect(toBool('true'), isTrue);
      expect(toBool('TRUE'), isTrue);
      expect(toBool('1'), isTrue);
      expect(toBool('yes'), isTrue);
      expect(toBool('0'), isFalse);
      expect(toBool('false'), isFalse);
      expect(toBool('no'), isFalse);
    });
  });
}
