import 'dart:math';
import 'package:untitled/pages/categories/storage/models/app_icons.dart';

class FileUtils {
  static String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  static String getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'apk':
        return AppIcons.apk;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'wmv':
        return AppIcons.video;
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
      case 'wma':
        return AppIcons.audio;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return AppIcons.image;
      default:
        return AppIcons.file;
    }
  }
}