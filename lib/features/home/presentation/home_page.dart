import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_playlist_app/features/home/presentation/viewmodel/home_view_model.dart';
import 'package:share_plus/share_plus.dart';

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
    final recommendationState = state.recommendationState;
    final quotaState = state.quotaState;
    final isRecommending = recommendationState.isLoading;
    final isQuotaLoading = quotaState.isLoading;
    final canRecommend = !isRecommending && !isQuotaLoading;

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
            const SizedBox(height: 12),
            _QuotaStatusCard(
              quotaState: quotaState,
              onRetry: () => ref.read(homeViewModelProvider.notifier).refreshQuota(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: canRecommend
                  ? () => ref.read(homeViewModelProvider.notifier).recommend(_controller.text)
                  : null,
              child: isRecommending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isQuotaLoading ? '잔여 횟수 확인 중...' : '추천 받기'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(onPressed: () => context.push('/calendar'), child: const Text('캘린더')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => context.push('/subscription'), child: const Text('구독')),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final text = await ref.read(homeViewModelProvider.notifier).fetchShareContent();
                    if (text != null && context.mounted) {
                      Share.share(text);
                    }
                  },
                  child: const Text('공유'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: recommendationState.when(
                data: (data) {
                  if (data == null) return const Center(child: Text('추천 결과가 여기에 표시됩니다.'));
                  final list = ((data['data']?['candidates']) ?? []) as List;
                  final freeRemaining = (data['data']?['freeRemaining'] as num?)?.toInt();
                  final exhausted = (freeRemaining ?? 0) <= 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exhausted)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/subscription'),
                            icon: const Icon(Icons.workspace_premium),
                            label: const Text('무료 횟수 소진됨 · 구독 안내 보기'),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
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
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) {
                  final message = state.recommendationErrorMessage ?? '오류: $e';
                  final isQuotaExhausted = state.recommendationErrorCode == 'BAD_STATE';

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message, textAlign: TextAlign.center),
                        if (isQuotaExhausted) ...[
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.push('/subscription'),
                            child: const Text('구독하러 가기'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _QuotaStatusCard extends StatelessWidget {
  const _QuotaStatusCard({
    required this.quotaState,
    required this.onRetry,
  });

  final AsyncValue<int?> quotaState;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: quotaState.when(
          data: (remaining) => Row(
            children: [
              const Icon(Icons.bolt, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  remaining == null ? '무료 잔여 횟수 확인 불가' : '현재 무료 잔여: $remaining회',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          loading: () => const Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('무료 잔여 조회 중...'),
            ],
          ),
          error: (_, __) => Row(
            children: [
              const Expanded(child: Text('무료 잔여 조회 실패')),
              TextButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ),
        ),
      ),
    );
  }
}
