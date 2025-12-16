import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

// Cross-platform file helper
class FileHelper {
  // Extract filename from path (works on all platforms)
  static String extractFileName(String path) {
    if (kIsWeb) {
      // On web, just split by / or \
      return path.split('/').last.split('\\').last;
    } else {
      // On mobile/desktop, use Platform.pathSeparator
      return path.split(io.Platform.pathSeparator).last;
    }
  }
}

