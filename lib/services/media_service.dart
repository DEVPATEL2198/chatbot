import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _player = AudioPlayer();

  // Image capture and selection
  Future<File?> captureImage() async {
    try {
      print('MediaService: captureImage called'); // Debug log
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      print(
          'MediaService: Camera permission status: $cameraStatus'); // Debug log
      if (!cameraStatus.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Camera permission is required to take photos',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      print('MediaService: Camera image result: ${image?.path}'); // Debug log

      if (image != null) {
        final file = File(image.path);
        print('MediaService: File exists: ${await file.exists()}'); // Debug log
        return file;
      }
      return null;
    } catch (e) {
      print('MediaService: captureImage error: $e'); // Debug log
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<bool> _ensureGalleryPermission() async {
    try {
      if (Platform.isIOS) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) return true;
        if (photosStatus.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Please enable Photos permission in Settings',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            mainButton: TextButton(
              onPressed: openAppSettings,
              child: const Text('Open Settings',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        } else {
          Get.snackbar(
            'Permission Denied',
            'Photos permission is required to access your library',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return false;
      }

      // Android
      // Try Android 13+ specific media permission first (mapped as photos in permission_handler)
      var granted = false;
      final imagesStatus = await Permission.photos.request();
      if (imagesStatus.isGranted) granted = true;

      // Fallback for Android 12 and below
      if (!granted) {
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) granted = true;
        if (storageStatus.isPermanentlyDenied ||
            imagesStatus.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Please enable gallery permissions in Settings',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            mainButton: TextButton(
              onPressed: openAppSettings,
              child: const Text('Open Settings',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        } else if (!granted) {
          Get.snackbar(
            'Permission Denied',
            'Gallery permission is required to pick images',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }

      return granted;
    } catch (e) {
      print('Error requesting gallery permission: $e');
      return false;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      print('MediaService: pickImageFromGallery called'); // Debug log

      final ok = await _ensureGalleryPermission();
      print('MediaService: gallery permission granted: $ok');
      if (!ok) return null;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      print('MediaService: Gallery image result: ${image?.path}'); // Debug log

      if (image != null) {
        final file = File(image.path);
        print('MediaService: File exists: ${await file.exists()}'); // Debug log
        return file;
      }
      return null;
    } catch (e) {
      print('MediaService: pickImageFromGallery error: $e'); // Debug log
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Camera-only image capture (gallery removed)
  Future<File?> showImageSourceDialog() async {
    print('MediaService: camera-only flow - capturing image');
    return await captureImage();
  }

  // Audio playback
  Future<void> playAudio(String filePath) async {
    try {
      await _player.play(DeviceFileSource(filePath));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to play audio: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> stopAudio() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      await _player.setSource(DeviceFileSource(filePath));
      return await _player.getDuration();
    } catch (e) {
      print('Error getting audio duration: $e');
      return null;
    }
  }

  // Convert file to base64 for API calls
  Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return bytes.toString();
    } catch (e) {
      throw Exception('Failed to convert file to base64: $e');
    }
  }

  // Cleanup
  void dispose() {
    _player.dispose();
  }
}
