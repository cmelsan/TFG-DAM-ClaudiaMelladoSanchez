import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sabor_de_casa/features/home/presentation/screens/home_screen_mobile.dart';
import 'package:sabor_de_casa/features/home/presentation/screens/home_screen_web.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const HomeScreenWeb();
    return const HomeScreenMobile();
  }
}
