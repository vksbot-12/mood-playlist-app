import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';

void main() {
  group('mapRecommendationErrorMessage', () {
    test('maps BAD_STATE to paywall message', () {
      expect(
        mapRecommendationErrorMessage('BAD_STATE'),
        '무료 횟수를 모두 사용했습니다. 구독 후 계속 이용할 수 있어요.',
      );
    });

    test('maps BAD_REQUEST and VALIDATION_ERROR to input message', () {
      expect(mapRecommendationErrorMessage('BAD_REQUEST'), '입력값을 확인한 뒤 다시 시도해주세요.');
      expect(mapRecommendationErrorMessage('VALIDATION_ERROR'), '입력값을 확인한 뒤 다시 시도해주세요.');
    });

    test('maps unknown code to default message', () {
      expect(mapRecommendationErrorMessage('ANYTHING'), '추천을 가져오지 못했습니다. 잠시 후 다시 시도해주세요.');
      expect(mapRecommendationErrorMessage(null), '추천을 가져오지 못했습니다. 잠시 후 다시 시도해주세요.');
    });
  });

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
