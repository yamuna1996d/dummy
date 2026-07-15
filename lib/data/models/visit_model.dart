import 'package:kincare/domain/entities/visit_document_entity.dart';
import 'package:kincare/domain/entities/visit_entity.dart';

/// Data model for a visit document with JSON serialization.
class VisitDocumentModel extends VisitDocumentEntity {
  const VisitDocumentModel({
    required super.id,
    required super.fileName,
    required super.fileSizeBytes,
  });

  factory VisitDocumentModel.fromJson(Map<String, dynamic> json) {
    return VisitDocumentModel(
      id: json['id']?.toString() ?? '',
      fileName: json['fileName'] as String? ?? '',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
    );
  }

  factory VisitDocumentModel.fromEntity(VisitDocumentEntity entity) {
    return VisitDocumentModel(
      id: entity.id,
      fileName: entity.fileName,
      fileSizeBytes: entity.fileSizeBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'fileName': fileName, 'fileSizeBytes': fileSizeBytes};
  }
}

/// Data model for visit records with JSON serialization.
class VisitModel extends VisitEntity {
  const VisitModel({
    required super.id,
    required super.visitType,
    super.childId,
    super.visitDate,
    super.purpose,
    super.physician,
    super.hospital,
    super.comment,
    super.documents,
  });

  factory VisitModel.fromGraphQL(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id']?.toString() ?? '',
      visitType: json['visitType'] as String? ?? '',
      childId: json['childId'] as String?,
      visitDate: json['visitDate'] != null
          ? DateTime.tryParse(json['visitDate'] as String)
          : null,
      purpose: json['purpose'] as String?,
      physician: json['physician'] as String?,
      hospital: json['hospital'] as String?,
      comment: json['comment'] as String?,
      documents: _documentsFrom(json['documents']),
    );
  }

  factory VisitModel.fromJson(Map<String, dynamic> json) =>
      VisitModel.fromGraphQL(json);

  static List<VisitDocumentEntity> _documentsFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map(
          (e) => VisitDocumentModel.fromJson(
            Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitType': visitType,
      'childId': childId,
      'visitDate': visitDate?.toIso8601String(),
      'purpose': purpose,
      'physician': physician,
      'hospital': hospital,
      'comment': comment,
      'documents': documents
          .map((d) => VisitDocumentModel.fromEntity(d).toJson())
          .toList(),
    };
  }

  factory VisitModel.fromEntity(VisitEntity entity) {
    return VisitModel(
      id: entity.id,
      visitType: entity.visitType,
      childId: entity.childId,
      visitDate: entity.visitDate,
      purpose: entity.purpose,
      physician: entity.physician,
      hospital: entity.hospital,
      comment: entity.comment,
      documents: entity.documents,
    );
  }
}
