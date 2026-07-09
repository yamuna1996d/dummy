import 'package:kincare/core/api/graphql_queries.dart';
import 'package:kincare/core/api/graphql_service.dart';
import 'package:kincare/core/errors/result.dart';
import 'package:kincare/data/models/dashboard_model.dart';

/// Remote datasource for fetching dashboard data from GraphQL.
class DashboardRemoteDatasource {
  const DashboardRemoteDatasource(this._graphQLService);

  final GraphQLService _graphQLService;

  Future<Result<DashboardModel>> getDashboard() async {
    final childrenResult = await _graphQLService.query(
      GraphQLQueries.getChildren,
      variables: {
        'options': {
          'paginate': {'page': 1, 'limit': 100},
        },
      },
    );

    final medicationsResult = await _graphQLService.query(
      GraphQLQueries.getMedications,
      variables: {
        'options': {
          'paginate': {'page': 1, 'limit': 10},
        },
      },
    );

    final childCount = childrenResult.when(
      success: (response) => response.connectionTotalCount('children'),
      failure: (_) => 0,
    );

    final medCount = medicationsResult.when(
      success: (response) => response.connectionTotalCount('medications'),
      failure: (_) => 0,
    );

    // Find every child with a future appointment, soonest first, by reading
    // the same children payload used for the child count above.
    final now = DateTime.now();
    final upcoming = childrenResult.when(
      success: (response) {
        final children = response.connectionItems('children') ?? [];
        final withAppointments =
            children
                .where(
                  (c) =>
                      c['nextAppointmentDate'] != null &&
                      DateTime.tryParse(
                            c['nextAppointmentDate'] as String,
                          )?.isAfter(now) ==
                          true,
                )
                .toList()
              ..sort(
                (a, b) => DateTime.parse(
                  a['nextAppointmentDate'] as String,
                ).compareTo(DateTime.parse(b['nextAppointmentDate'] as String)),
              );
        return withAppointments;
      },
      failure: (_) => <Map<String, dynamic>>[],
    );
    final soonest = upcoming.isNotEmpty ? upcoming.first : null;

    final activities = <ActivityModel>[
      ActivityModel(
        id: '1',
        title: 'Medication Reminder',
        description: 'Vitamin D due for Sarah',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        icon: 'medication',
      ),
      ActivityModel(
        id: '2',
        title: 'Appointment Scheduled',
        description: 'Pediatrician visit for Alex',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        icon: 'appointment',
      ),
      ActivityModel(
        id: '3',
        title: 'Profile Updated',
        description: 'Emergency contact information updated',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: 'profile',
      ),
    ];

    final dashboard = DashboardModel(
      totalChildren: childCount,
      totalMedications: medCount,
      upcomingAppointments: upcoming.length,
      recentActivities: activities,
      nextAppointmentChildId: soonest?['id'] as String?,
      nextAppointmentChildName: soonest?['name'] as String?,
      nextAppointmentTitle: soonest?['nextAppointmentTitle'] as String?,
      nextAppointmentDate: soonest != null
          ? DateTime.parse(soonest['nextAppointmentDate'] as String)
          : null,
      nextAppointmentTime: soonest?['nextAppointmentTime'] as String?,
      nextAppointmentLocation: soonest?['nextAppointmentLocation'] as String?,
    );

    return Result.success(dashboard);
  }
}
