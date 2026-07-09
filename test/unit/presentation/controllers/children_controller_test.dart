import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:kincare/presentation/controllers/children_controller.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockGetChildrenUseCase getChildrenUseCase;
  late MockGetChildDetailsUseCase getChildDetailsUseCase;
  late MockNetworkInfo networkInfo;
  late ChildrenController controller;

  List<ChildEntity> childrenNamed(List<String> names) => [
    for (var i = 0; i < names.length; i++)
      ChildEntity(id: '$i', name: names[i]),
  ];

  setUp(() {
    getChildrenUseCase = MockGetChildrenUseCase();
    getChildDetailsUseCase = MockGetChildDetailsUseCase();
    networkInfo = MockNetworkInfo();
    when(
      networkInfo.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());
    controller = ChildrenController(
      getChildrenUseCase: getChildrenUseCase,
      getChildDetailsUseCase: getChildDetailsUseCase,
      networkInfo: networkInfo,
    );
  });

  group('loadChildren', () {
    test('populates children sorted alphabetically by name', () async {
      final unsorted = childrenNamed(['Zara', 'Amit', 'Meera']);
      when(
        getChildrenUseCase(),
      ).thenAnswer((_) async => Result.success(unsorted));

      await controller.loadChildren();

      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isNull);
      expect(controller.filteredChildren.map((c) => c.name).toList(), [
        'Amit',
        'Meera',
        'Zara',
      ]);
    });

    test('maps NetworkException to its own message', () async {
      when(getChildrenUseCase()).thenAnswer(
        (_) async => const Result.failure(NetworkException('offline')),
      );

      await controller.loadChildren();

      expect(controller.errorMessage.value, 'offline');
      expect(controller.isLoading.value, isFalse);
    });

    test('maps any other exception to a generic message', () async {
      when(
        getChildrenUseCase(),
      ).thenAnswer((_) async => const Result.failure(UnexpectedException()));

      await controller.loadChildren();

      expect(controller.errorMessage.value, 'Failed to load children');
    });
  });

  group('pagination', () {
    setUp(() async {
      // 7 children, pageSize 5 -> 2 pages, page 2 has 2 items.
      final children = childrenNamed(['A', 'B', 'C', 'D', 'E', 'F', 'G']);
      when(
        getChildrenUseCase(),
      ).thenAnswer((_) async => Result.success(children));
      await controller.loadChildren();
    });

    test('computes totalPages from filtered list length and page size', () {
      expect(controller.totalPages, 2);
    });

    test('starts on page 1 with a full page of items', () {
      expect(controller.currentPage.value, 1);
      expect(controller.pagedChildren, hasLength(5));
    });

    test('nextPage advances to the next page with the remainder', () {
      controller.nextPage();

      expect(controller.currentPage.value, 2);
      expect(controller.pagedChildren, hasLength(2));
    });

    test('goToPage ignores out-of-range pages', () {
      controller.goToPage(0);
      expect(controller.currentPage.value, 1);

      controller.goToPage(99);
      expect(controller.currentPage.value, 1);
    });

    test('previousPage does not go below page 1', () {
      controller.previousPage();
      expect(controller.currentPage.value, 1);
    });

    test('nextPage does not go past the last page', () {
      controller.goToPage(2);
      controller.nextPage();
      expect(controller.currentPage.value, 2);
    });
  });

  group('loadChildDetails', () {
    test('populates selectedChild on success', () async {
      const child = ChildEntity(id: '1', name: 'Riya');
      when(
        getChildDetailsUseCase('1'),
      ).thenAnswer((_) async => const Result.success(child));

      await controller.loadChildDetails('1');

      expect(controller.selectedChild.value, child);
      expect(controller.isLoadingDetails.value, isFalse);
    });

    test('sets errorMessage on failure', () async {
      when(getChildDetailsUseCase(any)).thenAnswer(
        (_) async => const Result.failure(UnexpectedException('boom')),
      );

      await controller.loadChildDetails('missing');

      expect(controller.errorMessage.value, 'boom');
      expect(controller.isLoadingDetails.value, isFalse);
    });
  });
}
