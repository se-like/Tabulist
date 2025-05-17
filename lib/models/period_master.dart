import 'package:flutter/material.dart';

class PeriodMaster {
  final String id;
  final int dayOfWeek;
  final TimeOfDay startTime;
  final List<Period> periods;

  PeriodMaster({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.periods,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'periods': periods.map((period) => period.toJson()).toList(),
    };
  }

  factory PeriodMaster.fromJson(Map<String, dynamic> json) {
    return PeriodMaster(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: TimeOfDay(
        hour: json['startTime']['hour'] as int,
        minute: json['startTime']['minute'] as int,
      ),
      periods: (json['periods'] as List)
          .map((period) => Period.fromJson(period as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Period {
  final String id;
  final int periodNumber;
  final int duration;
  final bool isEnabled;
  final int breakDuration;

  Period({
    required this.id,
    required this.periodNumber,
    required this.duration,
    required this.isEnabled,
    this.breakDuration = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodNumber': periodNumber,
      'duration': duration,
      'isEnabled': isEnabled,
      'breakDuration': breakDuration,
    };
  }

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'] as String,
      periodNumber: json['periodNumber'] as int,
      duration: json['duration'] as int,
      isEnabled: json['isEnabled'] as bool,
      breakDuration: json['breakDuration'] as int? ?? 10,
    );
  }
} 