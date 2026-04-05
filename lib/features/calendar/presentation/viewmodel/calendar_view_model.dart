import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_playlist_app/features/home/data/recommendation_repository.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';

final calendarViewModelProvider =
    StateNotifierProvider<CalendarViewModel, CalendarUiState>(
  (ref) => CalendarViewModel(ref.watch(recommendationRepositoryProvider))..initialize(),
);

class CalendarViewModel extends StateNotifier<CalendarUiState> {
  CalendarViewModel(this._repository)
      : super(
          CalendarUiState(
            focusedMonth: DateTime.now(),
            selectedDate: DateTime.now(),
            countsByDate: const {},
            dayItems: const [],
            isMonthLoading: true,
            isDayLoading: true,
          ),
        );

  final RecommendationRepository _repository;

  Future<void> initialize() async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    state = state.copyWith(focusedMonth: month, selectedDate: now);
    await _loadMonth(month);
    await _loadDay(now);
  }

  Future<void> onPageChanged(DateTime focusedMonth) async {
    final month = DateTime(focusedMonth.year, focusedMonth.month, 1);
    state = state.copyWith(focusedMonth: month, isMonthLoading: true, errorMessage: null);
    await _loadMonth(month);
  }

  Future<void> onDaySelected(DateTime selectedDate) async {
    state = state.copyWith(
      selectedDate: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      isDayLoading: true,
      errorMessage: null,
    );
    await _loadDay(selectedDate);
  }

  Future<void> _loadMonth(DateTime focusedMonth) async {
    try {
      final monthRes = await _repository.fetchCalendar(focusedMonth.year, focusedMonth.month);
      final daysRaw = monthRes['data']?['days'] as Map<String, dynamic>? ?? {};

      final countsByDate = <DateTime, int>{};
      daysRaw.forEach((key, value) {
        final date = DateTime.tryParse(key);
        if (date != null) {
          countsByDate[DateTime(date.year, date.month, date.day)] = (value as num?)?.toInt() ?? 0;
        }
      });

      state = state.copyWith(countsByDate: countsByDate, isMonthLoading: false);
    } catch (e) {
      state = state.copyWith(isMonthLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> _loadDay(DateTime selectedDate) async {
    try {
      final dayRes = await _repository.fetchDayDetail(selectedDate);
      final dayItemsRaw = dayRes['data']?['items'] as List<dynamic>? ?? [];

      final dayItems = dayItemsRaw.whereType<Map<String, dynamic>>().map((e) {
        final candidates = (e['candidates'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().map((c) {
          return CandidateUiItem(
            rank: (c['rank'] as num?)?.toInt() ?? 0,
            title: c['title']?.toString() ?? '',
            reason: c['reason']?.toString() ?? '',
            emotionLink: c['emotionLink']?.toString() ?? '',
            youtubeUrl: c['youtubeUrl']?.toString(),
            youtubeQuery: c['youtubeQuery']?.toString(),
          );
        }).toList();

        return DayDetailUiItem(
          moodText: e['moodText']?.toString() ?? '',
          createdAt: e['createdAt']?.toString() ?? '',
          candidates: candidates,
        );
      }).toList();

      state = state.copyWith(dayItems: dayItems, isDayLoading: false);
    } catch (e) {
      state = state.copyWith(isDayLoading: false, errorMessage: e.toString());
    }
  }
}

class CalendarUiState {
  const CalendarUiState({
    required this.focusedMonth,
    required this.selectedDate,
    required this.countsByDate,
    required this.dayItems,
    this.isMonthLoading = false,
    this.isDayLoading = false,
    this.errorMessage,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Map<DateTime, int> countsByDate;
  final List<DayDetailUiItem> dayItems;
  final bool isMonthLoading;
  final bool isDayLoading;
  final String? errorMessage;

  CalendarUiState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDate,
    Map<DateTime, int>? countsByDate,
    List<DayDetailUiItem>? dayItems,
    bool? isMonthLoading,
    bool? isDayLoading,
    String? errorMessage,
  }) {
    return CalendarUiState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      countsByDate: countsByDate ?? this.countsByDate,
      dayItems: dayItems ?? this.dayItems,
      isMonthLoading: isMonthLoading ?? this.isMonthLoading,
      isDayLoading: isDayLoading ?? this.isDayLoading,
      errorMessage: errorMessage,
    );
  }
}

class DayDetailUiItem {
  const DayDetailUiItem({
    required this.moodText,
    required this.createdAt,
    required this.candidates,
  });

  final String moodText;
  final String createdAt;
  final List<CandidateUiItem> candidates;
}

class CandidateUiItem {
  const CandidateUiItem({
    required this.rank,
    required this.title,
    required this.reason,
    required this.emotionLink,
    this.youtubeUrl,
    this.youtubeQuery,
  });

  final int rank;
  final String title;
  final String reason;
  final String emotionLink;
  final String? youtubeUrl;
  final String? youtubeQuery;

  Uri? launchUri() {
    final rawUrl = youtubeUrl?.trim();
    if (rawUrl != null && rawUrl.isNotEmpty) {
      return Uri.tryParse(rawUrl);
    }

    final query = youtubeQuery?.trim();
    if (query != null && query.isNotEmpty) {
      return Uri.https('www.youtube.com', '/results', {'search_query': query});
    }

    return null;
  }
}
