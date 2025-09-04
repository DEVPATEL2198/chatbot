import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/media_service.dart';

class MediaController extends GetxController {
  final MediaService _mediaService = MediaService();

  // Image state
  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onClose() {
    _mediaService.dispose();
    super.onClose();
  }

  // Image methods
  Future<File?> selectImage() async {
    print('MediaController: selectImage called'); // Debug log
    final image = await _mediaService.showImageSourceDialog();
    print('MediaController: Image from service: ${image?.path}'); // Debug log
    if (image != null) {
      selectedImage.value = image;
      print(
          'MediaController: selectedImage.value set to: ${selectedImage.value?.path}'); // Debug log
    } else {
      print('MediaController: No image returned from service'); // Debug log
    }
    return image;
  }

  void clearSelectedImage() {
    print(
        'MediaController: clearSelectedImage called, current image: ${selectedImage.value?.path}'); // Debug log
    selectedImage.value = null;
    print(
        'MediaController: selectedImage cleared, now: ${selectedImage.value}'); // Debug log
  }
}
