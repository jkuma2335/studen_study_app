import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/planner/data/planner_repository.dart';
import 'package:mobile_app/features/planner/domain/study_session.dart';

class PlannerState {
  final List<StudySession> sessions;
  final bool isLoading;
  final String? error;
  final DateTime? currentWeekStart;

  PlannerState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.currentWeekStart,
  });

  PlannerState copyWith({
    List<StudySession>? sessions,
    bool? isLoading,
    String? error,
    DateTime? currentWeekStart,
  }) {
    return PlannerState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentWeekStart: currentWeekStart ?? this.currentWeekStart,
    );
  }
}

class PlannerNotifier extends StateNotifier<PlannerState> {
  final PlannerRepository _repository;

  PlannerNotifier(this._repository) : super(PlannerState());

  /// Load sessions for a week (7 days starting from the given date)
  Future<void> loadWeek(DateTime date) async {
    // Calculate week start (Monday) and end (Sunday)
    final weekStart = _getWeekStart(date);
    final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    state = state.copyWith(isLoading: true, error: null, currentWeekStart: weekStart);
    
    try {
      final sessions = await _repository.getSessions(weekStart, weekEnd);
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get the start of the week (Monday) for a given date
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  /// Create a recurring study session
  /// This method prepares the payload and calls the backend
  Future<void> createRecurringSession({
    required String subjectId,
    required int durationMinutes,
    required DateTime startTime,
    required String frequency, // 'DAILY' or 'WEEKLY'
    List<int>? daysOfWeek, // For WEEKLY: [1,3,5] = Mon, Wed, Fri (1=Mon, 7=Sun)
    required DateTime until,
    String? title,
    FocusType? focusType,
    SessionStatus? status,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'subjectId': subjectId,
        'durationMinutes': durationMinutes,
        'startTime': startTime.toIso8601String(),
        if (title != null) 'title': title,
        if (focusType != null)
          'focusType': _focusTypeToString(focusType),
        if (status != null) 'status': _statusToString(status),
        'recurrenceRule': {
          'frequency': frequency,
          if (frequency == 'DAILY') 'each': 1, // Every 1 day for daily recurrence
          if (daysOfWeek != null && frequency == 'WEEKLY') 'days': daysOfWeek,
          'until': until.toIso8601String(),
        },
      };

      // The backend will create all recurring sessions
      await _repository.createSession(payload);

      // Reload the current week to show the new sessions
      if (state.currentWeekStart != null) {
        await loadWeek(state.currentWeekStart!);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Create a single study session
  Future<void> createSession({
    required String subjectId,
    required int durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    FocusType? focusType,
    SessionStatus? status,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'subjectId': subjectId,
        'durationMinutes': durationMinutes,
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime.toIso8601String(),
        if (title != null) 'title': title,
        if (focusType != null) 'focusType': _focusTypeToString(focusType),
        if (status != null) 'status': _statusToString(status),
      };

      await _repository.createSession(payload);

      // Reload the current week to show the new session
      if (state.currentWeekStart != null) {
        await loadWeek(state.currentWeekStart!);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Update session status
  Future<void> updateSessionStatus(String sessionId, SessionStatus status) async {
    try {
      await _repository.updateStatus(sessionId, _statusToString(status));

      // Update local state
      final updatedSessions = state.sessions.map((session) {
        if (session.id == sessionId) {
          return session.copyWith(status: status);
        }
        return session;
      }).toList();

      state = state.copyWith(sessions: updatedSessions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Helper: Convert FocusType to string
  String _focusTypeToString(FocusType focusType) {
    switch (focusType) {
      case FocusType.deepFocus:
        return 'DEEP_FOCUS';
      case FocusType.revision:
        return 'REVISION';
      case FocusType.practice:
        return 'PRACTICE';
    }
  }

  /// Helper: Convert SessionStatus to string
  String _statusToString(SessionStatus status) {
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
}

// Providers
final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository();
});

final plannerProvider =
    StateNotifierProvider<PlannerNotifier, PlannerState>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return PlannerNotifier(repository);
});

