import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/app/constants/app_strings.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/entities/visit_entity.dart';
import 'package:kincare/domain/usecases/create_visit_usecase.dart';
import 'package:kincare/domain/usecases/delete_visit_usecase.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:kincare/domain/usecases/get_visit_details_usecase.dart';
import 'package:kincare/domain/usecases/get_visits_usecase.dart';
import 'package:kincare/domain/usecases/update_visit_usecase.dart';
import 'package:kincare/presentation/controllers/visit_document_item.dart';

/// Controller for visit management state and actions, including the
/// document upload workflow (simulated progress + network-failure/retry
/// handling) used by the Add/Edit Visit form.
class VisitController extends GetxController {
  VisitController({
    required GetVisitsUseCase getVisitsUseCase,
    required GetVisitDetailsUseCase getVisitDetailsUseCase,
    required CreateVisitUseCase createVisitUseCase,
    required UpdateVisitUseCase updateVisitUseCase,
    required DeleteVisitUseCase deleteVisitUseCase,
    required GetChildrenUseCase getChildrenUseCase,
    required NetworkInfo networkInfo,
  }) : _getVisitsUseCase = getVisitsUseCase,
       _getVisitDetailsUseCase = getVisitDetailsUseCase,
       _createVisitUseCase = createVisitUseCase,
       _updateVisitUseCase = updateVisitUseCase,
       _deleteVisitUseCase = deleteVisitUseCase,
       _getChildrenUseCase = getChildrenUseCase,
       _networkInfo = networkInfo;

  /// Preset options shown in the visit type dropdown.
  static const List<String> visitTypeOptions = [
    'Medical',
    'Dental',
    'Vision',
    'Therapy',
    'Vaccination',
    'Other',
  ];

  static const int maxFileSizeBytes = 12 * 1024 * 1024;
  static const List<String> allowedExtensions = ['pdf', 'doc', 'docx'];

  final GetVisitsUseCase _getVisitsUseCase;
  final GetVisitDetailsUseCase _getVisitDetailsUseCase;
  final CreateVisitUseCase _createVisitUseCase;
  final UpdateVisitUseCase _updateVisitUseCase;
  final DeleteVisitUseCase _deleteVisitUseCase;
  final GetChildrenUseCase _getChildrenUseCase;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;

  final purposeController = TextEditingController();
  final physicianController = TextEditingController();
  final hospitalController = TextEditingController();
  final commentController = TextEditingController();
  final selectedChildId = RxnString();
  final selectedVisitType = RxnString();
  final selectedDate = Rxn<DateTime>();
  final formKey = GlobalKey<FormState>();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final visits = <VisitEntity>[].obs;
  final filteredVisits = <VisitEntity>[].obs;
  final children = <ChildEntity>[].obs;
  final filterChildId = RxnString();
  final selectedVisit = Rxn<VisitEntity>();
  final isLoadingDetails = false.obs;

  /// Documents attached to the visit currently being added/edited.
  final documents = <VisitDocumentItem>[].obs;
  int _documentIdCounter = 0;

  @override
  void onInit() {
    super.onInit();
    loadVisits();
    loadChildren();
    // Retry as soon as connectivity is restored so the list/child picker
    // doesn't stay stuck empty/stale after a reconnect.
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected) {
        loadChildren();
        loadVisits();
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    purposeController.dispose();
    physicianController.dispose();
    hospitalController.dispose();
    commentController.dispose();
    super.onClose();
  }

  /// Loads the children list for the visit form's child picker.
  Future<void> loadChildren() async {
    final result = await _getChildrenUseCase();
    result.when(success: (data) => children.assignAll(data), failure: (_) {});
  }

  /// Loads visits from the repository.
  Future<void> loadVisits() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getVisitsUseCase();

