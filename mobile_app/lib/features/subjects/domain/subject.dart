import 'package:mobile_app/features/subjects/domain/schedule_model.dart';

class Subject {
  final String id;
  final String name;
  final String color;
  final String? teacherName;
  final String? teacherEmail;
  final String? teacherPhone;
  final double studyGoalHours;
  final String? category;
  final String? difficulty;
  final int streak;
  final List<ScheduleItem> schedules;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    this.teacherName,
    this.teacherEmail,
    this.teacherPhone,
    required this.studyGoalHours,
    this.category,
    this.difficulty,
    this.streak = 0,
    this.schedules = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    try {
      // Parse schedules array
      List<ScheduleItem> schedules = [];
      if (json['schedules'] != null && json['schedules'] is List) {
        try {
          schedules = (json['schedules'] as List<dynamic>)
              .map((scheduleJson) {
                if (scheduleJson is Map<String, dynamic>) {
                  return ScheduleItem.fromJson(scheduleJson);
                }
                return null;
              })
              .whereType<ScheduleItem>()
              .toList();
        } catch (e) {
          // If schedule parsing fails, continue with empty list
          schedules = [];
        }
      }

      return Subject(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        color: json['color'] as String? ?? '#3B82F6',
        teacherName: json['teacherName'] as String?,
        teacherEmail: json['teacherEmail'] as String?,
        teacherPhone: json['teacherPhone'] as String?,
        studyGoalHours: (json['studyGoalHours'] as num?)?.toDouble() ?? 0.0,
        category: json['category'] as String?,
        difficulty: json['difficulty'] as String?,
        streak: (json['streak'] as int?) ?? 0,
        schedules: schedules,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse Subject from JSON: $e\nJSON: $json',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'teacherName': teacherName,
      'teacherEmail': teacherEmail,
      'teacherPhone': teacherPhone,
      'studyGoalHours': studyGoalHours,
      'category': category,
      'difficulty': difficulty,
      'streak': streak,
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to DTO format for creating/updating (excludes id and timestamps)
  Map<String, dynamic> toCreateDto() {
    return {
      'name': name,
      'color': color,
      if (teacherName != null) 'teacherName': teacherName,
      if (teacherEmail != null) 'teacherEmail': teacherEmail,
      if (teacherPhone != null) 'teacherPhone': teacherPhone,
      'studyGoalHours': studyGoalHours,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (schedules.isNotEmpty)
        'schedules': schedules.map((schedule) => schedule.toCreateDto()).toList(),
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? color,
    String? teacherName,
    String? teacherEmail,
    String? teacherPhone,
    double? studyGoalHours,
    String? category,
    String? difficulty,
    int? streak,
    List<ScheduleItem>? schedules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      teacherName: teacherName ?? this.teacherName,
      teacherEmail: teacherEmail ?? this.teacherEmail,
      teacherPhone: teacherPhone ?? this.teacherPhone,
      studyGoalHours: studyGoalHours ?? this.studyGoalHours,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      streak: streak ?? this.streak,
      schedules: schedules ?? this.schedules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

