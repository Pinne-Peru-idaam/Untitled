import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'dart:math';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  List<File> videoFiles = [];
  bool isLoading = true;
  int totalSize = 0;
  Map<String, Uint8List?> thumbnails = {};

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => isLoading = true);
    if (await Permission.storage.request().isGranted) {
      try {
        final List<File> files = [];
        int size = 0;
        final List<String> videoPaths = [
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Movies',
          '/storage/emulated/0/Download',
        ];

        for (String path in videoPaths) {
          final directory = Directory(path);
          if (await directory.exists()) {
            await for (var entity in directory.list(recursive: true)) {
              if (entity is File &&
                  (entity.path.endsWith('.mp4') ||
                      entity.path.endsWith('.avi') ||
                      entity.path.endsWith('.mkv') ||
                      entity.path.endsWith('.mov'))) {
                files.add(entity);
                size += await entity.length();
                await _generateThumbnail(entity.path);
              }
            }
          }
        }

        setState(() {
          videoFiles = files;
          totalSize = size;
          isLoading = false;
        });
      } catch (e) {
        _showError('Error loading videos: $e');
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _generateThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 25,
      );
      setState(() {
        thumbnails[videoPath] = thumbnail;
      });
    } catch (e) {
      print('Error generating thumbnail: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  void _showVideoOptions(File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Play'),
            onTap: () {
              Navigator.pop(context);
              OpenFile.open(file.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              Share.share(file.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(file);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(File file) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text(
            'Are you sure you want to delete ${file.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await file.delete();
        _loadVideos();
      } catch (e) {
        _showError('Error deleting video: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        backgroundColor: const Color(0xFF1E2746),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Videos (${_formatSize(totalSize)})',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : videoFiles.isEmpty
                      ? const Center(child: Text('No videos found'))
                      : ListView.builder(
                          itemCount: videoFiles.length,
                          itemBuilder: (context, index) {
                            final file = videoFiles[index];
                            final name = file.path.split('/').last;
                            final thumbnail = thumbnails[file.path];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Container(
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: thumbnail != null
                                      ? Image.memory(
                                          thumbnail,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.video_file,
                                          color: Colors.white),
                                ),
                                title: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: FutureBuilder<FileStat>(
                                  future: file.stat(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text('Loading...');
                                    }
                                    return Text(
                                        _formatSize(snapshot.data!.size));
                                  },
                                ),
                                onTap: () => OpenFile.open(file.path),
                                onLongPress: () => _showVideoOptions(file),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
