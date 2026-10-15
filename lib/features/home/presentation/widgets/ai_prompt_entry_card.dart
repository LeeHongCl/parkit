import 'package:flutter/material.dart';

/// 홈 화면에 배치되는 AI 대화형 추천 요청 입력 영역.
/// 실제 AI 추천 로직은 백엔드/LLM 연동 후 구현 예정이며, 여기서는 사용자가
/// 자연어로 요청을 입력하고 전달하는 UI만 제공한다.
class AiPromptEntryCard extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const AiPromptEntryCard({super.key, required this.onSubmit});

  @override
  State<AiPromptEntryCard> createState() => _AiPromptEntryCardState();
}

class _AiPromptEntryCardState extends State<AiPromptEntryCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('AI에게 추천 요청하기', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '예: 비 오는 날 가까운 실내주차장 추천해줘',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '원하는 조건을 자유롭게 입력해보세요',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _submit,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
