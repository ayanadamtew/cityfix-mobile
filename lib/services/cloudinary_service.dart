// lib/services/cloudinary_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudinaryService {
  final Dio _dio = Dio();
  
  // Create an unsigned upload preset in Cloudinary:
  // 1. Settings -> Upload -> Add upload preset
  // 2. Set 'Signing Mode' to 'Unsigned'
  // 3. Name it 'cityfix_uploads' (or similar)
  static const String cloudName = 'drg6o0xjw'; // Replace with a demo/placeholder if needed, or actual User's Cloudinary
  static const String uploadPreset = 'cityfix_preset';

  Future<String?> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      String fileName = filePath.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'upload_preset': uploadPreset,
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['secure_url']; // The uploaded image URL
      }
      return null;
    } catch (e) {
      throw Exception('Cloudinary upload failed: $e');
    }
  }
}

final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());
