import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/dashboard/data/dashboard_repository.dart';
import 'package:mobile_app/features/dashboard/domain/dashboard_stats.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardStats();
});

