import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

class GroupOrderScreen extends StatelessWidget {
  const GroupOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(title: const Text('Pedido grupal'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_rounded,
                  size: 72,
                  color: AppTokens.brandPrimary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Pedido grupal',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pronto podrás crear una sala compartida, invitar a tus amigos o compañeros y hacer el pedido juntos con un solo pago.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTokens.brandPrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      color: AppTokens.brandPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Próximamente',
                      style: TextStyle(
                        color: AppTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
