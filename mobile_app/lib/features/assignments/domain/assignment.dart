import 'package:mobile_app/features/subjects/domain/subject.dart';

class Assignment {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status; // 'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'
  final String priority;
  final List<String> attachmentUrls;
  final String subjectId;
  final Subject? subject; // Optional subject data from backend
  final DateTime createdAt;
  final DateTime updatedAt;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.attachmentUrls = const [],
    required this.subjectId,
    this.subject,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if the assignment is overdue
  bool get isOverdue {
    return dueDate.isBefore(DateTime.now()) && status != 'COMPLETED';
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
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

      // Parse attachmentUrls
      List<String> attachmentUrls = [];
      if (json['attachmentUrls'] != null && json['attachmentUrls'] is List) {
        attachmentUrls = (json['attachmentUrls'] as List<dynamic>)
            .map((url) => url.toString())
            .toList();
      }

      // Parse status - handle migration from isCompleted if needed
      String status = json['status'] as String? ?? 'NOT_STARTED';
      if (json['isCompleted'] != null && json['status'] == null) {
        // Migration: convert old isCompleted to new status
        status = (json['isCompleted'] as bool? ?? false) 
            ? 'COMPLETED' 
            : 'NOT_STARTED';
      }

      return Assignment(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : DateTime.now(),
        status: status,
        priority: json['priority'] as String? ?? 'Medium',
        attachmentUrls: attachmentUrls,
        subjectId: json['subjectId'] as String? ?? '',
        subject: subject,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse Assignment from JSON: $e\nJSON: $json',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'attachmentUrls': attachmentUrls,
      'subjectId': subjectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateDto() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
      if (attachmentUrls.isNotEmpty) 'attachmentUrls': attachmentUrls,
    };
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? priority,
    List<String>? attachmentUrls,
    String? subjectId,
    Subject? subject,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      subjectId: subjectId ?? this.subjectId,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

