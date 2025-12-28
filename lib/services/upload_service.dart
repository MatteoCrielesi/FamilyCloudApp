import 'package:family_cloud_app/models/upload_task.dart';

class UploadService {
  const UploadService();

  Future<UploadTask> enqueue({
    required String localPath,
    required String remotePath,
    required int totalBytes,
  }) async {
    throw UnimplementedError();
  }
}
