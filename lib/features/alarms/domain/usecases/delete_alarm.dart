import 'package:elevate/features/alarms/domain/repositories/alarm_repository.dart';

class DeleteAlarm {
  final AlarmRepository _repository;
  const DeleteAlarm(this._repository);
  Future<void> call(String id) => _repository.deleteAlarm(id);
}
