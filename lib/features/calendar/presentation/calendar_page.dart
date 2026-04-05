import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_playlist_app/features/calendar/presentation/viewmodel/calendar_view_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('감정 캘린더')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (data) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: data.focusedMonth,
                selectedDayPredicate: (day) => isSameDay(day, data.selectedDate),
                onPageChanged: (day) {
                  ref.read(calendarViewModelProvider.notifier).onPageChanged(day);
                },
                onDaySelected: (selectedDay, _) {
                  ref.read(calendarViewModelProvider.notifier).onDaySelected(selectedDay);
                },
                eventLoader: (day) {
                  final normalized = DateTime(day.year, day.month, day.day);
                  final count = data.countsByDate[normalized] ?? 0;
                  return count > 0 ? List.filled(count, 'entry') : const [];
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: data.dayItems.isEmpty
                    ? const Center(child: Text('선택한 날짜의 감정 기록이 없습니다.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.dayItems.length,
                        itemBuilder: (context, index) {
                          final item = data.dayItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.moodText, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 6),
                                  Text(item.createdAt, style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 10),
                                  ...item.candidates.map(
                                    (candidate) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          '${candidate.rank}. ${candidate.title}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: const Icon(Icons.open_in_new, size: 18),
                                        onTap: () async {
                                          final uri = candidate.launchUri();
                                          if (uri == null) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('열 수 있는 링크가 없습니다.')),
                                              );
                                            }
                                            return;
                                          }

                                          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                          if (!launched && context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('링크 열기에 실패했습니다.')),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
