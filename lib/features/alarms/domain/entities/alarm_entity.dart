import 'package:flutter/material.dart';

/// A single mission chip shown on an alarm card.
class AlarmMission {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const AlarmMission({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory AlarmMission.fromJson(Map<dynamic, dynamic> json) {
    return AlarmMission(
      label: json['label'] as String,
      backgroundColor: Color(json['backgroundColor'] as int),
      textColor: Color(json['textColor'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'backgroundColor': backgroundColor.toARGB32(),
      'textColor': textColor.toARGB32(),
    };
  }
}

/// Core alarm entity — used across domain, data and presentation layers.
class AlarmEntity {
  final String id;
  final DateTime time;
  final String label;
  final bool enabled;
  final List<int> repeatDays; // 1=Mon … 7=Sun, empty = one‑time
  final List<AlarmMission> missions;
  final int? snoozeDurationMinutes; // null = no snooze
  final bool isNextAlarm; // shows the green "NEXT ALARM" badge

  const AlarmEntity({
    required this.id,
    required this.time,
    required this.label,
    this.enabled = true,
    this.repeatDays = const [],
    this.missions = const [],
    this.snoozeDurationMinutes,
    this.isNextAlarm = false,
  });

  AlarmEntity copyWith({
    String? id,
    DateTime? time,
    String? label,
    bool? enabled,
    List<int>? repeatDays,
    List<AlarmMission>? missions,
    int? snoozeDurationMinutes,
    bool? isNextAlarm,
  }) {
    return AlarmEntity(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      repeatDays: repeatDays ?? this.repeatDays,
      missions: missions ?? this.missions,
      snoozeDurationMinutes:
          snoozeDurationMinutes ?? this.snoozeDurationMinutes,
      isNextAlarm: isNextAlarm ?? this.isNextAlarm,
    );
  }

  factory AlarmEntity.fromJson(Map<dynamic, dynamic> json) {
    return AlarmEntity(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      label: json['label'] as String,
      enabled: json['enabled'] as bool,
      repeatDays: (json['repeatDays'] as List<dynamic>).map((e) => e as int).toList(),
      isNextAlarm: json['isNextAlarm'] as bool,
      snoozeDurationMinutes: json['snoozeDurationMinutes'] as int?,
      missions: (json['missions'] as List<dynamic>)
          .map((e) => AlarmMission.fromJson(e as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'label': label,
      'enabled': enabled,
      'repeatDays': repeatDays,
      'isNextAlarm': isNextAlarm,
      'snoozeDurationMinutes': snoozeDurationMinutes,
      'missions': missions.map((m) => m.toJson()).toList(),
    };
  }
}
