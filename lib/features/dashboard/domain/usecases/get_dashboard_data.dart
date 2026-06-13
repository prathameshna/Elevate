import 'package:elevate/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:elevate/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardDataUseCase {
  final DashboardRepository _repository;

  const GetDashboardDataUseCase(this._repository);

  Future<DashboardData> call() => _repository.getDashboardData();
}
