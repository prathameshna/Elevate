import 'package:elevate/features/dashboard/data/models/dashboard_model.dart';
import 'package:elevate/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:elevate/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardData> getDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    return DashboardModel.mock();
  }
}
