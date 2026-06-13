import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:elevate/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:elevate/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:elevate/features/dashboard/domain/usecases/get_dashboard_data.dart';

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});

// Use case provider
final getDashboardDataUseCaseProvider = Provider<GetDashboardDataUseCase>((ref) {
  return GetDashboardDataUseCase(ref.read(dashboardRepositoryProvider));
});

// Dashboard data state provider
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final useCase = ref.read(getDashboardDataUseCaseProvider);
  return useCase();
});

// Current nav index provider
final navIndexProvider = StateProvider<int>((ref) => 0);

// Refresh trigger provider  
final refreshTriggerProvider = StateProvider<int>((ref) => 0);
