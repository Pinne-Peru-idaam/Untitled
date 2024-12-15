import 'package:flutter/material.dart';
import 'dart:io';
import '../models/app_icons.dart';
import '../utils/file_utils.dart';

class FileGridItem extends StatelessWidget {
  final FileSystemEntity entity;
  final Function onTap;
  final Function onLongPress;

  const FileGridItem({
    super.key,
    required this.entity,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final name = entity.path.split('/').last;
    final isDirectory = entity is Directory;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onTap(),
        onLongPress: () => onLongPress(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isDirectory
                  ? Image.asset(
                      AppIcons.folder,
                      width: 60,
                      height: 60,
                      color: Colors.amber,
                    )
                  : Image.asset(
                      FileUtils.getFileIcon(name),
                      width: 40,
                      height: 40,
                    ),
              const SizedBox(height: 10),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<FileStat>(
                future: entity.stat(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('Loading...',
                        style: TextStyle(fontSize: 10));
                  }
                  final stat = snapshot.data!;
                  if (isDirectory) {
                    return Text(
                      'Modified: ${stat.modified}',
                      style: const TextStyle(fontSize: 10),
                    );
                  } else {
                    return Text(
                      FileUtils.formatSize(stat.size),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
