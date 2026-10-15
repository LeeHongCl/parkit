import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AI 대화형 추천 화면의 자리표시(placeholder) 버전.
/// 실제 LLM/백엔드 연동 전까지는 입력된 요청을 그대로 보여주고,
/// 조건 기반 추천(/recommendation)으로 안내하는 역할만 한다.
/// 임의의 추천 결과를 지어내지 않는다.
class AiRecommendationScreen extends StatelessWidget {
  final String initialPrompt;

  const AiRecommendationScreen({super.key, required this.initialPrompt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AI 추천 (준비 중)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(initialPrompt),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('AI 추천', style: theme.textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'AI 대화형 추천은 백엔드/LLM 연동 후 제공될 예정입니다.\n'
                    '지금은 조건 기반 추천을 이용해 주차 시간·추천 유형에 맞는 결과를 받아보실 수 있어요.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/recommendation'),
            icon: const Icon(Icons.tune),
            label: const Text('조건 기반 추천 받으러 가기'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}
