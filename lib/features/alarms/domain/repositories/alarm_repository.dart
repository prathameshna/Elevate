import 'package:elevate/features/alarms/domain/entities/alarm_entity.dart';

abstract class AlarmRepository {
  Future<List<AlarmEntity>> getAlarms();
  Future<void> addAlarm(AlarmEntity alarm);
  Future<void> deleteAlarm(String id);
  Future<void> toggleAlarm(String id, {required bool enabled});
}
