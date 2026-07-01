import 'package:get/get.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/domain/usecases/get_children_usecase.dart';
import 'package:kincare/domain/usecases/get_child_details_usecase.dart';

/// Controller for children management state and actions.
class ChildrenController extends GetxController {
  ChildrenController({
    required GetChildrenUseCase getChildrenUseCase,
    required GetChildDetailsUseCase getChildDetailsUseCase,
  }) : _getChildrenUseCase = getChildrenUseCase,
       _getChildDetailsUseCase = getChildDetailsUseCase;

  final GetChildrenUseCase _getChildrenUseCase;
  final GetChildDetailsUseCase _getChildDetailsUseCase;

  final isLoading = true.obs;
  final isLoadingDetails = false.obs;
  final errorMessage = RxnString();
  final children = <ChildEntity>[].obs;
  final filteredChildren = <ChildEntity>[].obs;
  final pagedChildren = <ChildEntity>[].obs;
  final selectedChild = Rxn<ChildEntity>();

  /// Pagination state.
  static const int pageSize = 5;
  final currentPage = 1.obs;
  int get totalPages =>
      (filteredChildren.length / pageSize).ceil().clamp(1, 999);

  @override
  void onInit() {
    super.onInit();
    loadChildren();
  }

  /// Loads children list from the repository.
  Future<void> loadChildren() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getChildrenUseCase();

    result.when(
      success: (data) {
        children.assignAll(data);
        _applyFilters();
        isLoading.value = false;
      },
      failure: (exception) {
        errorMessage.value = switch (exception) {
          NetworkException() => exception.message,
          _ => 'Failed to load children',
        };
        isLoading.value = false;
      },
    );
  }

  /// Loads details for a specific child.
  Future<void> loadChildDetails(String id) async {
    isLoadingDetails.value = true;

    final result = await _getChildDetailsUseCase(id);

    result.when(
      success: (child) {
        selectedChild.value = child;
        isLoadingDetails.value = false;
      },
      failure: (exception) {
        errorMessage.value = exception.message;
        isLoadingDetails.value = false;
      },
    );
  }

  // Sorts children alphabetically by name. Resets to page 1 so that any
  // previous page offset doesn't leave the user on a now-invalid page.
  void _applyFilters() {
    final result = List<ChildEntity>.from(children)
      ..sort((a, b) => a.name.compareTo(b.name));

    filteredChildren.assignAll(result);
    currentPage.value = 1;
    _applyPagination();
  }

  // Slices filteredChildren into the current page window. clamp() prevents
  // index-out-of-range crashes when the list length isn't a multiple of
  // pageSize (e.g. 7 items, page 2 would compute end=10, clamped to 7).
  void _applyPagination() {
    final start = (currentPage.value - 1) * pageSize;
    final end = start + pageSize;
    pagedChildren.assignAll(
      filteredChildren.sublist(
        start.clamp(0, filteredChildren.length),
        end.clamp(0, filteredChildren.length),
      ),
    );
  }

  /// Navigates to a specific page.
  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    currentPage.value = page;
    _applyPagination();
  }

  /// Navigates to the next page.
  void nextPage() => goToPage(currentPage.value + 1);

  /// Navigates to the previous page.
  void previousPage() => goToPage(currentPage.value - 1);

  /// Refreshes children data.
  @override
  Future<void> refresh() async {
    await loadChildren();
  }
}
