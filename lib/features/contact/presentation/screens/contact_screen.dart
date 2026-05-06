import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/validators.dart';
import 'package:sabor_de_casa/core/widgets/location_section.dart';
import 'package:sabor_de_casa/features/contact/presentation/providers/contact_provider.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedType;
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(contactSubmitProvider);

    ref.listen(contactSubmitProvider, (prev, next) {
      if ((prev?.isLoading ?? false) && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensaje enviado. Nos pondremos en contacto pronto.'),
            backgroundColor: AppTokens.brandPrimary,
          ),
        );
        _formKey.currentState?.reset();
        _nameCtrl.clear();
        _emailCtrl.clear();
        _phoneCtrl.clear();
        _messageCtrl.clear();
        setState(() => _selectedType = null);
      }
    });

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        title: const Text('Atención al cliente'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿EN QUÉ PODEMOS AYUDARTE?',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 24,
                    letterSpacing: 1.5,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Si tienes dudas sobre tu pedido, sobre nuestros platos o quieres dejarnos algo de feedback, escríbenos.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                const _ContactInfoItem(
                  icon: Icons.phone_outlined,
                  text: '+34 900 123 456',
                ),
                const SizedBox(height: 12),
                const _ContactInfoItem(
                  icon: Icons.email_outlined,
                  text: 'info@sabordecasa.com',
                ),
                const SizedBox(height: 12),
                const _ContactInfoItem(
                  icon: Icons.access_time,
                  text: 'L a D: 12:00h - 23:30h',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Mapa de ubicación del local
          const LocationSection(),
          const SizedBox(height: 24),
          const Text(
            'Envíanos un mensaje',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E3)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'Nombre completo',
                    icon: Icons.person_outline,
                    validator: (value) {
                      final requiredError = Validators.required(value);
                      if (requiredError != null) return requiredError;
                      return Validators.maxLength(value, 100);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneCtrl,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de consulta',
                      prefixIcon: const Icon(Icons.help_outline),
                      filled: true,
                      fillColor: const Color(0xFFE5E5E3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items:
                        [
                              'Consulta general',
                              'Propuesta de evento',
                              'Oferta de trabajo',
                              'Colaboración',
                              'Otro',
                            ]
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedType = v),
                    validator: (v) =>
                        v == null ? 'Selecciona un tipo de consulta' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _messageCtrl,
                    label: 'Tu mensaje',
                    icon: Icons.chat_bubble_outline,
                    maxLines: 5,
                    validator: (value) {
                      final requiredError = Validators.required(value);
                      if (requiredError != null) return requiredError;
                      return Validators.maxLength(value, 1000);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: submitState.isLoading ? null : _submit,
                      icon: const Icon(Icons.send_outlined),
                      label: submitState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Enviar mensaje',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: maxLines == 1
            ? Icon(icon, color: Colors.black54)
            : Padding(
                padding: const EdgeInsets.only(
                  bottom: 80,
                ), // Aproximación para alinearlo arriba
                child: Icon(icon, color: Colors.black54),
              ),
        filled: true,
        fillColor: const Color(0xFFE5E5E3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(contactSubmitProvider.notifier)
        .submit(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          subject: _selectedType!,
          message: _messageCtrl.text,
        );
  }
}

class _ContactInfoItem extends StatelessWidget {
  const _ContactInfoItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTokens.pageBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTokens.brandPrimary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
      ],
    );
  }
}
