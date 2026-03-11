import 'dart:io';
import 'package:dio/dio.dart';

/// Service for uploading images to Cloudinary.
/// Uses unsigned uploads with upload presets for security.
abstract class CloudinaryService {
  /// Uploads an image file to Cloudinary.
  /// Returns the secure URL of the uploaded image.
  Future<String> uploadImage(File imageFile, {String? folder});
}

/// Implementation of CloudinaryService using Dio for HTTP requests.
class CloudinaryServiceImpl implements CloudinaryService {
  final Dio _dio;
  final String _cloudName;
  final String _uploadPreset;

  CloudinaryServiceImpl({
    required String cloudName,
    required String uploadPreset,
    Dio? dio,
  })  : _cloudName = cloudName,
        _uploadPreset = uploadPreset,
        _dio = dio ?? Dio();

  /// Cloudinary upload URL for unsigned uploads.
  String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  @override
  Future<String> uploadImage(File imageFile, {String? folder}) async {
    try {
      // Get the file name
      final fileName = imageFile.path.split('/').last;

      // Create form data for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'upload_preset': _uploadPreset,
        if (folder != null) 'folder': folder,
      });

      // Make the upload request
      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Extract the secure URL from the response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final secureUrl = data['secure_url'] as String?;

        if (secureUrl == null) {
          throw Exception('No secure_url in Cloudinary response');
        }

        return secureUrl;
      } else {
        throw Exception(
          'Cloudinary upload failed with status: ${response.statusCode}',
        );
      }
    } on DioError catch (e) {
      throw Exception('Image upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }
}

/// Factory class for creating CloudinaryService instances.
/// Helps with dependency injection and configuration.
class CloudinaryServiceFactory {
  /// Creates a CloudinaryService from environment configuration.
  ///
  /// Usage:
  /// ```dart
  /// final service = CloudinaryServiceFactory.create(
  ///   cloudName: 'your_cloud_name',
  ///   uploadPreset: 'your_upload_preset',
  /// );
  /// ```
  static CloudinaryService create({
    required String cloudName,
    required String uploadPreset,
  }) {
    return CloudinaryServiceImpl(
      cloudName: cloudName,
      uploadPreset: uploadPreset,
    );
  }
}
