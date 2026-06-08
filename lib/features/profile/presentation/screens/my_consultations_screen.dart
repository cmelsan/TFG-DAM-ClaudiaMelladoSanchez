import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_message.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_thread.dart';
import 'package:sabor_de_casa/features/support/presentation/providers/support_provider.dart';

class MyConsultationsScreen extends ConsumerWidget {
  const MyConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(mySupportThreadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        title: const Text('Mis consultas'),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: AppTokens.surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: threadsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(mySupportThreadsProvider),
          ),
        ),
        data: (threads) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const _NewConsultationSheet(),
                  ),
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  label: const Text('Nueva consulta'),
                ),
              ),
              const SizedBox(height: 14),
              _ConsultationsHero(
                total: threads.length,
                unread: threads.fold<int>(0, (sum, thread) => sum + thread.unreadForCustomer),
              ),
              const SizedBox(height: 20),
              if (threads.isEmpty)
                const _EmptyConsultationsCard()
              else
                ...threads.map(
                  (thread) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ConsultationTile(
                      thread: thread,
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _ConsultationSheet(thread: thread),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ConsultationsHero extends StatelessWidget {
  const _ConsultationsHero({required this.total, required this.unread});

  final int total;
  final int unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FCF9), Color(0xFFF3FBF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EFE7)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 340;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tus consultas internas',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTokens.surfaceDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                total == 0
                    ? 'Aun no has abierto ninguna conversación.'
                    : unread > 0
                        ? '$unread sin leer · $total en total'
                        : '$total conversaciones · todo al dia',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF7C847E),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTokens.brandLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: AppTokens.brandPrimary),
                ),
                const SizedBox(height: 10),
                content,
              ],
            );
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTokens.brandLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.support_agent_rounded, color: AppTokens.brandPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyConsultationsCard extends StatelessWidget {
  const _EmptyConsultationsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E4DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No tienes consultas todavía',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTokens.surfaceDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando abras una conversación desde soporte interno, aparecerá aquí para seguirla sin salir de tu cuenta.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF7E776F),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _NewConsultationSheet extends ConsumerStatefulWidget {
  const _NewConsultationSheet();

  @override
  ConsumerState<_NewConsultationSheet> createState() => _NewConsultationSheetState();
}

class _NewConsultationSheetState extends ConsumerState<_NewConsultationSheet> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    if (subject.isEmpty || message.isEmpty) return;
    setState(() => _creating = true);
    try {
      final threadId = await ref.read(supportActionProvider.notifier).createThread(
            subject: subject,
            category: 'general',
            message: message,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      if (threadId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta creada')),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 18 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3DED7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Nueva consulta',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Escribe tu duda o incidencia. Se guardará dentro de tu cuenta.',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7E776F)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Asunto',
                hintText: 'Por ejemplo: Cambio de dirección',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageCtrl,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                hintText: 'Cuéntanos qué necesitas',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _creating ? null : _create,
                child: _creating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Crear consulta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationTile extends StatelessWidget {
  const _ConsultationTile({required this.thread, required this.onTap});

  final SupportThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = thread.unreadForCustomer;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E4DD)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0B000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTokens.brandLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.support_agent_rounded, color: AppTokens.brandPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTokens.surfaceDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    thread.lastMessage ?? 'Sin mensajes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF7B756D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    thread.lastMessageAt != null
                        ? Formatters.dateTime(thread.lastMessageAt!)
                        : 'Sin fecha',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF9A948C),
                    ),
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTokens.brandPrimary),
          ],
        ),
      ),
    );
  }
}

class _ConsultationSheet extends ConsumerStatefulWidget {
  const _ConsultationSheet({required this.thread});

  final SupportThread thread;

  @override
  ConsumerState<_ConsultationSheet> createState() => _ConsultationSheetState();
}

class _ConsultationSheetState extends ConsumerState<_ConsultationSheet> {
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(supportActionProvider.notifier).markRead(widget.thread.id, asAdmin: false);
    });
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final body = _replyCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(supportActionProvider.notifier).sendMessage(
            threadId: widget.thread.id,
            body: body,
            asAdmin: false,
          );
      _replyCtrl.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(supportMessagesProvider(widget.thread.id));
    final closed = widget.thread.status == 'closed';
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE3DED7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.thread.subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1B1A)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: closed ? const Color(0xFFEDE8E1) : const Color(0xFFEAF7EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    closed ? 'Cerrado' : 'Abierto',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: closed ? const Color(0xFF9A9188) : AppTokens.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error al cargar mensajes',
                  style: GoogleFonts.inter(color: const Color(0xFF7C847E)),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Sin mensajes'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => _MessageBubble(
                    message: messages[index],
                    fromAdmin: messages[index].senderRole == 'admin',
                  ),
                );
              },
            ),
          ),
          if (!closed)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu respuesta...',
                        filled: true,
                        fillColor: const Color(0xFFF7F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _sending ? null : _sendReply,
                    style: IconButton.styleFrom(backgroundColor: AppTokens.brandPrimary),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.fromAdmin});

  final SupportMessage message;
  final bool fromAdmin;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fromAdmin ? AppTokens.brandPrimary : const Color(0xFFF3F0EC),
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fromAdmin ? 'Admin' : 'Tú',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: fromAdmin ? Colors.white70 : AppTokens.brandPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.body,
              style: GoogleFonts.inter(
                color: fromAdmin ? Colors.white : const Color(0xFF1D1B1A),
                height: 1.45,
              ),
            ),
            if (message.createdAt != null) ...[
              const SizedBox(height: 6),
              Text(
                Formatters.dateTime(message.createdAt!),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: fromAdmin ? Colors.white60 : const Color(0xFF8F8982),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
