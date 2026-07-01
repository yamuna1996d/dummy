import 'package:flutter_test/flutter_test.dart';
import 'package:kincare/data/models/dashboard_model.dart';
import 'package:kincare/domain/entities/dashboard_entity.dart';

void main() {
  group('DashboardModel.fromJson', () {
    test('parses counts and nested recentActivities', () {
      final json = {
        'totalChildren': 2,
        'totalMedications': 3,
        'upcomingAppointments': 1,
        'recentActivities': [
          {
            'id': 'a1',
            'title': 'Vaccination',
            'description': 'Flu shot administered',
            'timestamp': '2026-06-01T00:00:00.000Z',
            'icon': 'vaccine',
          },
        ],
        'nextAppointmentChildId': 'c1',
        'nextAppointmentChildName': 'Riya',
        'nextAppointmentTitle': 'Dental checkup',
        'nextAppointmentDate': '2026-08-01T00:00:00.000Z',
        'nextAppointmentTime': '10:00 AM',
        'nextAppointmentLocation': 'City Clinic',
      };

      final model = DashboardModel.fromJson(json);

      expect(model.totalChildren, 2);
      expect(model.totalMedications, 3);
      expect(model.upcomingAppointments, 1);
      expect(model.recentActivities, hasLength(1));
      expect(model.recentActivities.first.title, 'Vaccination');
      expect(
        model.recentActivities.first.timestamp,
        DateTime.parse('2026-06-01T00:00:00.000Z'),
      );
      expect(model.nextAppointmentChildName, 'Riya');
    });

    test('defaults counts to 0 and activities to an empty list', () {
      final model = DashboardModel.fromJson(const {});

      expect(model.totalChildren, 0);
      expect(model.totalMedications, 0);
      expect(model.upcomingAppointments, 0);
      expect(model.recentActivities, isEmpty);
      expect(model.nextAppointmentDate, isNull);
    });
  });

  group('DashboardModel.toJson', () {
    test('round-trips counts and activities through toJson/fromJson', () {
      final original = DashboardModel.fromJson({
        'totalChildren': 5,
        'totalMedications': 2,
        'upcomingAppointments': 1,
        'recentActivities': [
          {
            'id': 'a1',
            'title': 'Checkup',
            'description': 'Routine visit',
            'timestamp': '2026-05-01T00:00:00.000Z',
          },
        ],
      });

      final roundTripped = DashboardModel.fromJson(original.toJson());

      expect(roundTripped.totalChildren, original.totalChildren);
      expect(roundTripped.recentActivities, hasLength(1));
      expect(
        roundTripped.recentActivities.first.title,
        original.recentActivities.first.title,
      );
    });
  });

  group('ActivityModel', () {
    test(
      'fromJson defaults description-less timestamp to now when missing',
      () {
        final before = DateTime.now();
        final model = ActivityModel.fromJson(const {
          'id': 'a1',
          'title': 'X',
          'description': 'Y',
        });
        final after = DateTime.now();

        expect(
          model.timestamp.isAfter(before) || model.timestamp == before,
          isTrue,
        );
        expect(
          model.timestamp.isBefore(after) || model.timestamp == after,
          isTrue,
        );
      },
    );

    test('fromEntity copies every field from an ActivityEntity', () {
      final entity = ActivityEntity(
        id: 'a2',
        title: 'Title',
        description: 'Desc',
        timestamp: DateTime.parse('2026-01-01T00:00:00.000Z'),
        icon: 'note',
      );

      final model = ActivityModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.title, entity.title);
      expect(model.description, entity.description);
      expect(model.timestamp, entity.timestamp);
      expect(model.icon, entity.icon);
    });
  });
}
