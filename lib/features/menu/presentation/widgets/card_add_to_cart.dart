import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';

/// Selector de cantidad inline + botón de añadir al carrito para tarjetas.
/// Se gestiona el estado de cantidad localmente.
class CardAddToCart extends StatefulWidget {
  const CardAddToCart({super.key, required this.dish});

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
        return SizedBox(
          height: 38,
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
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.remove, color: Colors.white, size: 17),
                    ),
                  ),
                  // ── Cantidad ────────────────────────────────────────────
                  SizedBox(
                    width: 24,
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
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.add, color: Colors.white, size: 17),
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
                                  ? '${_qty}× ${widget.dish.name} añadido'
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
                      child: const Center(
                        child: Text(
                          'AÑADIR AL CARRITO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
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
