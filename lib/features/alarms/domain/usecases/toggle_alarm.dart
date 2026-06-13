import 'package:elevate/features/alarms/domain/repositories/alarm_repository.dart';

class ToggleAlarm {
  final AlarmRepository _repository;
  const ToggleAlarm(this._repository);
  Future<void> call(String id, {required bool enabled}) =>
      _repository.toggleAlarm(id, enabled: enabled);
}
