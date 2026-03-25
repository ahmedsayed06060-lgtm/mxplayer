import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static String fileSize(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size >= 100 || unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  static String duration(Duration? duration) {
    if (duration == null) {
      return '--:--';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '${duration.inMinutes}:$seconds';
  }

  static String resolution(int? width, int? height) {
    if (width == null || height == null) {
      return 'Unknown';
    }
    return '${width}x$height';
  }

  static String relativeDate(int epochMs) {
    return DateFormat.yMMMd().add_jm().format(
      DateTime.fromMillisecondsSinceEpoch(epochMs),
    );
  }
}
