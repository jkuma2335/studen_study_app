import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/features/analytics/data/analytics_repository.dart';
import 'package:mobile_app/features/analytics/domain/analytics_models.dart';

class AnalyticsState {
  final bool isLoading;
  final String? error;
  final AnalyticsData? data;

  AnalyticsState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    AnalyticsData? data,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsNotifier(this._repository) : super(AnalyticsState());

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repository.getAllAnalytics();
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadAnalytics();
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ApiClient());
});

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.read(analyticsRepositoryProvider));
});
