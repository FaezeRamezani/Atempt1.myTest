import 'package:intl/intl.dart';

String splitNumber(int number) {
  return NumberFormat.simpleCurrency(decimalDigits: 0, name: '').format(number);
}

int roundPrice(num number) {
  return ((number / 100).round() * 100);
}
