import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

/// Selector de cantidad inline + botón de añadir al carrito para tarjetas.
/// Se gestiona el estado de cantidad localmente.
class CardAddToCart extends StatefulWidget {
  const CardAddToCart({required this.dish, super.key});

  final Dish dish;

  @override
  State<CardAddToCart> createState() => _CardAddToCartState();
}

class _CardAddToCartState extends State<CardAddToCart> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isWeb = kIsWeb;
        final controlSize = isWeb ? 38.0 : 34.0;
        final qtyWidth = isWeb ? 24.0 : 20.0;
        final buttonLabel = isWeb ? 'AÑADIR AL CARRITO' : 'AÑADIR';

        return SizedBox(
          height: controlSize,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTokens.brandPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // ── Botón –  ───────────────────────────────────────────
                  InkWell(
                    onTap: () {
                      if (_qty > 1) setState(() => _qty--);
                    },
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: controlSize,
                      height: controlSize,
                      child: const Icon(Icons.remove, color: Colors.white, size: 17),
                    ),
                  ),
                  // ── Cantidad ────────────────────────────────────────────
                  SizedBox(
                    width: qtyWidth,
                    child: Text(
                      '$_qty',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // ── Botón +  ───────────────────────────────────────────
                  InkWell(
                    onTap: () => setState(() => _qty++),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: controlSize,
                      height: controlSize,
                      child: const Icon(Icons.add, color: Colors.white, size: 17),
                    ),
                  ),
                  // ── Separador vertical ─────────────────────────────────
                  Container(
                    width: 1,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  // ── AÑADIR AL CARRITO ──────────────────────────────────
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        for (var i = 0; i < _qty; i++) {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .addDish(widget.dish);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _qty > 1
                                  ? '$_qty× ${widget.dish.name} añadido'
                                  : '${widget.dish.name} añadido',
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        setState(() => _qty = 1);
                      },
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(20),
                      ),
                      child: _AddLabel(
                        label: buttonLabel,
                        isWeb: isWeb,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddLabel extends StatelessWidget {
  const _AddLabel({required this.label, required this.isWeb});

  final String label;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isWeb ? 11 : 10,
              letterSpacing: isWeb ? 0.5 : 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
