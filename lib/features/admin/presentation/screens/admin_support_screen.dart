import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_message.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_thread.dart';
import 'package:sabor_de_casa/features/support/presentation/providers/support_provider.dart';

class AdminSupportScreen extends ConsumerStatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  ConsumerState<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends ConsumerState<AdminSupportScreen> {
  final _replyCtrl = TextEditingController();
  String? _selectedThreadId;
  String _filter = 'open';

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(adminSupportThreadsProvider);
    final actionState = ref.watch(supportActionProvider);

    return AdminShell(
      title: 'Mensajes',
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppTokens.brandPrimary,
          ),
          onPressed: () => ref.invalidate(adminSupportThreadsProvider),
        ),
        const SizedBox(width: 8),
      ],
      child: threadsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(adminSupportThreadsProvider),
          ),
        ),
        data: (threads) {
          final filtered = _filteredThreads(threads);
          final selected = _selectedThread(filtered);
          if (selected != null && _selectedThreadId != selected.id) {
            _selectedThreadId = selected.id;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920;
              final list = _ThreadList(
                threads: filtered,
                selectedId: selected?.id,
                filter: _filter,
                onFilterChanged: (value) => setState(() => _filter = value),
                onSelected: (thread) {
                  setState(() => _selectedThreadId = thread.id);
                  ref
                      .read(supportActionProvider.notifier)
                      .markRead(thread.id, asAdmin: true);
                },
              );
              final detail = selected == null
                  ? const _EmptyDetail()
                  : _ThreadDetail(
                      thread: selected,
                      replyCtrl: _replyCtrl,
                      isSending: actionState.isLoading,
                      onSend: () => _sendReply(selected),
                      onClose: () => _closeThread(selected),
                    );

              if (!wide) {
                return Column(
                  children: [
                    SizedBox(height: 280, child: list),
                    Expanded(child: detail),
                  ],
                );
              }
              return Row(
                children: [
                  SizedBox(width: 380, child: list),
                  const VerticalDivider(width: 1, color: Color(0xFFE8E5E0)),
                  Expanded(child: detail),
                ],
              );
            },
          );
        },
      ),
    );
  }

  SupportThread? _selectedThread(List<SupportThread> threads) {
    if (threads.isEmpty) return null;
    for (final thread in threads) {
      if (thread.id == _selectedThreadId) return thread;
    }
    return threads.first;
  }

  List<SupportThread> _filteredThreads(List<SupportThread> threads) {
    return switch (_filter) {
      'unread' => threads.where((t) => t.unreadForAdmin > 0).toList(),
      'closed' => threads.where((t) => t.status == 'closed').toList(),
      'all' => threads,
      _ => threads.where((t) => t.status != 'closed').toList(),
    };
  }

  Future<void> _sendReply(SupportThread thread) async {
    final body = _replyCtrl.text.trim();
    if (body.isEmpty) return;
    await ref
        .read(supportActionProvider.notifier)
        .sendMessage(threadId: thread.id, body: body, asAdmin: true);
    _replyCtrl.clear();
  }

  Future<void> _closeThread(SupportThread thread) async {
    await ref.read(supportActionProvider.notifier).closeThread(thread.id);
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList({
    required this.threads,
    required this.selectedId,
    required this.filter,
    required this.onFilterChanged,
    required this.onSelected,
  });

  final List<SupportThread> threads;
  final String? selectedId;
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<SupportThread> onSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFAF9F7),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Bandeja',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTokens.surfaceDark,
                  ),
                ),
                const Spacer(),
                _FilterMenu(value: filter, onChanged: onFilterChanged),
              ],
            ),
          ),
          Expanded(
            child: threads.isEmpty
                ? Center(
                    child: Text(
                      'Sin conversaciones en este filtro',
                      style: GoogleFonts.inter(color: const Color(0xFF8C8780)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _ThreadTile(
                      thread: threads[index],
                      selected: threads[index].id == selectedId,
                      onTap: () => onSelected(threads[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ThreadDetail extends ConsumerWidget {
  const _ThreadDetail({
    required this.thread,
    required this.replyCtrl,
    required this.isSending,
    required this.onSend,
    required this.onClose,
  });

  final SupportThread thread;
  final TextEditingController replyCtrl;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(supportMessagesProvider(thread.id));
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE8E5E0))),
          ),
          child: Row(
            children: [
              _CategoryAvatar(category: thread.category),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppTokens.surfaceDark,
                      ),
                    ),
                    Text(
                      '${thread.userFullName ?? 'Cliente'} · ${thread.userEmail ?? thread.userId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF8A8782),
                      ),
                    ),
                  ],
                ),
              ),
              if (thread.status != 'closed')
                TextButton.icon(
                  onPressed: onClose,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTokens.danger,
                    minimumSize: const Size(0, 40),
                  ),
                  icon: const Icon(Icons.lock_rounded, size: 16),
                  label: const Text('Cerrar'),
                ),
            ],
          ),
        ),
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, _) => Center(
              child: ErrorView(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(supportMessagesProvider(thread.id)),
              ),
            ),
            data: (messages) => ListView.builder(
              padding: const EdgeInsets.all(22),
              itemCount: messages.length,
              itemBuilder: (context, index) => _MessageBubble(
                message: messages[index],
                fromAdmin: messages[index].senderRole == 'admin',
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE8E5E0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: replyCtrl,
                  minLines: 1,
                  maxLines: 4,
                  enabled: thread.status != 'closed',
                  decoration: InputDecoration(
                    hintText: thread.status == 'closed'
                        ? 'Conversacion cerrada'
                        : 'Responder al cliente...',
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
                onPressed: thread.status == 'closed' || isSending
                    ? null
                    : onSend,
                style: IconButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  disabledBackgroundColor: const Color(0xFFD8D5D0),
                ),
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({
    required this.thread,
    required this.selected,
    required this.onTap,
  });

  final SupportThread thread;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTokens.brandLight : Colors.white,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: selected ? AppTokens.brandPrimary : const Color(0xFFEDE8E1),
          ),
        ),
        child: Row(
          children: [
            _CategoryAvatar(category: thread.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTokens.surfaceDark,
                          ),
                        ),
                      ),
                      if (thread.unreadForAdmin > 0) const _UnreadDot(),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    thread.lastMessage ?? 'Sin mensajes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF77716B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.userFullName ?? thread.userEmail ?? 'Cliente',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8B8580),
                          ),
                        ),
                      ),
                      if (thread.lastMessageAt != null)
                        Text(
                          Formatters.date(thread.lastMessageAt!),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFFA09B94),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
              fromAdmin ? 'Admin' : 'Cliente',
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
                color: fromAdmin ? Colors.white : AppTokens.surfaceDark,
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

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        items: const [
          DropdownMenuItem(value: 'open', child: Text('Abiertos')),
          DropdownMenuItem(value: 'unread', child: Text('Sin leer')),
          DropdownMenuItem(value: 'closed', child: Text('Cerrados')),
          DropdownMenuItem(value: 'all', child: Text('Todos')),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppTokens.brandLight,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Icon(_categoryIcon(category), color: AppTokens.brandPrimary),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Selecciona una conversacion',
        style: GoogleFonts.inter(color: const Color(0xFF8C8780)),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: AppTokens.danger,
        shape: BoxShape.circle,
      ),
    );
  }
}

IconData _categoryIcon(String category) => switch (category) {
  'order' => Icons.receipt_long_rounded,
  'catering' => Icons.celebration_rounded,
  'incident' => Icons.report_problem_rounded,
  _ => Icons.support_agent_rounded,
};
