import 'package:permission_handler/permission_handler.dart';

// Request storage permission before accessing files
Future<void> requestPermission() async {
  if (await Permission.storage.request().isGranted) {
    // Permission granted, proceed with accessing files.
  } else {
    // Handle permission denial.
  }
}
