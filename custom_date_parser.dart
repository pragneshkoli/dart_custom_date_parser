import 'package:intl/intl.dart';

class CustomDateParser {
  /// Precompile all formats once (fastest!!)
  static final Map<String, DateFormat> _formatMap = {
    // Slash formats
    'slash': DateFormat('dd/MM/yyyy HH:mm'),
    'slash2': DateFormat('dd/MM/yyyy HH:mm:ss'),
    'slash3': DateFormat('dd/MM/yyyy'),
    'slash4': DateFormat('yyyy/MM/dd HH:mm:ss'),
    'slash5': DateFormat('yyyy/MM/dd HH:mm'),
    'slash6': DateFormat('yyyy/MM/dd'),

    // Dash formats
    'dash': DateFormat('yyyy-MM-dd HH:mm:ss'),
    'dash2': DateFormat('yyyy-MM-dd HH:mm'),
    'dash3': DateFormat('yyyy-MM-dd'),
    'dash4': DateFormat('dd-MM-yyyy HH:mm:ss'),
    'dash5': DateFormat('dd-MM-yyyy HH:mm'),
    'dash6': DateFormat('dd-MM-yyyy'),

    // Text formats
    'text': DateFormat('dd MMM yyyy'),
    'text2': DateFormat('dd MMM yyyy HH:mm'),
    'text3': DateFormat('dd MMM yyyy HH:mm:ss'),
    'text4': DateFormat('MMM dd, yyyy'),
    'text5': DateFormat('MMM dd, yyyy HH:mm'),
    'text6': DateFormat('MMM dd, yyyy HH:mm:ss'),

    // Compact numeric formats
    'compact': DateFormat('yyyyMMdd'),
    'compact2': DateFormat('yyyyMMddHHmmss'),
    'compact3': DateFormat('yyyyMMddHHmm'),

    // RFC format
    'rfc': DateFormat('EEE, dd MMM yyyy HH:mm:ss Z'),
  };

  /// Detect candidate formats based on input pattern
  List<DateFormat> _detectFormats(String s) {
    // Digits only → compact
    if (RegExp(r'^\d+$').hasMatch(s)) {
      return _formatMap.entries
          .where((e) => e.key.contains('compact'))
          .map((e) => e.value)
          .toList();
    }

    // RFC (Mon, ..., Monday,)
    if (RegExp(r'^[A-Za-z]+,').hasMatch(s)) {
      return [_formatMap['rfc']!];
    }

    // Slash formats
    if (s.contains('/')) {
      return _formatMap.entries
          .where((e) => e.key.contains('slash'))
          .map((e) => e.value)
          .toList();
    }

    // Dash formats (numeric only)
    if (s.contains('-') &&
        !RegExp(r'[A-Za-z]').hasMatch(s) &&
        !s.contains(',')) {
      return _formatMap.entries
          .where((e) => e.key.contains('dash'))
          .map((e) => e.value)
          .toList();
    }

    // Text formats (month names)
    if (RegExp(r'[A-Za-z]').hasMatch(s)) {
      return _formatMap.entries
          .where((e) => e.key.contains('text'))
          .map((e) => e.value)
          .toList();
    }

    // Fallback → all formats
    return _formatMap.values.toList();
  }

  /// Core parser
  String tryParseAndFormatDate(String input, String outputFormat) {
    final outFmt = DateFormat(outputFormat);

    // 1. ISO parsing → fastest O(n)
    final iso = DateTime.tryParse(input);
    if (iso != null) return outFmt.format(iso);

    // 2. Select minimized format list
    final candidates = _detectFormats(input);

    // 3. Try selected formats
    for (final fmt in candidates) {
      try {
        return outFmt.format(fmt.parseStrict(input));
      } catch (_) {}
    }

    // 4. Final fallback → try all formats except RFC (unless needed)
    for (final entry in _formatMap.entries) {
      if (entry.key == 'rfc' && !input.contains(',')) continue;
      try {
        return outFmt.format(entry.value.parseStrict(input));
      } catch (_) {}
    }

    return "Invalid date";
  }

  /// Public API
  String formatDate(String date,
      {String outputDateFormat = 'dd/MM/yyyy HH:mm'}) {
    return tryParseAndFormatDate(date, outputDateFormat);
  }
}
