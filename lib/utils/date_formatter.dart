import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      return DateFormat.jm().format(date); // 3:45 PM
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date); // Mon, Tue
    } else if (date.year == now.year) {
      return DateFormat.MMMd().format(date); // Oct 24
    } else {
      return DateFormat.yMMMd().format(date); // Oct 24, 2023
    }
  }

  static String formatDetailed(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  /// Format timestamp showing date and time
  static String formatWithTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && now.day == date.day) {
      return 'Today at ${DateFormat.jm().format(date)}'; // Today at 3:45 PM
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat.jm().format(date)}'; // Yesterday at 3:45 PM
    } else if (difference.inDays < 7) {
      return '${DateFormat.E().format(date)} at ${DateFormat.jm().format(date)}'; // Mon at 3:45 PM
    } else if (date.year == now.year) {
      return '${DateFormat.MMMd().format(date)} at ${DateFormat.jm().format(date)}'; // Oct 24 at 3:45 PM
    } else {
      return '${DateFormat.yMMMd().format(date)} at ${DateFormat.jm().format(date)}'; // Oct 24, 2023 at 3:45 PM
    }
  }

  /// Format timestamp showing full date and time with label
  static String formatTimestampWithLabel(DateTime date,
      {String label = 'Updated'}) {
    return '$label at ${formatWithTime(date)}';
  }

  /// Check if a date was recently updated (within last hour)
  static bool isRecentlyUpdated(DateTime createdAt, DateTime updatedAt) {
    return updatedAt.difference(createdAt).inMinutes > 1 &&
        DateTime.now().difference(updatedAt).inMinutes < 60;
  }
}
