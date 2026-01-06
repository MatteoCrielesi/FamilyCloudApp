import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:family_cloud_app/models/app_settings.dart';
import 'package:family_cloud_app/models/upload_task.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UploadService {
  const UploadService();

  Future<UploadTask> enqueue({
    required String localPath,
    required String remotePath,
    required int totalBytes,
    required AppSettings settings,
  }) async {
    // Check Wi-Fi constraint
    if (settings.wifiOnlyUpload) {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.wifi)) {
        throw Exception('Upload consentito solo sotto rete Wi-Fi');
      }
    }

    String finalPath = localPath;
    int finalBytes = totalBytes;

    // Check Compression constraint (Images only)
    if (settings.compressImages && _isImage(localPath)) {
      try {
        final compressedFile = await _compressImage(localPath);
        if (compressedFile != null) {
          finalPath = compressedFile.path;
          finalBytes = await compressedFile.length();
        }
      } catch (e) {
        // Fallback to original if compression fails
        print('Compression failed: $e');
      }
    }

    // TODO: Actual upload logic here
    // For now, we return a mock task
    return UploadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      localPath: finalPath,
      remotePath: remotePath,
      totalBytes: finalBytes,
      status: UploadTaskStatus.queued,
    );
  }

  bool _isImage(String path) {
    final extensions = ['.jpg', '.jpeg', '.png', '.heic', '.webp'];
    final ext = path.toLowerCase();
    return extensions.any((e) => ext.endsWith(e));
  }

  Future<File?> _compressImage(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      'compressed_${path.basename(sourcePath)}',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 70, // Reasonable quality for "compression"
    );

    return result != null ? File(result.path) : null;
  }
}
