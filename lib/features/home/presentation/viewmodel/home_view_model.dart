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

String mapRecommendationErrorMessage(String? code) {
  switch (code) {
    case 'BAD_STATE':
      return '무료 횟수를 모두 사용했습니다. 구독 후 계속 이용할 수 있어요.';
    case 'BAD_REQUEST':
    case 'VALIDATION_ERROR':
      return '입력값을 확인한 뒤 다시 시도해주세요.';
    default:
      return '추천을 가져오지 못했습니다. 잠시 후 다시 시도해주세요.';
  }
}

typedef RecommendCall = Future<Map<String, dynamic>> Function(String moodText);
typedef FetchQuotaCall = Future<Map<String, dynamic>> Function();
typedef FetchShareCall = Future<Map<String, dynamic>> Function(int moodLogId);

class HomeViewModel extends StateNotifier<HomeUiState> {
  HomeViewModel(
    RecommendationRepository repository, {
    RecommendCall? recommendCall,
    FetchQuotaCall? fetchQuotaCall,
    FetchShareCall? fetchShareCall,
  })  : _recommendCall = recommendCall ?? repository.recommend,
        _fetchQuotaCall = fetchQuotaCall ?? repository.fetchMyQuota,
        _fetchShareCall = fetchShareCall ?? repository.fetchShareData,
        super(const HomeUiState(
          recommendationState: AsyncValue.data(null),
          quotaState: AsyncValue.loading(),
          recommendationErrorCode: null,
          recommendationErrorMessage: null,
        ));

  final RecommendCall _recommendCall;
  final FetchQuotaCall _fetchQuotaCall;
  final FetchShareCall _fetchShareCall;

  Future<void> initialize() async {
    await refreshQuota();
  }

  Future<void> refreshQuota() async {
    state = state.copyWith(quotaState: const AsyncValue.loading());
    final quotaState = await AsyncValue.guard(() async {
      final res = await _fetchQuotaCall();
      return (res['data']?['freeRemaining'] as num?)?.toInt();
    });
    state = state.copyWith(quotaState: quotaState);
  }

  Future<void> recommend(String moodText) async {
    state = state.copyWith(
      recommendationState: const AsyncValue.loading(),
      recommendationErrorCode: null,
      recommendationErrorMessage: null,
    );

    try {
      final data = await _recommendCall(moodText);
      state = state.copyWith(
        recommendationState: AsyncValue.data(data),
        recommendationErrorCode: null,
        recommendationErrorMessage: null,
      );
    } catch (e, st) {
      final code = _extractApiErrorCode(e);
      state = state.copyWith(
        recommendationState: AsyncValue.error(e, st),
        recommendationErrorCode: code,
        recommendationErrorMessage: mapRecommendationErrorMessage(code),
      );
    }

    await refreshQuota();
  }

  Future<String?> fetchShareContent() async {
    final data = state.recommendationState.value;
    final moodLogId = data?['data']?['moodLogId'];
    if (moodLogId == null) return null;
    final res = await _fetchShareCall(moodLogId as int);
    return res['data']?['content']?.toString();
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
    required this.recommendationErrorMessage,
  });

  static const _noChange = Object();

  final AsyncValue<Map<String, dynamic>?> recommendationState;
  final AsyncValue<int?> quotaState;
  final String? recommendationErrorCode;
  final String? recommendationErrorMessage;

  HomeUiState copyWith({
    AsyncValue<Map<String, dynamic>?>? recommendationState,
    AsyncValue<int?>? quotaState,
    Object? recommendationErrorCode = _noChange,
    Object? recommendationErrorMessage = _noChange,
  }) {
    return HomeUiState(
      recommendationState: recommendationState ?? this.recommendationState,
      quotaState: quotaState ?? this.quotaState,
      recommendationErrorCode: recommendationErrorCode == _noChange
          ? this.recommendationErrorCode
          : recommendationErrorCode as String?,
      recommendationErrorMessage: recommendationErrorMessage == _noChange
          ? this.recommendationErrorMessage
          : recommendationErrorMessage as String?,
    );
  }
}
