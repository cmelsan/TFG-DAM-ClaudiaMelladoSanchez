import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

/// FAB del chatbot IA — visible en todas las pantallas de cliente.
/// En web alterna entre icono de chat y X según [isOpen].
class AppFab extends StatelessWidget {
  const AppFab({required this.onPressed, this.isOpen = false, super.key});

  final VoidCallback onPressed;
  final bool isOpen;

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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: isOpen
              ? const Icon(Icons.close_rounded, size: 22, key: ValueKey('x'))
              : const Icon(Icons.chat_bubble_outline_rounded,
                  size: 22, key: ValueKey('chat')),
        ),
      ),
    );
  }
}
