class UploadTask {
  final String localPath;
  final String remotePath;
  final int totalBytes;
  final int uploadedBytes;

  const UploadTask({
    required this.localPath,
    required this.remotePath,
    required this.totalBytes,
    required this.uploadedBytes,
  });
}
