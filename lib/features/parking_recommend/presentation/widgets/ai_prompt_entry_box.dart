import 'package:flutter/material.dart';

/// 네이버 지도 스타일의 AI 검색창. 입력 후 전송하면 챗봇 화면으로 넘어간다.
class AiPromptEntryBox extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const AiPromptEntryBox({super.key, required this.onSubmit});

  @override
  State<AiPromptEntryBox> createState() => _AiPromptEntryBoxState();
}

class _AiPromptEntryBoxState extends State<AiPromptEntryBox> {
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'AI에게 물어보기 (예: 동성로 근처 저렴한 주차장)',
                border: InputBorder.none,
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: theme.colorScheme.primary,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
