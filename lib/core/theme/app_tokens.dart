import 'package:flutter/material.dart';

/// Design tokens únicos de Sabor de Casa.
/// Úsalo en TODA la app — nunca codifiques colores inline.
abstract final class AppTokens {
  // ─── COLORES BRAND ────────────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF1D9E75);
  static const Color brandDark = Color(0xFF0F6E56);
  static const Color brandLight = Color(0xFFE1F5EE);
  static const Color surfaceDark = Color(0xFF1A1A2E); // admin / sidebar
  static const Color pageBg = Color(0xFFF7F7F5);

  // ─── COLORES SEMÁNTICOS ───────────────────────────────────────────
  static const Color info = Color(0xFF378ADD);
  static const Color infoBg = Color(0xFFE6F1FB);
  static const Color warning = Color(0xFFEF9F27);
  static const Color warningBg = Color(0xFFFAEEDA);
  static const Color danger = Color(0xFFE24B4A);
  static const Color dangerBg = Color(0xFFFCEBEB);
  static const Color success = Color(0xFF1D9E75);
  static const Color successBg = Color(0xFFE1F5EE);

  // ─── BADGES TIPO DE PEDIDO ────────────────────────────────────────
  static const Color badgeRecogidaBg = Color(0xFFE6F1FB);
  static const Color badgeRecogidaFg = Color(0xFF0C447C);
  static const Color badgeDomicilioBg = Color(0xFFFAEEDA);
  static const Color badgeDomicilioFg = Color(0xFF633806);
  static const Color badgeEncargoBg = Color(0xFFEAF3DE);
  static const Color badgeEncargoFg = Color(0xFF27500A);
  static const Color badgeMostradorBg = Color(0xFFEEEDFE);
  static const Color badgeMostradorFg = Color(0xFF3C3489);

  // ─── ESTADOS PEDIDO ───────────────────────────────────────────────
  static const Color statusPendiente = Color(0xFFEF9F27);
  static const Color statusConfirmado = Color(0xFF378ADD);
  static const Color statusPreparando = Color(0xFF1D9E75);
  static const Color statusListo = Color(0xFF085041);
  static const Color statusReparto = Color(0xFF7F77DD);
  static const Color statusEntregado = Color(0xFF444441);
  static const Color statusCancelado = Color(0xFFE24B4A);

  // ─── BACKGROUNDS ESTADOS ──────────────────────────────────────────
  static const Color statusPendienteBg = Color(0xFFFAEEDA);
  static const Color statusConfirmadoBg = Color(0xFFE6F1FB);
  static const Color statusPreparandoBg = Color(0xFFE1F5EE);
  static const Color statusListoBg = Color(0xFFD5EFE9);
  static const Color statusRepartoBg = Color(0xFFEEEDFE);
  static const Color statusEntregadoBg = Color(0xFFE8E8E6);
  static const Color statusCanceladoBg = Color(0xFFFCEBEB);

  // ─── BORDER RADIUS ────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 24;

  // ─── ELEVACIÓN / SOMBRA ───────────────────────────────────────────
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}
