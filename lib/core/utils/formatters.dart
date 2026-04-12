import 'package:intl/intl.dart';

/// Formateadores reutilizables.
class Formatters {
  const Formatters._();

  static final _priceFormat = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 2,
  );

  static String price(double amount) => _priceFormat.format(amount);

  static String date(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  static String time(DateTime time) => DateFormat('HH:mm').format(time);

  static String dateTime(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm').format(dt);
}
