import 'package:mobile_app/features/subjects/domain/subject.dart';

enum SessionStatus {
  planned,
  inProgress,
  completed,
  skipped,
}

enum FocusType {
  deepFocus,
  revision,
  practice,
}

class StudySession {
  final String id;
  final int durationMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? title;
  final FocusType focusType;
  final SessionStatus status;
  final String? recurrenceGroupId;
  final String subjectId;
  final Subject? subject; // Optional subject data from backend
  final DateTime createdAt;

  StudySession({
    required this.id,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
    this.title,
    this.focusType = FocusType.deepFocus,
    this.status = SessionStatus.planned,
    this.recurrenceGroupId,
    required this.subjectId,
    this.subject,
    required this.createdAt,
  });

  /// Get color from subject if available, otherwise default
  String get color {
    return subject?.color ?? '#3B82F6';
  }

  /// Parse status from string
  static SessionStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PLANNED':
        return SessionStatus.planned;
      case 'IN_PROGRESS':
        return SessionStatus.inProgress;
      case 'COMPLETED':
        return SessionStatus.completed;
      case 'SKIPPED':
        return SessionStatus.skipped;
      default:
        return SessionStatus.planned;
    }
  }

  /// Parse focus type from string
  static FocusType _parseFocusType(String? focusType) {
    switch (focusType?.toUpperCase()) {
      case 'DEEP_FOCUS':
        return FocusType.deepFocus;
      case 'REVISION':
        return FocusType.revision;
      case 'PRACTICE':
        return FocusType.practice;
      default:
        return FocusType.deepFocus;
    }
  }

  /// Convert status to string for API
  static String _statusToString(SessionStatus status) {
    switch (status) {
      case SessionStatus.planned:
        return 'PLANNED';
      case SessionStatus.inProgress:
        return 'IN_PROGRESS';
      case SessionStatus.completed:
        return 'COMPLETED';
      case SessionStatus.skipped:
        return 'SKIPPED';
    }
  }

  /// Convert focus type to string for API
  static String _focusTypeToString(FocusType focusType) {
    switch (focusType) {
      case FocusType.deepFocus:
        return 'DEEP_FOCUS';
      case FocusType.revision:
        return 'REVISION';
      case FocusType.practice:
        return 'PRACTICE';
    }
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    try {
      // Parse subject if present
      Subject? subject;
      if (json['subject'] != null) {
        try {
          Map<String, dynamic>? subjectMap;
          if (json['subject'] is Map<String, dynamic>) {
            subjectMap = json['subject'] as Map<String, dynamic>;
          } else if (json['subject'] is Map) {
            subjectMap = Map<String, dynamic>.from(json['subject'] as Map);
          } else {
            subjectMap = null;
          }

          if (subjectMap != null) {
            subject = Subject.fromJson(subjectMap);
          }
        } catch (e) {
          // If subject parsing fails, continue without it
          subject = null;
        }
      }

      return StudySession(
        id: json['id'] as String? ?? '',
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        title: json['title'] as String?,
        focusType: _parseFocusType(json['focusType'] as String?),
        status: _parseStatus(json['status'] as String?),
        recurrenceGroupId: json['recurrenceGroupId'] as String?,
        subjectId: json['subjectId'] as String? ?? '',
        subject: subject,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse StudySession from JSON: $e\nJSON: $json',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durationMinutes': durationMinutes,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'title': title,
      'focusType': _focusTypeToString(focusType),
      'status': _statusToString(status),
      'recurrenceGroupId': recurrenceGroupId,
      'subjectId': subjectId,
      'subject': subject?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to DTO format for creating/updating
  Map<String, dynamic> toCreateDto() {
    return {
      'subjectId': subjectId,
      'durationMinutes': durationMinutes,
      if (startTime != null) 'startTime': startTime!.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      if (title != null) 'title': title,
      'focusType': _focusTypeToString(focusType),
      'status': _statusToString(status),
    };
  }

  StudySession copyWith({
    String? id,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    FocusType? focusType,
    SessionStatus? status,
    String? recurrenceGroupId,
    String? subjectId,
    Subject? subject,
    DateTime? createdAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      focusType: focusType ?? this.focusType,
      status: status ?? this.status,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      subjectId: subjectId ?? this.subjectId,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

