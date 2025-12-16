import 'package:flutter/material.dart';

/// Class Schedule Model
/// Represents a single class schedule entry (e.g., Monday 9AM-10:30AM)
class ScheduleItem {
  final String id;
  final String dayOfWeek; // 'Mon', 'Tue', 'Wed', etc.
  final String startTime; // 'HH:mm' format (e.g., '09:00')
  final String endTime; // 'HH:mm' format (e.g., '10:30')
  final String? location; // e.g., "Room 304"
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleItem({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert TimeOfDay to HH:mm string
  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Convert HH:mm string to TimeOfDay
  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Get startTime as TimeOfDay object
  TimeOfDay get startTimeObj => stringToTimeOfDay(startTime);

  /// Get endTime as TimeOfDay object
  TimeOfDay get endTimeObj => stringToTimeOfDay(endTime);

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    try {
      return ScheduleItem(
        id: json['id'] as String? ?? '',
        dayOfWeek: json['dayOfWeek'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '09:00',
        endTime: json['endTime'] as String? ?? '10:00',
        location: json['location'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse ScheduleItem from JSON: $e\nJSON: $json',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to DTO format for creating/updating (excludes id and timestamps)
  Map<String, dynamic> toCreateDto() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      if (location != null) 'location': location,
    };
  }

  ScheduleItem copyWith({
    String? id,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

