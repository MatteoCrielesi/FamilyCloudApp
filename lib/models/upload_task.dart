enum UploadTaskStatus { queued, uploading, completed, failed, canceled }

class UploadTask {
  const UploadTask({
    required this.id,
    required this.localPath,
    required this.remotePath,
    required this.totalBytes,
    this.sentBytes = 0,
    this.status = UploadTaskStatus.queued,
    this.failureMessage,
  });

  final String id;
  final String localPath;
  final String remotePath;
  final int totalBytes;
  final int sentBytes;
  final UploadTaskStatus status;
  final String? failureMessage;

  double get progress => totalBytes == 0 ? 0 : sentBytes / totalBytes;
}
