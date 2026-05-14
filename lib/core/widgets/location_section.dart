import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

const _kLat = 36.7773;
const _kLng = -6.3534;

/// Sección "Dónde encontrarnos" adaptativa:
/// - Web (≥720px): info a la izquierda sin card, mapa grande a la derecha.
/// - Móvil (<720px): info arriba, mapa abajo.
class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  void _openMaps() {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$_kLat,$_kLng',
    );
    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                return isWide ? _buildWide() : _buildNarrow();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWide() {
    return SizedBox(
      height: 480,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Panel izquierdo: texto directo sobre fondo blanco ──
          SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.only(right: 48, top: 8, bottom: 8),
              child: _InfoPanel(onOpenMaps: _openMaps),
            ),
          ),
          // ── Mapa: ocupa el resto del espacio en altura ──────────
          const Expanded(child: _MapTile()),
        ],
      ),
    );
  }

  Widget _buildNarrow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: _InfoPanel(onOpenMaps: _openMaps),
        ),
        const SizedBox(
          height: 260,
          child: _MapTile(),
        ),
      ],
    );
  }
}

// ── Panel de información (sin card/fondo) ─────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.onOpenMaps});

  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eyebrow badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTokens.brandPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Nuestra ubicación',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTokens.brandPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Dónde\nencontrarnos',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 36,
            color: const Color(0xFF0D3B2E),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 44,
          height: 3,
          decoration: BoxDecoration(
            color: AppTokens.brandPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 32),
        const _InfoRow(
          icon: Icons.location_on_outlined,
          text: 'Calle Ejemplo, 12\nSanlúcar de Barrameda, Cádiz',
        ),
        const SizedBox(height: 18),
        const _InfoRow(
          icon: Icons.access_time_outlined,
          text: 'Lun – Dom\n12:00 – 15:30 · 20:00 – 23:30',
        ),
        const SizedBox(height: 18),
        const _InfoRow(
          icon: Icons.phone_outlined,
          text: '+34 900 123 456',
        ),
        const SizedBox(height: 36),
        FilledButton.icon(
          onPressed: onOpenMaps,
          icon: const Icon(Icons.directions_outlined, size: 17),
          label: Text(
            'CÓMO LLEGAR',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppTokens.brandPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size.zero,
          ),
        ),
      ],
    );
  }
}

// ── Fila de dato (icono + texto) ───────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTokens.brandPrimary, size: 21),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF3A3A3A),
              fontSize: 15,
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mapa estático sin interacción ─────────────────────────────────────────────

class _MapTile extends StatelessWidget {
  const _MapTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1D9E75).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(_kLat, _kLng),
            initialZoom: 15.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sabordecasa.app',
            ),
            const MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(_kLat, _kLng),
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.location_pin,
                    color: AppTokens.brandPrimary,
                    size: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
