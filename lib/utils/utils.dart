import 'package:intl/intl.dart';

class Utils {

  String formatTimestamp(String rawTimestamp) {
      try {
        final dateTime = DateTime.parse(rawTimestamp);
        return DateFormat('MMM d, yyyy – h:mm a').format(dateTime);
      } catch (_) {
        return rawTimestamp;
      }
    }

}