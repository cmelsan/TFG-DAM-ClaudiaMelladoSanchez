import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/layout/responsive.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_sidebar.dart';

/// Shell responsivo para el panel de administración.
///
/// - **Desktop/Tablet** (≥ 600 px): [AdminSidebar] de 240 px + contenido.
/// - **Mobile** (< 600 px): Scaffold con [Drawer] + AppBar.
///
/// ```dart
/// // En el router GoRouter:
/// ShellRoute(
///   builder: (ctx, state, child) => AdminShell(child: child),
///   routes: [...]
/// )
/// ```
class AdminShell extends StatelessWidget {
  const AdminShell({
    required this.child,
    super.key,
    this.title,
    this.floatingActionButton,
  });

  final Widget child;
  final String? title;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return _MobileAdminShell(
        title: title,
        floatingActionButton: floatingActionButton,
        child: child,
      );
    }
    return _DesktopAdminShell(
      floatingActionButton: floatingActionButton,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP / TABLET
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopAdminShell extends StatelessWidget {
  const _DesktopAdminShell({required this.child, this.floatingActionButton});
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          const AdminSidebar(),
          Container(width: 0.5, color: const Color(0xFF2A2A2A)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────────

class _MobileAdminShell extends StatelessWidget {
  const _MobileAdminShell({
    required this.child,
    this.title,
    this.floatingActionButton,
  });
  final String? title;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        title: Text(title ?? 'Admin'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const Drawer(
        backgroundColor: AppTokens.surfaceDark,
        width: 240,
        child: AdminSidebar(),
      ),
      body: child,
    );
  }
}
