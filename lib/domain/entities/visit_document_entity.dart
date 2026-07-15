/// Domain entity representing a document attached to a visit.
class VisitDocumentEntity {
  const VisitDocumentEntity({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
  });

  final String id;
  final String fileName;
  final int fileSizeBytes;
}
