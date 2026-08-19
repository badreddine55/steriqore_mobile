import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dmyFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dmyHmFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '--/--/----';
    return _dmyFormat.format(dateTime);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--/--/---- --:--';
    return _dmyHmFormat.format(dateTime);
  }

  static String formatIso(DateTime dateTime) {
    return _isoFormat.format(dateTime.toUtc());
  }

  static String formatRelative(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return 'Today at ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _dmyFormat.format(dateTime);
    }
  }

  static int remainingDays(DateTime expirationDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
    return expiry.difference(today).inDays;
  }
}
