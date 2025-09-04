import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

import '../controllers/message_controller.dart';

class ImageViewer extends StatelessWidget {
  final String imagePath;
  const ImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final msg = Get.find<MessageController>();
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'image_view_$imagePath',
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => const Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                        size: 96,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                top: 8,
                right: 56,
                child: IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  onPressed: () async {
                    final ok = await msg.saveImageToGallery(imagePath);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(ok
                              ? 'Saved to gallery'
                              : 'Failed to save. Please grant permission.'),
                        ),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () async {
                    try {
                      await Share.shareXFiles([XFile(imagePath)]);
                    } catch (_) {}
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
