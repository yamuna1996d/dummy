import 'package:kincare/domain/entities/visit_document_entity.dart';

/// Domain entity representing a visit record (e.g. a medical appointment).
class VisitEntity {
  const VisitEntity({
    required this.id,
    required this.visitType,
    this.childId,
    this.visitDate,
    this.purpose,
    this.physician,
    this.hospital,
    this.comment,
    this.documents = const [],
  });

  final String id;
  final String visitType;
  final String? childId;
  final DateTime? visitDate;
  final String? purpose;
  final String? physician;
  final String? hospital;
  final String? comment;
  final List<VisitDocumentEntity> documents;
}
