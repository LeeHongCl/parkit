import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/chat_providers.dart';
import 'providers/parking_recommend_providers.dart';

/// 네이버 지도의 AI 검색창과 비슷한 흐름: 홈 화면 입력창에 텍스트를 넣으면
/// 이 화면으로 넘어오고, 답변에 주차장이 포함되면 바로 상세로 이동할 수 있다.
/// 실제 LLM 호출은 아니고(chat_query_parser.dart 참고), 규칙 기반으로 조건을
/// 해석해 기존 recommend API를 호출한다.
class ChatScreen extends ConsumerStatefulWidget {
  final String? initialPrompt;

  const ChatScreen({super.key, this.initialPrompt});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final prompt = widget.initialPrompt;
    if (prompt != null && prompt.trim().isNotEmpty) {
      Future.microtask(() => ref.read(chatMessagesProvider.notifier).send(prompt));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(chatMessagesProvider.notifier).send(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final loading = ref.watch(chatLoadingProvider);
    final durationMinutes = ref.watch(durationMinutesProvider);
    final dataUpdatedDate = ref.watch(metaResultProvider).value?.displayDate;

    ref.listen(chatMessagesProvider, (previous, next) => _scrollToBottom());
    ref.listen(chatLoadingProvider, (previous, next) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(title: const Text('AI에게 물어보기')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty && !loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        '원하는 조건을 자유롭게 입력해보세요.\n예: "동성로 근처 저렴한 주차장 찾아줘"',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= messages.length) {
                        return const _TypingBubble();
                      }
                      final message = messages[index];
                      return _ChatBubble(
                        message: message,
                        onViewDetail: message.item == null
                            ? null
                            : () => context.push('/detail', extra: {
                                  'item': message.item,
                                  'durationMinutes': durationMinutes,
                                  'dataUpdatedDate': dataUpdatedDate,
                                }),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '예: 비 오는 날 가까운 실내주차장 추천해줘',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: loading ? null : _submit,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onViewDetail;

  const _ChatBubble({required this.message, required this.onViewDetail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primaryContainer
              : message.isError
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text),
            if (onViewDetail != null) ...[
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: onViewDetail,
                icon: const Icon(Icons.local_parking, size: 18),
                label: const Text('주차장 확인하기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('찾아보는 중...'),
          ],
        ),
      ),
    );
  }
}
