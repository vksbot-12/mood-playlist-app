import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_playlist_app/core/network/api_client.dart';
import 'package:mood_playlist_app/features/home/data/recommendation_repository.dart';

final apiClientProvider = Provider((_) => ApiClient(const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080')));
final recommendationRepositoryProvider = Provider((ref) => RecommendationRepository(ref.watch(apiClientProvider).dio));

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, AsyncValue<Map<String, dynamic>?>>(
  (ref) => HomeViewModel(ref.watch(recommendationRepositoryProvider)),
);

class HomeViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  HomeViewModel(this._repository) : super(const AsyncValue.data(null));

  final RecommendationRepository _repository;

  Future<void> recommend(String moodText) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.recommend(moodText));
  }

  Future<String?> fetchShareContent() async {
    final data = state.value;
    final moodLogId = data?['data']?['moodLogId'];
    if (moodLogId == null) return null;
    final res = await _repository.fetchShareData(moodLogId as int);
    return res['data']?['content']?.toString();
  }
}
