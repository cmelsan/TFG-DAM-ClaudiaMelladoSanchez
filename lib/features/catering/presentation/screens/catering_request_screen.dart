import 'package:flutter/material.dart';

class CateringRequestScreen extends StatelessWidget {
  const CateringRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitud de catering')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Formulario de solicitud avanzada en preparación. '
            'Por ahora puedes consultar menús de catering.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
