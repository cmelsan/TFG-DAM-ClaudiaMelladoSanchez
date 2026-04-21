import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/validators.dart';
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
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(contactSubmitProvider);

    ref.listen(contactSubmitProvider, (prev, next) {
      if ((prev?.isLoading ?? false) && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mensaje enviado correctamente')),
        );
        _formKey.currentState?.reset();
        _nameCtrl.clear();
        _emailCtrl.clear();
        _phoneCtrl.clear();
        _subjectCtrl.clear();
        _messageCtrl.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    final requiredError = Validators.required(value);
                    if (requiredError != null) return requiredError;
                    return Validators.maxLength(value, 100);
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Asunto'),
                  validator: (value) {
                    final requiredError = Validators.required(value);
                    if (requiredError != null) return requiredError;
                    return Validators.maxLength(value, 120);
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _messageCtrl,
                  decoration: const InputDecoration(labelText: 'Mensaje'),
                  maxLines: 5,
                  validator: (value) {
                    final requiredError = Validators.required(value);
                    if (requiredError != null) return requiredError;
                    return Validators.maxLength(value, 1000);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: submitState.isLoading ? null : _submit,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(contactSubmitProvider.notifier).submit(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          subject: _subjectCtrl.text,
          message: _messageCtrl.text,
        );
  }
}
