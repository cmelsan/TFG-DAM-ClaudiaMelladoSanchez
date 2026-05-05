import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Logo de la marca como texto con tipografía de display pesada.
/// Usa [color] para adaptar a fondos claros u oscuros.
class AppLogoText extends StatelessWidget {
  const AppLogoText({
    required this.color,
    required this.fontSize,
    this.textAlign = TextAlign.left,
    super.key,
  });

  final Color color;
  final double fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      'SABOR\nDE CASA',
      textAlign: textAlign,
      style: GoogleFonts.bebasNeue(
        fontSize: fontSize,
        color: color,
        height: 0.95,
        letterSpacing: 2,
      ),
    );
  }
}
