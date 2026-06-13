import 'package:elevate/features/alarms/domain/entities/alarm_entity.dart';
import 'package:elevate/features/alarms/domain/repositories/alarm_repository.dart';

class AddAlarm {
  final AlarmRepository _repository;
  const AddAlarm(this._repository);
  Future<void> call(AlarmEntity alarm) => _repository.addAlarm(alarm);
}
