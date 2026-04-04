import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 감정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '지금 기분을 자유롭게 적어주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(homeViewModelProvider.notifier).recommend(_controller.text),
              child: const Text('추천 받기'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(onPressed: () => context.push('/calendar'), child: const Text('캘린더')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => context.push('/subscription'), child: const Text('구독')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.when(
                data: (data) {
                  if (data == null) return const Center(child: Text('추천 결과가 여기에 표시됩니다.'));
                  final list = ((data['data']?['candidates']) ?? []) as List;
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index] as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text('${item['rank']}. ${item['title']}'),
                          subtitle: Text(item['reason']?.toString() ?? ''),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('오류: $e')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
