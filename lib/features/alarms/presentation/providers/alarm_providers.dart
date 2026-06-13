import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate/features/alarms/data/repositories/alarm_repository_impl.dart';
import 'package:elevate/features/alarms/domain/entities/alarm_entity.dart';
import 'package:elevate/features/alarms/domain/repositories/alarm_repository.dart';
import 'package:elevate/features/alarms/domain/usecases/add_alarm.dart';
import 'package:elevate/features/alarms/domain/usecases/delete_alarm.dart';
import 'package:elevate/features/alarms/domain/usecases/get_alarms.dart';
import 'package:elevate/features/alarms/domain/usecases/toggle_alarm.dart';

// ── Repository ──────────────────────────────────────────────────────────────
final alarmRepositoryProvider = Provider<AlarmRepository>(
  (_) => AlarmRepositoryImpl(),
);

// ── Use-case providers ───────────────────────────────────────────────────────
final getAlarmsUseCaseProvider = Provider<GetAlarms>(
  (ref) => GetAlarms(ref.read(alarmRepositoryProvider)),
);

final addAlarmUseCaseProvider = Provider<AddAlarm>(
  (ref) => AddAlarm(ref.read(alarmRepositoryProvider)),
);

final deleteAlarmUseCaseProvider = Provider<DeleteAlarm>(
  (ref) => DeleteAlarm(ref.read(alarmRepositoryProvider)),
);

final toggleAlarmUseCaseProvider = Provider<ToggleAlarm>(
  (ref) => ToggleAlarm(ref.read(alarmRepositoryProvider)),
);

// ── Alarm list notifier ──────────────────────────────────────────────────────
class AlarmNotifier extends AsyncNotifier<List<AlarmEntity>> {
  @override
  Future<List<AlarmEntity>> build() async {
    return ref.read(getAlarmsUseCaseProvider).call();
  }

  Future<void> addAlarm(AlarmEntity alarm) async {
    await ref.read(addAlarmUseCaseProvider).call(alarm);
    ref.invalidateSelf();
  }

  Future<void> deleteAlarm(String id) async {
    await ref.read(deleteAlarmUseCaseProvider).call(id);
    ref.invalidateSelf();
  }

  Future<void> toggleAlarm(String id, {required bool enabled}) async {
    await ref.read(toggleAlarmUseCaseProvider).call(id, enabled: enabled);
    // Optimistic local update so the switch feels instant
    state = AsyncData(
      (state.valueOrNull ?? []).map((a) {
        return a.id == id ? a.copyWith(enabled: enabled) : a;
      }).toList(),
    );
  }
}

final alarmProvider =
    AsyncNotifierProvider<AlarmNotifier, List<AlarmEntity>>(AlarmNotifier.new);
