import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/study-sessions/data/study_session_repository.dart';
import 'package:mobile_app/features/planner/presentation/planner_provider.dart';
import 'package:mobile_app/features/planner/domain/study_session.dart' as planner;

class TimerState {
  final bool isRunning;
  final int timeLeft; // in seconds
  final String? selectedSubjectId;
  final DateTime? startTime;
  final String? plannerSessionId; // ID of the planner session being tracked

  TimerState({
    this.isRunning = false,
    this.timeLeft = 1500, // 25 minutes in seconds
    this.selectedSubjectId,
    this.startTime,
    this.plannerSessionId,
  });

  TimerState copyWith({
    bool? isRunning,
    int? timeLeft,
    String? selectedSubjectId,
    DateTime? startTime,
    String? plannerSessionId,
  }) {
    return TimerState(
      isRunning: isRunning ?? this.isRunning,
      timeLeft: timeLeft ?? this.timeLeft,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      startTime: startTime ?? this.startTime,
      plannerSessionId: plannerSessionId ?? this.plannerSessionId,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final StudySessionRepository _repository;
  Timer? _timer;

  TimerNotifier(this._repository) : super(TimerState());

  /// Initialize timer with planner session details
  void initializeFromPlanner({
    required String subjectId,
    required String plannerSessionId,
    int? durationMinutes,
    bool autoStart = false,
  }) {
    final duration = durationMinutes ?? 25;
    state = state.copyWith(
      selectedSubjectId: subjectId,
      plannerSessionId: plannerSessionId,
      timeLeft: duration * 60, // Convert minutes to seconds
    );

    if (autoStart) {
      startTimer();
    }
  }

  void startTimer() {
    if (state.selectedSubjectId == null) {
      return; // Can't start without a subject
    }

    if (state.isRunning) {
      return; // Already running
    }

    state = state.copyWith(
      isRunning: true,
      startTime: state.startTime ?? DateTime.now(),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    stopTimer();
    state = state.copyWith(
      timeLeft: 1500, // Reset to 25 minutes
      startTime: null,
    );
  }

  void setSubject(String? subjectId) {
    if (!state.isRunning) {
      state = state.copyWith(selectedSubjectId: subjectId);
    }
  }

  int get elapsedTimeSeconds {
    return 1500 - state.timeLeft;
  }

  Future<void> saveSession() async {
    if (state.selectedSubjectId == null) {
      throw Exception('No subject selected');
    }

    final elapsedSeconds = elapsedTimeSeconds;
    
    if (elapsedSeconds <= 0) {
      throw Exception('No time was studied');
    }

    // Calculate duration in minutes (round up to ensure at least 1 minute if any time elapsed)
    final durationMinutes = (elapsedSeconds / 60).ceil();
    
    if (durationMinutes <= 0) {
      throw Exception('Study session too short');
    }

    // If this is a planner session, we'll update it from the TimerScreen
    // For now, still create a session (the TimerScreen will handle the update)
    if (state.plannerSessionId == null) {
      await _repository.logSession(
        subjectId: state.selectedSubjectId!,
        durationMinutes: durationMinutes,
        startTime: state.startTime,
      );
    }
    // Note: Planner session update is handled in TimerScreen

    resetTimer();
  }
}

final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return StudySessionRepository();
});

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final repository = ref.watch(studySessionRepositoryProvider);
  return TimerNotifier(repository);
});

