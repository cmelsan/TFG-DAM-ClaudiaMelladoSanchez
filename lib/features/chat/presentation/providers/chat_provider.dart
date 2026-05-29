import 'package:flutter/foundation.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/chat/data/repositories/chat_repository.dart';
import 'package:sabor_de_casa/features/chat/domain/models/chat_message.dart';

part 'chat_provider.g.dart';

// ── Estado ────────────────────────────────────────────────────────────────────

class ChatState {
  const ChatState({required this.messages, this.isLoading = false});

  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class ChatNotifier extends _$ChatNotifier {
  static const _welcomeId = 'welcome';

  @override
  ChatState build() => ChatState(
        messages: [
          ChatMessage(
            id: _welcomeId,
            role: ChatRole.assistant,
            text: '¡Hola! Soy SaborIA 🌿, tu asistente de Sabor de Casa. '
                '¿En qué puedo ayudarte? Puedo orientarte sobre nuestra carta, '
                'catering para eventos, horarios y mucho más.',
            timestamp: DateTime.now(),
          ),
        ],
      );

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMsg = ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final reply = await ref
          .read(chatRepositoryProvider)
          .sendMessages(state.messages);

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: '${DateTime.now().microsecondsSinceEpoch}_r',
            role: ChatRole.assistant,
            text: reply,
            timestamp: DateTime.now(),
          ),
        ],
        isLoading: false,
      );
    } catch (e, st) {
      debugPrint('[SaborIA] Error al llamar Edge Function: $e\n$st');
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: '${DateTime.now().microsecondsSinceEpoch}_e',
            role: ChatRole.assistant,
            text: 'Lo siento, ha ocurrido un error. Inténtalo de nuevo.',
            timestamp: DateTime.now(),
          ),
        ],
        isLoading: false,
      );
    }
  }

  /// Reinicia la conversación al mensaje de bienvenida.
  void clear() => state = build();
}
