import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tiles = <_HomeTileData>[
      _HomeTileData('Menú', Icons.restaurant_menu, RouteNames.menu),
      _HomeTileData('Carrito', Icons.shopping_cart_outlined, RouteNames.cart),
      _HomeTileData('Mis pedidos', Icons.receipt_long, RouteNames.orders),
      _HomeTileData('Favoritos', Icons.favorite_outline, RouteNames.favorites),
      _HomeTileData('Perfil', Icons.person_outline, RouteNames.profile),
      _HomeTileData(
        'Catering',
        Icons.celebration_outlined,
        RouteNames.catering,
      ),
      _HomeTileData('Contacto', Icons.mail_outline, RouteNames.contact),
      _HomeTileData('Chat IA', Icons.smart_toy_outlined, RouteNames.chat),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Sabor de Casa')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          childAspectRatio: 1.25,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (_, index) {
          final item = tiles[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.goNamed(item.routeName),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 36),
                    const SizedBox(height: 10),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeTileData {
  const _HomeTileData(this.label, this.icon, this.routeName);

  final String label;
  final IconData icon;
  final String routeName;
}
