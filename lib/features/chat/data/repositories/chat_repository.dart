import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/chat/domain/models/chat_message.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepository(ref.watch(supabaseClientProvider));
}

class ChatRepository {
  ChatRepository(this._client);

  final SupabaseClient _client;

  /// Envía el historial de mensajes a la Edge Function y devuelve la respuesta
  /// del asistente como texto plano.
  Future<String> sendMessages(List<ChatMessage> messages) async {
    final response = await _client.functions.invoke(
      'chat-bot',
      body: {
        'messages': messages
            .map(
              (m) => {
                'role': m.role == ChatRole.user ? 'user' : 'assistant',
                'content': m.text,
              },
            )
            .toList(),
      },
    );

    final data = response.data as Map<String, dynamic>?;
    if (data == null) throw Exception('Sin respuesta del servidor de chat');

    final error = data['error'] as String?;
    if (error != null) throw Exception(error);

    return data['reply'] as String? ??
        'Lo siento, no pude procesar tu consulta.';
  }
}
