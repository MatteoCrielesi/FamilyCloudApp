class FileItem {
  const FileItem({
    required this.path,
    required this.name,
    this.sizeBytes,
    this.lastModifiedUtc,
  });

  final String path;
  final String name;
  final int? sizeBytes;
  final DateTime? lastModifiedUtc;
}
