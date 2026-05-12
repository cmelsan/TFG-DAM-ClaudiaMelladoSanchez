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
/// - Web (≥720px): info a la izquierda, mapa a la derecha.
/// - Móvil (<720px): info arriba, mapa abajo.
/// Usa OpenStreetMap (sin API key). El botón abre Google Maps / app nativa.
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
      color: AppTokens.pageBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 48),
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 340,
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _InfoPanel(onOpenMaps: _openMaps),
            ),
          ),
          const SizedBox(width: 24),
          const Expanded(child: _MapTile(height: 420)),
        ],
      ),
    );
  }

  Widget _buildNarrow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF0D3B2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _InfoPanel(onOpenMaps: _openMaps),
        ),
        const SizedBox(height: 20),
        const _MapTile(height: 220),
      ],
    );
  }
}

// ── Panel de información ───────────────────────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.onOpenMaps});

  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTokens.brandPrimary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Nuestra ubicación',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7ED4B8),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Título compacto
        Text(
          'Dónde\nencontrarnos',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 22),
        const _InfoRow(
          icon: Icons.location_on_outlined,
          text: 'Calle Ejemplo, 12\nSanlúcar de Barrameda, Cádiz',
        ),
        const SizedBox(height: 12),
        const _InfoRow(
          icon: Icons.access_time_outlined,
          text: 'Lun – Dom\n12:00 – 15:30 · 20:00 – 23:30',
        ),
        const SizedBox(height: 12),
        const _InfoRow(
          icon: Icons.phone_outlined,
          text: '+34 900 123 456',
        ),
        const SizedBox(height: 26),
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
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
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
        Icon(icon, color: const Color(0xFF8FBFB0), size: 20),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD0EEE6),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mapa interactivo (OpenStreetMap via flutter_map) ──────────────────────────

class _MapTile extends StatelessWidget {
  const _MapTile({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1D9E75).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(_kLat, _kLng),
            initialZoom: 15.5,
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
