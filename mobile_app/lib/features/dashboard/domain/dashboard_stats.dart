import 'package:mobile_app/features/assignments/domain/assignment.dart';

class DashboardStats {
  final int pendingCount;
  final int studyMinutesToday;
  final List<Assignment> recentAssignments;

  DashboardStats({
    required this.pendingCount,
    required this.studyMinutesToday,
    required this.recentAssignments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pendingCount: json['assignmentsPending'] as int? ?? 0,
      studyMinutesToday: json['studyMinutesToday'] as int? ?? 0,
      recentAssignments: (json['assignmentsDueSoon'] as List<dynamic>?)
              ?.map((item) => Assignment.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentsPending': pendingCount,
      'studyMinutesToday': studyMinutesToday,
      'assignmentsDueSoon': recentAssignments.map((a) => a.toJson()).toList(),
    };
  }
}

