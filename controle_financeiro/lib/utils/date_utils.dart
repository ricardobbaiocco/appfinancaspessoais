import 'package:intl/intl.dart';

class AppDateUtils {
  static DateTime get currentLocalTime {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
  }

  static String formatToLocal(DateTime date) {
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }
}