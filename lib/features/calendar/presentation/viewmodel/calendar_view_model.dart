import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_playlist_app/features/home/data/recommendation_repository.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';

final calendarViewModelProvider =
    StateNotifierProvider<CalendarViewModel, AsyncValue<CalendarUiState>>(
  (ref) => CalendarViewModel(ref.watch(recommendationRepositoryProvider))..initialize(),
);

class CalendarViewModel extends StateNotifier<AsyncValue<CalendarUiState>> {
  CalendarViewModel(this._repository) : super(const AsyncValue.loading());

  final RecommendationRepository _repository;

  Future<void> initialize() async {
    final now = DateTime.now();
    await _load(now, now);
  }

  Future<void> onPageChanged(DateTime focusedMonth) async {
    final selectedDate = state.value?.selectedDate ?? focusedMonth;
    await _load(DateTime(focusedMonth.year, focusedMonth.month, 1), selectedDate);
  }

  Future<void> onDaySelected(DateTime selectedDate) async {
    final focusedMonth = state.value?.focusedMonth ?? DateTime(selectedDate.year, selectedDate.month, 1);
    await _load(focusedMonth, selectedDate);
  }

  Future<void> _load(DateTime focusedMonth, DateTime selectedDate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final monthRes = await _repository.fetchCalendar(focusedMonth.year, focusedMonth.month);
      final dayRes = await _repository.fetchDayDetail(selectedDate);

      final daysRaw = monthRes['data']?['days'] as Map<String, dynamic>? ?? {};
      final dayItemsRaw = dayRes['data']?['items'] as List<dynamic>? ?? [];

      final countsByDate = <DateTime, int>{};
      daysRaw.forEach((key, value) {
        final date = DateTime.tryParse(key);
        if (date != null) {
          countsByDate[DateTime(date.year, date.month, date.day)] = (value as num?)?.toInt() ?? 0;
        }
      });

      final dayItems = dayItemsRaw
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => DayDetailUiItem(
              moodText: e['moodText']?.toString() ?? '',
              createdAt: e['createdAt']?.toString() ?? '',
              candidates:
                  (e['candidates'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList(),
            ),
          )
          .toList();

      return CalendarUiState(
        focusedMonth: DateTime(focusedMonth.year, focusedMonth.month, 1),
        selectedDate: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
        countsByDate: countsByDate,
        dayItems: dayItems,
      );
    });
  }
}

class CalendarUiState {
  const CalendarUiState({
    required this.focusedMonth,
    required this.selectedDate,
    required this.countsByDate,
    required this.dayItems,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Map<DateTime, int> countsByDate;
  final List<DayDetailUiItem> dayItems;
}

class DayDetailUiItem {
  const DayDetailUiItem({
    required this.moodText,
    required this.createdAt,
    required this.candidates,
  });

  final String moodText;
  final String createdAt;
  final List<Map<String, dynamic>> candidates;
}
