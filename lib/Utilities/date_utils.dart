/// Date and time formatting utilities for MedTrack application
class AppDateUtils {
  /// Format date as DD/MM/YYYY (e.g. 15/10/2026)
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  /// Format date in human readable format (e.g. Oct 15, 2026)
  static String formatDateReadable(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Calculate exact difference in days between target date and today
  static int daysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  /// Get readable expiry description (e.g., "Expired 3 days ago", "Expires today", "Expires in 5 days")
  static String getExpiryText(DateTime expiryDate) {
    final days = daysUntil(expiryDate);
    if (days < 0) {
      final absDays = days.abs();
      return absDays == 1 ? 'Expired yesterday' : 'Expired $absDays days ago';
    } else if (days == 0) {
      return 'Expires today';
    } else if (days == 1) {
      return 'Expires tomorrow';
    } else {
      return 'Expires in $days days';
    }
  }

  /// Categorize expiry status: 'Expired', 'Expiring Soon', or 'Good'
  static String getExpiryStatus(DateTime expiryDate, {int warningDays = 30}) {
    final days = daysUntil(expiryDate);
    if (days < 0) {
      return 'Expired';
    } else if (days <= warningDays) {
      return 'Expiring Soon';
    } else {
      return 'Good';
    }
  }
}
