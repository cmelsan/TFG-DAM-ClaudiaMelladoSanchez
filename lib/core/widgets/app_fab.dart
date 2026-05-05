import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

/// FAB del chatbot IA — visible en todas las pantallas de cliente.
///
/// ```dart
/// Scaffold(
///   floatingActionButton: AppFab(onPressed: () => context.push('/chat')),
///   body: ...,
/// )
/// ```
class AppFab extends StatelessWidget {
  const AppFab({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppTokens.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
      ),
    );
  }
}
