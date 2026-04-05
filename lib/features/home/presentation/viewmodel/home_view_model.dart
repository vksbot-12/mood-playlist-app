import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_playlist_app/core/network/api_client.dart';
import 'package:mood_playlist_app/features/home/data/recommendation_repository.dart';

final apiClientProvider =
    Provider((_) => ApiClient(const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080')));
final recommendationRepositoryProvider =
    Provider((ref) => RecommendationRepository(ref.watch(apiClientProvider).dio));

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeUiState>(
  (ref) => HomeViewModel(ref.watch(recommendationRepositoryProvider))..initialize(),
);

class HomeViewModel extends StateNotifier<HomeUiState> {
  HomeViewModel(this._repository)
      : super(const HomeUiState(
          recommendationState: AsyncValue.data(null),
          quotaState: AsyncValue.loading(),
          recommendationErrorCode: null,
        ));

  final RecommendationRepository _repository;

  Future<void> initialize() async {
    await refreshQuota();
  }

  Future<void> refreshQuota() async {
    state = state.copyWith(quotaState: const AsyncValue.loading());
    final quotaState = await AsyncValue.guard(() async {
      final res = await _repository.fetchMyQuota();
      return (res['data']?['freeRemaining'] as num?)?.toInt();
    });
    state = state.copyWith(quotaState: quotaState);
  }

  Future<void> recommend(String moodText) async {
    state = state.copyWith(
      recommendationState: const AsyncValue.loading(),
      recommendationErrorCode: null,
    );

    try {
      final data = await _repository.recommend(moodText);
      state = state.copyWith(
        recommendationState: AsyncValue.data(data),
        recommendationErrorCode: null,
      );
    } catch (e, st) {
      state = state.copyWith(
        recommendationState: AsyncValue.error(e, st),
        recommendationErrorCode: _extractApiErrorCode(e),
      );
    }

    await refreshQuota();
  }

  Future<String?> fetchShareContent() async {
    final data = state.recommendationState.value;
    final moodLogId = data?['data']?['moodLogId'];
    if (moodLogId == null) return null;
    final res = await _repository.fetchShareData(moodLogId as int);
    return res['data']?['content']?.toString();
  }
}

  String? _extractApiErrorCode(Object error) {
    if (error is! DioException) return null;
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return data['error']?['code']?.toString();
    }
    return null;
  }
}

class HomeUiState {
  const HomeUiState({
    required this.recommendationState,
    required this.quotaState,
    required this.recommendationErrorCode,
  });

  static const _noChange = Object();

  final AsyncValue<Map<String, dynamic>?> recommendationState;
  final AsyncValue<int?> quotaState;
  final String? recommendationErrorCode;

  HomeUiState copyWith({
    AsyncValue<Map<String, dynamic>?>? recommendationState,
    AsyncValue<int?>? quotaState,
    Object? recommendationErrorCode = _noChange,
  }) {
    return HomeUiState(
      recommendationState: recommendationState ?? this.recommendationState,
      quotaState: quotaState ?? this.quotaState,
      recommendationErrorCode: recommendationErrorCode == _noChange
          ? this.recommendationErrorCode
          : recommendationErrorCode as String?,
    );
  }
}
