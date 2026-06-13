import 'package:elevate/features/alarms/domain/entities/alarm_entity.dart';
import 'package:elevate/features/alarms/domain/repositories/alarm_repository.dart';

class GetAlarms {
  final AlarmRepository _repository;
  const GetAlarms(this._repository);
  Future<List<AlarmEntity>> call() => _repository.getAlarms();
}
