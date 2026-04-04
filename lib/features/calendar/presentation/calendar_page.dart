import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_playlist_app/features/home/data/recommendation_repository.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

final calendarProvider = FutureProvider.family<Map<String, dynamic>, DateTime>((ref, month) async {
  final repo = ref.watch(recommendationRepositoryProvider);
  return repo.fetchCalendar(month.year, month.month);
});

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime focused = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final monthData = ref.watch(calendarProvider(focused));
    return Scaffold(
      appBar: AppBar(title: const Text('감정 캘린더')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focused,
            onPageChanged: (d) => setState(() => focused = d),
          ),
          Expanded(
            child: monthData.when(
              data: (data) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('월 데이터: ${data['data']?['days'] ?? {}}'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          )
        ],
      ),
    );
  }
}
