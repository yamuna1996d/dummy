import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/core/errors/app_exception.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/child_model.dart';
import 'package:kincare/data/repositories/children_repository_impl.dart';
import 'package:kincare/domain/entities/child_entity.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  late MockChildrenRemoteDatasource remoteDatasource;
  late MockNetworkInfo networkInfo;
  late ChildrenRepositoryImpl repository;

  const child = ChildEntity(id: '1', name: 'Riya');

  setUp(() {
    remoteDatasource = MockChildrenRemoteDatasource();
    networkInfo = MockNetworkInfo();
    repository = ChildrenRepositoryImpl(
      remoteDatasource: remoteDatasource,
      networkInfo: networkInfo,
    );
  });

  group('getChildren', () {
    test(
      'returns NetworkException without hitting the datasource when offline',
      () async {
        when(networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.getChildren();

        expect(result.isFailure, isTrue);
        result.when(
          success: (_) => fail('expected a failure'),
          failure: (e) => expect(e, isA<NetworkException>()),
        );
        verifyNever(remoteDatasource.getChildren());
      },
    );

    test('delegates to the datasource when online', () async {
      when(networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        remoteDatasource.getChildren(),
      ).thenAnswer((_) async => Result.success([ChildModel.fromEntity(child)]));

      final result = await repository.getChildren();

      expect(result.isSuccess, isTrue);
      verify(remoteDatasource.getChildren()).called(1);
    });
  });

  group('getChildDetails', () {
    test('does not perform a connectivity check', () async {
      when(
        remoteDatasource.getChildDetails('1'),
      ).thenAnswer((_) async => Result.success(ChildModel.fromEntity(child)));

      final result = await repository.getChildDetails('1');

      expect(result.isSuccess, isTrue);
      verifyNever(networkInfo.isConnected);
    });
  });

  group('addChild', () {
    test(
      'returns NetworkException without hitting the datasource when offline',
      () async {
        when(networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.addChild(child);

        result.when(
          success: (_) => fail('expected a failure'),
          failure: (e) => expect(e, isA<NetworkException>()),
        );
        verifyNever(remoteDatasource.addChild(any));
      },
    );

    test(
      'converts the entity to a model before calling the datasource',
      () async {
        when(networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          remoteDatasource.addChild(any),
        ).thenAnswer((_) async => Result.success(ChildModel.fromEntity(child)));

        await repository.addChild(child);

        final captured =
            verify(remoteDatasource.addChild(captureAny)).captured.single
                as ChildModel;
        expect(captured.id, child.id);
        expect(captured.name, child.name);
      },
    );
  });

  group('updateChild', () {
    test(
      'returns NetworkException without hitting the datasource when offline',
      () async {
        when(networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.updateChild(child);

        expect(result.isFailure, isTrue);
        verifyNever(remoteDatasource.updateChild(any));
      },
    );
  });

  group('deleteChild', () {
    test(
      'returns NetworkException without hitting the datasource when offline',
      () async {
        when(networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.deleteChild('1');

        expect(result.isFailure, isTrue);
        verifyNever(remoteDatasource.deleteChild(any));
      },
    );

    test('delegates to the datasource when online', () async {
      when(networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        remoteDatasource.deleteChild('1'),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await repository.deleteChild('1');

      expect(result.isSuccess, isTrue);
      verify(remoteDatasource.deleteChild('1')).called(1);
    });
  });
}
