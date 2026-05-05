import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(title: const Text('SaborIA'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E5E3)),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  size: 80,
                  color: AppTokens.brandPrimary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'TU ASISTENTE GASTRONÓMICO',
                style: GoogleFonts.bebasNeue(
                  fontSize: 28,
                  letterSpacing: 1.5,
                  color: const Color(0xFF111111),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Estamos preparando SaborIA, una inteligencia artificial que te ayudará a encontrar el plato perfecto para hoy según tus antojos y restricciones alimentarias.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.black54, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Próximamente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
