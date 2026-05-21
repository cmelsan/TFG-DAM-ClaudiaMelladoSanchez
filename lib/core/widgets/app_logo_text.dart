import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Logo de la marca como texto con tipografía de display pesada.
/// Usa [color] para adaptar a fondos claros u oscuros.
/// Si [showImage] es true, muestra el icono del logo a la izquierda
/// del texto con la misma altura que las letras.
class AppLogoText extends StatelessWidget {
  const AppLogoText({
    required this.color,
    required this.fontSize,
    this.textAlign = TextAlign.left,
    this.showImage = false,
    this.singleLine = false,
    super.key,
  });

  final Color color;
  final double fontSize;
  final TextAlign textAlign;
  final bool showImage;

  /// Si true, el texto se muestra en una sola línea con tipografía Syne italic.
  /// Si false (por defecto), se muestra en dos líneas con Inter w900.
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final text = singleLine
        ? Text(
            'Sabor de Casa',
            textAlign: textAlign,
            style: GoogleFonts.syne(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              fontSize: fontSize,
              color: color,
              height: 1,
              letterSpacing: 0,
            ),
          )
        : Text(
            'SABOR\nDE CASA',
            textAlign: textAlign,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              color: color,
              height: 0.95,
              letterSpacing: 2,
            ),
          );

    if (!showImage) return text;

    // Altura aproximada del bloque de texto (2 líneas × fontSize × height)
    final imageSize = fontSize * 0.95 * 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(imageSize * 0.15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(imageSize * 0.15),
            child: Image.asset(
              'assets/images/logo_bueno.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        text,
      ],
    );
  }
}