    result.when(
      success: (data) {
        visits.assignAll(data);
        _applyFilters();
        isLoading.value = false;
      },
      failure: (exception) {
        errorMessage.value = switch (exception) {
          NetworkException() => exception.message,
          _ => 'Failed to load visits',
        };
        isLoading.value = false;
      },
    );
  }

  /// Loads a single visit's details for the Visit Detail screen.
  Future<void> loadVisitDetails(String id) async {
    isLoadingDetails.value = true;
    errorMessage.value = null;

    final result = await _getVisitDetailsUseCase(id);

    result.when(
      success: (visit) {
        selectedVisit.value = visit;
        isLoadingDetails.value = false;
      },
      failure: (exception) {
        errorMessage.value = exception.message;
        isLoadingDetails.value = false;
      },
    );
  }

  /// Creates a new visit.
  Future<bool> createVisit(VisitEntity visit) async {
    isSaving.value = true;

    final result = await _createVisitUseCase(visit);

    isSaving.value = false;
    return result.when(
      success: (created) {
        visits.add(created);
        _applyFilters();
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }

  /// Updates an existing visit.
  Future<bool> updateVisit(VisitEntity visit) async {
    isSaving.value = true;

    final result = await _updateVisitUseCase(visit);

    isSaving.value = false;
    return result.when(
      success: (updated) {
        final index = visits.indexWhere((v) => v.id == updated.id);
        if (index != -1) {
          visits[index] = updated;
          _applyFilters();
        }
        if (selectedVisit.value?.id == updated.id) {
          selectedVisit.value = updated;
        }
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }

  /// Deletes a visit.
  Future<bool> deleteVisit(String id) async {
    isSaving.value = true;

    final result = await _deleteVisitUseCase(id);

    isSaving.value = false;
    return result.when(
      success: (_) {
        visits.removeWhere((v) => v.id == id);
        _applyFilters();
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }

  /// Restricts the visits list to a single child, or clears the
  /// restriction when [id] is null.
  void setChildFilter(String? id) {
    if (filterChildId.value == id) return;
    filterChildId.value = id;
    _applyFilters();
  }

  void _applyFilters() {
    var result = List<VisitEntity>.from(visits);

    if (filterChildId.value != null) {
      result = result.where((v) => v.childId == filterChildId.value).toList();
    }
    // Most recent visit first.
    result.sort((a, b) {
      final ad = a.visitDate;
      final bd = b.visitDate;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });

    filteredVisits.assignAll(result);
  }

  /// Refreshes visit data (shows loading spinner).
  @override
  Future<void> refresh() async {
    await loadVisits();
  }

  /// Reloads visits without showing the loading spinner. Used after
  /// add/edit/delete so the list updates immediately on return.
  Future<void> refreshSilently() async {
    final result = await _getVisitsUseCase();
    result.when(
      success: (data) {
        visits.assignAll(data);
        _applyFilters();
      },
      failure: (_) {},
    );
  }

  /// Clears form fields for a fresh Add Visit.
  void clearForm() {
    purposeController.clear();
    physicianController.clear();
    hospitalController.clear();
    commentController.clear();
    selectedChildId.value = null;
    selectedVisitType.value = visitTypeOptions.first;
    selectedDate.value = null;
    documents.clear();
    _documentIdCounter = 0;
  }

  /// Populates form for editing, including previously-uploaded documents.
  void populateForm(VisitEntity visit) {
    purposeController.text = visit.purpose ?? '';
    physicianController.text = visit.physician ?? '';
    hospitalController.text = visit.hospital ?? '';
    commentController.text = visit.comment ?? '';
    selectedChildId.value = visit.childId;
    selectedVisitType.value = visitTypeOptions.contains(visit.visitType)
        ? visit.visitType
        : visitTypeOptions.first;
    selectedDate.value = visit.visitDate;
    documents.assignAll(
      visit.documents.map((d) {
        final item = VisitDocumentItem(
          id: d.id,
          fileName: d.fileName,
          fileSizeBytes: d.fileSizeBytes,
          filePath: '',
          status: DocumentUploadStatus.uploaded,
        );
        item.progress.value = 1;
        return item;
      }),
    );
  }

  // ── Document upload ──────────────────────────────────────────────────────

  /// Opens the native file picker restricted to [allowedExtensions] and,
  /// once a file is chosen, kicks off a simulated upload for it.
  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    if (picked.size > maxFileSizeBytes) {
      Get.snackbar(AppStrings.error, AppStrings.fileTooLarge);
      return;
    }

    final item = VisitDocumentItem(
      id: 'local-${_documentIdCounter++}',
      fileName: picked.name,
      fileSizeBytes: picked.size,
      filePath: picked.path ?? '',
    );
    documents.add(item);
    unawaited(_simulateUpload(item));
  }

  /// Re-attempts an upload after a failure (e.g. network was restored).
  Future<void> retryUpload(VisitDocumentItem item) async {
    item.status.value = DocumentUploadStatus.uploading;
    item.progress.value = 0;
    await _simulateUpload(item);
  }

  void removeDocument(VisitDocumentItem item) {
    documents.remove(item);
  }

  /// Simulates a chunked upload with progress, failing the item if
  /// connectivity drops partway through (network failure state).
  Future<void> _simulateUpload(VisitDocumentItem item) async {
    const totalSteps = 20;
    const stepDuration = Duration(milliseconds: 180);

    for (var step = 1; step <= totalSteps; step++) {
      await Future.delayed(stepDuration);
      // The item may have been removed (form left / deleted) mid-upload —
      // bail out rather than mutate a detached document.
      if (!documents.contains(item)) return;

      if (!await _networkInfo.isConnected) {
        item.status.value = DocumentUploadStatus.failed;
        return;
      }

      item.progress.value = step / totalSteps;
      item.secondsRemaining.value =
          ((totalSteps - step) * stepDuration.inMilliseconds / 1000).ceil();
    }

    item.status.value = DocumentUploadStatus.uploaded;
  }

  /// Documents ready to be persisted with the visit — uploads still in
  /// progress or failed are excluded until they succeed.
  List<VisitDocumentItem> get uploadedDocuments => documents
      .where((d) => d.status.value == DocumentUploadStatus.uploaded)
      .toList();
}
