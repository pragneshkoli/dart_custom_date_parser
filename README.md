# custom_date_parser.dart

**Overview**
- **Purpose:**: A lightweight Dart class (`CustomDateParser`) that robustly parses many common date string formats and formats them to a requested output pattern.
- **Intended for:**: Flutter and Dart apps that receive date/time strings in mixed formats (APIs, logs, CSV, user input) and need a single, defensive way to normalize them.

**Features**
- **Precompiled formats:**: Uses a map of `DateFormat` instances to avoid re-creating formatters on each call (faster and less GC pressure).
- **Heuristic detection:**: Chooses a small set of candidate formats based on the input (slashes, dashes, month names, RFC, compact numeric, or ISO) to minimize parsing attempts.
- **ISO-first fast path:**: Tries `DateTime.tryParse` first for native ISO strings (fastest).
- **Fail-safe behavior:**: Attempts a small set of likely formats then falls back to the full set, returning a readable `"Invalid date"` string if parsing fails rather than throwing.

**Why use this**
- **Reduce runtime failures:**: By trying multiple formats safely and returning a fallback value, it prevents uncaught parse exceptions from crashing the app.
- **Reduce code duplication:**: Centralizes parsing logic instead of scattering custom parsing code across the codebase.
- **Performance-minded:**: The detection stage reduces the number of `DateFormat.parseStrict` calls for common inputs, improving performance when parsing many strings.

**Usage**
- **Add dependency:**: This class depends on the `intl` package. Add it to your project with:

```bash
flutter pub add intl
```

- **Import & call:**: Use the `formatDate` API to parse an incoming date string and format it to the shape you need.

**API**
- **Class:**: `CustomDateParser` (file: `custom_date_parser.dart`)
- **Method:**: `String formatDate(String date, {String outputDateFormat = 'dd/MM/yyyy HH:mm'})`
	- **Returns:**: Formatted date string on success, or the string `"Invalid date"` when parsing cannot succeed.
	- **Parameter:**: `outputDateFormat` uses `DateFormat` patterns (see `intl` package docs).

**Examples**

- Plain Dart example:

```dart
import 'custom_date_parser.dart';

void main() {
	final p = CustomDateParser();

	final inputs = [
		'2025-11-21 13:45:00', // dash (ISO-like)
		'21/11/2025 13:45',    // slash
		'Nov 21, 2025 13:45',  // text month
		'20251121134500',      // compact numeric
		'Fri, 21 Nov 2025 13:45:00 +0000', // RFC
	];

	for (final s in inputs) {
		final out = p.formatDate(s, outputDateFormat: 'dd/MM/yyyy HH:mm');
		print('$s  ->  $out');
	}
}
```

- Flutter example (widget):

```dart
import 'package:flutter/material.dart';
import 'custom_date_parser.dart';

class DateDisplay extends StatelessWidget {
	final String rawDate;
	const DateDisplay({super.key, required this.rawDate});

	@override
	Widget build(BuildContext context) {
		final formatted = CustomDateParser().formatDate(rawDate,
				outputDateFormat: 'dd MMM yyyy, HH:mm');
		return Text(formatted);
	}
}
```

**Behavior & edge cases**
- **ISO strings:**: `DateTime.tryParse` is used first — fastest path for standard ISO input.
- **format detection:**: If the string contains `/` the parser prefers slash-based patterns; if it contains `-` (and no letters/commas) it prefers dash-based numeric patterns; if letters are present it prefers text-based patterns; if the string is digits-only it treats it as compact numeric; if it starts with an alphabetical weekday it treats it as RFC.
- **ParseStrict usage:**: The code uses `parseStrict` for attempted parses; these throw on mismatches but are caught internally so callers get a safe fallback instead of an exception.
- **Return value on failure:**: The function returns `"Invalid date"` rather than throwing — you can update this behavior to throw or return `null`/`Either` if you prefer explicit error handling.

**Performance notes**
- **Precompiled `DateFormat` instances:**: Re-using `DateFormat` instances stored in a static map reduces object churn and improves throughput when parsing many dates.
- **Heuristic minimization:**: The `_detectFormats` step minimizes the number of `parseStrict` attempts, making typical inputs parse faster than trying every possible format.

**Suggestions / improvements**
- **Return a typed result:**: Consider returning `DateTime?` or a `Result/Either` type to let callers handle failures more explicitly.
- **Localization:**: If your app needs localized month names, ensure you initialize `intl` locales as needed and add localized `DateFormat` patterns.
- **Custom formats:**: You can extend `_formatMap` with additional formats used by your backend or legacy data.

**Contributing / Notes**
- **File:**: `custom_date_parser.dart` — drop into your `lib/` folder (or import directly).
- **Testing:**: Add unit tests with representative inputs (ISO, slash, dash, text, compact, RFC) to validate behavior before relying on it in production.

If you'd like, I can also:
- add unit tests that cover the common formats;
- refactor the API to return `DateTime?` instead of a string;
- or add a small Flutter demo showing the parser handling different incoming formats.
