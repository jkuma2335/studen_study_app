import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/assignments/data/assignment_repository.dart';
import 'package:mobile_app/features/assignments/domain/assignment.dart';
import 'package:mobile_app/core/services/notification_service.dart';

class AssignmentState {
  final List<Assignment> assignments;
  final bool isLoading;
  final String? error;

  AssignmentState({
    this.assignments = const [],
    this.isLoading = false,
    this.error,
  });

  AssignmentState copyWith({
    List<Assignment>? assignments,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AssignmentState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AssignmentNotifier extends StateNotifier<AssignmentState> {
  final AssignmentRepository _repository;

  AssignmentNotifier(this._repository) : super(AssignmentState());

  Future<void> loadAssignments(String subjectId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final assignments = await _repository.getAssignments(subjectId);
      state = state.copyWith(assignments: assignments, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAllAssignments() async {
    print('🔄 [AssignmentNotifier] loadAllAssignments called');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final assignments = await _repository.getAllAssignments();
      print('✅ [AssignmentNotifier] Loaded ${assignments.length} assignments');
      state = state.copyWith(assignments: assignments, isLoading: false);
    } catch (e) {
      print('❌ [AssignmentNotifier] Error loading assignments: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addAssignment({
    required String subjectId,
    required String title,
    String? description,
    required DateTime dueDate,
    required String priority,
    String? status,
    List<String>? attachmentUrls,
  }) async {
    try {
      final createdAssignment = await _repository.createAssignment(
        subjectId,
        {
          'title': title,
          if (description != null) 'description': description,
          'dueDate': dueDate.toIso8601String(),
          'priority': priority,
          'status': status ?? 'NOT_STARTED',
          if (attachmentUrls != null && attachmentUrls.isNotEmpty)
            'attachmentUrls': attachmentUrls,
        },
      );

      // Schedule reminders for the new assignment
      try {
        final notificationService = NotificationService();
        await notificationService.scheduleAssignmentReminders(createdAssignment);
      } catch (e) {
        print('Failed to schedule assignment reminders: $e');
        // Don't fail the assignment creation if reminder scheduling fails
      }

      await loadAssignments(subjectId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateAssignment({
    required String id,
    required String subjectId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? priority,
    List<String>? attachmentUrls,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (dueDate != null) updateData['dueDate'] = dueDate.toIso8601String();
      if (status != null) updateData['status'] = status;
      if (priority != null) updateData['priority'] = priority;
      if (attachmentUrls != null) updateData['attachmentUrls'] = attachmentUrls;

      final updatedAssignment = await _repository.updateAssignment(id, updateData);

      // Reschedule reminders if due date or status changed
      if (dueDate != null || status != null) {
        try {
          final notificationService = NotificationService();
          // Cancel old reminders
          await notificationService.cancelAssignmentReminders(id);
          // Schedule new reminders if not completed
          if (updatedAssignment.status != 'COMPLETED') {
            await notificationService.scheduleAssignmentReminders(updatedAssignment);
          }
        } catch (e) {
          print('Failed to reschedule assignment reminders: $e');
          // Don't fail the assignment update if reminder scheduling fails
        }
      }

      await loadAssignments(subjectId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleAssignment(
    String id,
    String currentStatus,
    String subjectId,
  ) async {
    try {
      final updatedAssignment = await _repository.toggleComplete(id, currentStatus);
      
      // If assignment is now completed, cancel reminders
      if (updatedAssignment.status == 'COMPLETED') {
        try {
          final notificationService = NotificationService();
          await notificationService.cancelAssignmentReminders(id);
        } catch (e) {
          print('Failed to cancel assignment reminders: $e');
        }
      }

      await loadAssignments(subjectId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository();
});

final assignmentProvider = StateNotifierProvider<AssignmentNotifier, AssignmentState>((ref) {
  final repository = ref.watch(assignmentRepositoryProvider);
  return AssignmentNotifier(repository);
});

