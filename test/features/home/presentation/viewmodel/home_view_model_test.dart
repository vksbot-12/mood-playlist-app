import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';

void main() {
  group('HomeUiState.copyWith', () {
    const initial = HomeUiState(
      recommendationState: AsyncValue.data({'data': {'moodLogId': 1}}),
      quotaState: AsyncValue.data(7),
      recommendationErrorCode: 'BAD_REQUEST',
      recommendationErrorMessage: '입력값 오류',
    );

    test('keeps optional fields when not provided', () {
      final updated = initial.copyWith(quotaState: const AsyncValue.data(5));

      expect(updated.quotaState.value, 5);
      expect(updated.recommendationErrorCode, 'BAD_REQUEST');
      expect(updated.recommendationErrorMessage, '입력값 오류');
      expect(updated.recommendationState.value?['data']?['moodLogId'], 1);
    });

    test('clears error fields when explicit null provided', () {
      final updated = initial.copyWith(
        recommendationErrorCode: null,
        recommendationErrorMessage: null,
      );

      expect(updated.recommendationErrorCode, isNull);
      expect(updated.recommendationErrorMessage, isNull);
    });
  });
}
