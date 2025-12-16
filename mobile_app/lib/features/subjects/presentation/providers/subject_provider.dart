import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/subjects/data/subject_repository.dart';
import 'package:mobile_app/features/subjects/domain/subject.dart';
import 'package:mobile_app/features/subjects/domain/schedule_model.dart';
import 'package:mobile_app/core/services/notification_service.dart';

class SubjectState {
  final List<Subject> subjects;
  final bool isLoading;
  final String? error;

  SubjectState({
    this.subjects = const [],
    this.isLoading = false,
    this.error,
  });

  SubjectState copyWith({
    List<Subject>? subjects,
    bool? isLoading,
    String? error,
  }) {
    return SubjectState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SubjectNotifier extends StateNotifier<SubjectState> {
  final SubjectRepository _repository;

  SubjectNotifier(this._repository) : super(SubjectState()) {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subjects = await _repository.getSubjects();
      state = state.copyWith(subjects: subjects, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createSubject({
    required String name,
    String? color,
    String? teacherName,
    String? teacherEmail,
    String? teacherPhone,
    double? studyGoalHours,
    String? category,
    String? difficulty,
    List<ScheduleItem>? schedules,
  }) async {
    try {
      final createdSubject = await _repository.createSubject(
        name: name,
        color: color,
        teacherName: teacherName,
        teacherEmail: teacherEmail,
        teacherPhone: teacherPhone,
        studyGoalHours: studyGoalHours,
        category: category,
        difficulty: difficulty,
        schedules: schedules,
      );
      
      // Schedule reminders for each class schedule
      if (schedules != null && schedules.isNotEmpty) {
        final notificationService = NotificationService();
        for (final schedule in schedules) {
          try {
            await notificationService.scheduleClassReminder(
              schedule,
              name,
            );
          } catch (e) {
            // Log error but don't fail the subject creation
            print('Failed to schedule reminder for ${schedule.dayOfWeek}: $e');
          }
        }
      }
      
      await loadSubjects();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateSubject({
    required String id,
    String? name,
    String? color,
    String? teacherName,
    String? teacherEmail,
    String? teacherPhone,
    double? studyGoalHours,
    String? category,
    String? difficulty,
    List<ScheduleItem>? schedules,
  }) async {
    try {
      final updatedSubject = await _repository.updateSubject(
        id: id,
        name: name,
        color: color,
        teacherName: teacherName,
        teacherEmail: teacherEmail,
        teacherPhone: teacherPhone,
        studyGoalHours: studyGoalHours,
        category: category,
        difficulty: difficulty,
        schedules: schedules,
      );
      
      // Schedule reminders for new schedules if provided
      if (schedules != null && schedules.isNotEmpty) {
        final notificationService = NotificationService();
        for (final schedule in schedules) {
          try {
            await notificationService.scheduleClassReminder(
              schedule,
              updatedSubject.name,
            );
          } catch (e) {
            // Log error but don't fail the subject update
            print('Failed to schedule reminder for ${schedule.dayOfWeek}: $e');
          }
        }
      }
      
      await loadSubjects();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      await loadSubjects();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

final subjectProvider = StateNotifierProvider<SubjectNotifier, SubjectState>((ref) {
  final repository = ref.watch(subjectRepositoryProvider);
  return SubjectNotifier(repository);
});

