import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indica si la sesión actual proviene de un enlace de recuperación de
/// contraseña (AuthChangeEvent.passwordRecovery).
/// El router lo usa para redirigir a /auth/reset-password.
/// Se pone a false cuando el usuario actualiza su contraseña con éxito.
final passwordRecoveryModeProvider = StateProvider<bool>((ref) => false);
