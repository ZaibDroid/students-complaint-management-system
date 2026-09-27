import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Utilities for picking and handling compressed images for complaint evidence
class ImageCompressor {
  ImageCompressor._();

  static final ImagePicker _picker = ImagePicker();

  /// Pick single image from gallery or camera
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75, // compresses automatically
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultiImage({int maxImages = 4}) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75,
        limit: maxImages,
      );

      return pickedFiles.take(maxImages).map((x) => File(x.path)).toList();
    } catch (e) {
      return [];
    }
  }
}
