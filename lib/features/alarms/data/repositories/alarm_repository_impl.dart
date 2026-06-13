import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elevate/features/alarms/domain/entities/alarm_entity.dart';
import 'package:elevate/features/alarms/domain/repositories/alarm_repository.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  late final Box _box;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    _box = Hive.box('alarmsBox');

    if (_box.isEmpty) {
      // Seed with realistic alarms matching the screenshot exactly.
      final seedAlarms = [
        AlarmEntity(
          id: '1',
          time: DateTime(2024, 1, 1, 6, 45),
          label: 'Morning Grind',
          enabled: true,
          repeatDays: [1, 2, 3, 4, 5], // Weekdays
          isNextAlarm: true,
          missions: const [
            AlarmMission(
              label: 'COLOUR TILES',
              backgroundColor: Color(0xFFEEF2FF),
              textColor: Color(0xFF4F46E5),
            ),
            AlarmMission(
              label: '50 STEPS',
              backgroundColor: Color(0xFFFFF7ED),
              textColor: Color(0xFFEA7C1E),
            ),
            AlarmMission(
              label: 'MEMORY',
              backgroundColor: Color(0xFFF0FDF4),
              textColor: Color(0xFF16A34A),
            ),
          ],
        ),
        AlarmEntity(
          id: '2',
          time: DateTime(2024, 1, 1, 7, 30),
          label: 'Backup',
          enabled: true,
          repeatDays: List.generate(7, (i) => i + 1), // Daily
          isNextAlarm: false,
          snoozeDurationMinutes: 5,
          missions: const [
            AlarmMission(
              label: 'MATH',
              backgroundColor: Color(0xFFEEF2FF),
              textColor: Color(0xFF4F46E5),
            ),
          ],
        ),
      ];

      for (final alarm in seedAlarms) {
        await _box.put(alarm.id, alarm.toJson());
      }
    }
    _initialized = true;
  }

  @override
  Future<List<AlarmEntity>> getAlarms() async {
    await _init();
    final alarms = _box.values.map((e) {
      return AlarmEntity.fromJson(Map<dynamic, dynamic>.from(e as Map));
    }).toList();

    alarms.sort((a, b) {
      final aMin = a.time.hour * 60 + a.time.minute;
      final bMin = b.time.hour * 60 + b.time.minute;
      return aMin.compareTo(bMin);
    });
    return alarms;
  }

  @override
  Future<void> addAlarm(AlarmEntity alarm) async {
    await _init();
    await _box.put(alarm.id, alarm.toJson());
  }

  @override
  Future<void> deleteAlarm(String id) async {
    await _init();
    await _box.delete(id);
  }

  @override
  Future<void> toggleAlarm(String id, {required bool enabled}) async {
    await _init();
    final data = _box.get(id);
    if (data != null) {
      final alarm = AlarmEntity.fromJson(Map<dynamic, dynamic>.from(data as Map));
      final updated = alarm.copyWith(enabled: enabled);
      await _box.put(id, updated.toJson());
    }
  }
}
