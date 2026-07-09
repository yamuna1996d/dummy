import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/network/network_info.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/entities/medication_entity.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:kincare/domain/usecases/get_medications_usecase.dart';
import 'package:kincare/domain/usecases/create_medication_usecase.dart';
import 'package:kincare/domain/usecases/update_medication_usecase.dart';
import 'package:kincare/domain/usecases/delete_medication_usecase.dart';

/// Controller for medication management state and actions.
class MedicationController extends GetxController {
  MedicationController({
    required GetMedicationsUseCase getMedicationsUseCase,
    required CreateMedicationUseCase createMedicationUseCase,
    required UpdateMedicationUseCase updateMedicationUseCase,
    required DeleteMedicationUseCase deleteMedicationUseCase,
    required GetChildrenUseCase getChildrenUseCase,
    required NetworkInfo networkInfo,
  }) : _getMedicationsUseCase = getMedicationsUseCase,
       _createMedicationUseCase = createMedicationUseCase,
       _updateMedicationUseCase = updateMedicationUseCase,
       _deleteMedicationUseCase = deleteMedicationUseCase,
       _getChildrenUseCase = getChildrenUseCase,
       _networkInfo = networkInfo;

  /// Preset options shown in the medication frequency dropdown.
  static const List<String> frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'As needed',
    'Before meals',
    'After meals',
    'At bedtime',
  ];

  final GetMedicationsUseCase _getMedicationsUseCase;
  final CreateMedicationUseCase _createMedicationUseCase;
  final UpdateMedicationUseCase _updateMedicationUseCase;
  final DeleteMedicationUseCase _deleteMedicationUseCase;
  final GetChildrenUseCase _getChildrenUseCase;
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;

  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();
  final selectedChildId = RxnString();
  final selectedFrequency = RxnString();
  final formKey = GlobalKey<FormState>();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final medications = <MedicationEntity>[].obs;
  final filteredMedications = <MedicationEntity>[].obs;
  final children = <ChildEntity>[].obs;
  final filterChildId = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadMedications();
    loadChildren();
    // The children list (and medications) can fail to load while offline.
    // Retry as soon as connectivity is restored so the child picker
    // dropdown doesn't stay stuck empty/stale after a reconnect.
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected) {
        loadChildren();
        loadMedications();
      }
    });
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    nameController.dispose();
    dosageController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Loads the children list for the medication form's child picker.
  Future<void> loadChildren() async {
    final result = await _getChildrenUseCase();
    result.when(success: (data) => children.assignAll(data), failure: (_) {});
  }

  /// Loads medications from the repository.
  Future<void> loadMedications() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getMedicationsUseCase();

    result.when(
      success: (data) {
        medications.assignAll(data);
        _applyFilters();
        isLoading.value = false;
      },
      failure: (exception) {
        errorMessage.value = switch (exception) {
          NetworkException() => exception.message,
          _ => 'Failed to load medications',
        };
        isLoading.value = false;
      },
    );
  }

  /// Creates a new medication.
  Future<bool> createMedication(MedicationEntity medication) async {
    isSaving.value = true;

    final result = await _createMedicationUseCase(medication);

    isSaving.value = false;
    return result.when(
      success: (created) {
        medications.add(created);
        _applyFilters();
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }

  /// Updates an existing medication.
  Future<bool> updateMedication(MedicationEntity medication) async {
    isSaving.value = true;

    final result = await _updateMedicationUseCase(medication);

    isSaving.value = false;
    return result.when(
      success: (updated) {
        final index = medications.indexWhere((m) => m.id == updated.id);
        if (index != -1) {
          medications[index] = updated;
          _applyFilters();
        }
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }

  /// Deletes a medication.
  Future<bool> deleteMedication(String id) async {
    isSaving.value = true;

    final result = await _deleteMedicationUseCase(id);

    isSaving.value = false;
    return result.when(
      success: (_) {
        medications.removeWhere((m) => m.id == id);
        _applyFilters();
        return true;
      },
      failure: (e) {
        errorMessage.value = e.message;
        return false;
      },
    );
  }

  /// Restricts the medications list to a single child, or clears the
  /// restriction when [id] is null.
  ///
  /// The early-return guard prevents _applyFilters from running (and
  /// triggering reactive rebuilds) if the screen rebuilds with the same
  /// filter already applied — e.g. when MedicationListScreen's build()
  /// calls this on every frame.
  void setChildFilter(String? id) {
    if (filterChildId.value == id) return;
    filterChildId.value = id;
    _applyFilters();
  }

  // When filterChildId is set, only medications belonging to that child are
  // shown. When null, all medications are shown (drawer / default route).
  void _applyFilters() {
    var result = List<MedicationEntity>.from(medications);

    if (filterChildId.value != null) {
      result = result.where((m) => m.childId == filterChildId.value).toList();
    }

    filteredMedications.assignAll(result);
  }

  /// Refreshes medication data (shows loading spinner).
  @override
  Future<void> refresh() async {
    await loadMedications();
  }

  /// Reloads medications from the in-memory executor without showing the
  /// loading spinner. Used after add / edit / delete so the list updates
  /// immediately when the user navigates back, without a visible flash.
  Future<void> refreshSilently() async {
    final result = await _getMedicationsUseCase();
    result.when(
      success: (data) {
        medications.assignAll(data);
        _applyFilters();
      },
      failure: (_) {},
    );
  }

  /// Clears form fields.
  void clearForm() {
    nameController.clear();
    dosageController.clear();
    notesController.clear();
    selectedChildId.value = null;
    selectedFrequency.value = null;
  }

  /// Populates form for editing.
  void populateForm(MedicationEntity medication) {
    nameController.text = medication.name;
    dosageController.text = medication.dosage ?? '';
    notesController.text = medication.notes ?? '';
    selectedChildId.value = medication.childId;
    selectedFrequency.value = medication.frequency;
  }
}
