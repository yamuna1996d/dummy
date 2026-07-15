import 'package:get/get.dart';
import 'package:kincare/domain/entities/visit_document_entity.dart';

/// Upload lifecycle of a [VisitDocumentItem].
enum DocumentUploadStatus { uploading, uploaded, failed }

/// A document attached to the in-progress visit form.
///
/// This is a presentation-only wrapper around [VisitDocumentEntity] — it
/// carries the reactive upload progress/status that only exists while the
/// form is open (the persisted entity itself has no notion of "in
/// progress"). Only documents whose [status] is `uploaded` are converted
/// back to [VisitDocumentEntity] when the visit is saved.
class VisitDocumentItem {
  VisitDocumentItem({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
    required this.filePath,
    DocumentUploadStatus status = DocumentUploadStatus.uploading,
  }) : status = Rx<DocumentUploadStatus>(status),
       progress = 0.0.obs,
       secondsRemaining = 0.obs;

  final String id;
  final String fileName;
  final int fileSizeBytes;
  final String filePath;
  final Rx<DocumentUploadStatus> status;
  final RxDouble progress;
  final RxInt secondsRemaining;

  int get fileSizeMb => (fileSizeBytes / (1024 * 1024)).ceil();

  VisitDocumentEntity toEntity() =>
      VisitDocumentEntity(id: id, fileName: fileName, fileSizeBytes: fileSizeBytes);
}
