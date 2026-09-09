/// File metadata returned by POST /files/upload.
class UploadedFile {
  final String id;
  final String name;
  final String? mimeType;
  final int size;

  const UploadedFile({
    required this.id,
    required this.name,
    this.mimeType,
    required this.size,
  });
}
