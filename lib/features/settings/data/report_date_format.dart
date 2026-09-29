class ReportDateFormat {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String date(DateTime value, String format) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return switch (format) {
      'YYYY-MM-DD' => '${value.year}-$month-$day',
      'MM/DD/YYYY' => '$month/$day/${value.year}',
      _ => '$day ${_months[value.month - 1]} ${value.year}',
    };
  }

  static String time(DateTime value, String format) {
    final minute = value.minute.toString().padLeft(2, '0');
    if (format == '24-hour') return '${value.hour.toString().padLeft(2, '0')}:$minute';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
  }
}
