import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/recommend_item.dart';
import '../../data/parking_api_client.dart';
import '../../domain/chat_query_parser.dart';
import 'parking_recommend_providers.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final RecommendItem? item;
  final bool isError;

  const ChatMessage({
    required this.isUser,
    required this.text,
    this.item,
    this.isError = false,
  });
}

class ChatLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final chatLoadingProvider = NotifierProvider<ChatLoadingNotifier, bool>(
  ChatLoadingNotifier.new,
);

class ChatMessagesNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [];

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || ref.read(chatLoadingProvider)) return;

    state = [...state, ChatMessage(isUser: true, text: trimmed)];
    ref.read(chatLoadingProvider.notifier).set(true);

    final parsed = parseChatQuery(
      trimmed,
      fallbackCenter: ref.read(searchCenterProvider),
      fallbackWeights: ref.read(weightsProvider),
      fallbackDurationMinutes: ref.read(durationMinutesProvider),
    );

    final client = ref.read(parkingApiClientProvider);
    try {
      final result = await client.fetchRecommend(
        lat: parsed.center.lat,
        lng: parsed.center.lng,
        durationMin: parsed.durationMinutes,
        wFee: parsed.weights.fee,
        wDistance: parsed.weights.distance,
        wEv: parsed.weights.ev,
      );

      if (result.items.isEmpty) {
        state = [
          ...state,
          const ChatMessage(
            isUser: false,
            text: '조건에 맞는 주차장을 찾지 못했어요. 다른 조건으로 다시 물어봐 주세요.',
          ),
        ];
      } else {
        final top = result.items.first;
        ref.read(searchCenterProvider.notifier).set(parsed.center);
        final locationNote =
            parsed.matchedLandmarkName != null ? '${parsed.matchedLandmarkName} 근처에서 ' : '';
        final reason = top.reasons.isNotEmpty ? ' (${top.reasons.first})' : '';
        state = [
          ...state,
          ChatMessage(
            isUser: false,
            text: '$locationNote가장 적합한 곳은 "${top.name}"이에요$reason.',
            item: top,
          ),
        ];
      }
    } on ApiException catch (e) {
      state = [...state, ChatMessage(isUser: false, text: e.message, isError: true)];
    } finally {
      ref.read(chatLoadingProvider.notifier).set(false);
    }
  }
}

final chatMessagesProvider = NotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  ChatMessagesNotifier.new,
);
