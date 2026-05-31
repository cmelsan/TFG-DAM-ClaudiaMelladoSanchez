/// Traduce los mensajes de error de Supabase Auth al español.
///
/// Supabase devuelve errores en inglés (p.ej. "Invalid login credentials").
/// Esta función mapea los más comunes a mensajes claros en español.
String translateAuthError(Object? error) {
  if (error == null) return 'Ha ocurrido un error inesperado.';

  final raw = error.toString().toLowerCase();

  // ── Credenciales ──────────────────────────────────────────────────────────
  if (raw.contains('invalid_credentials') ||
      raw.contains('invalid login credentials') ||
      raw.contains('invalid email or password')) {
    return 'Correo electrónico o contraseña incorrectos.';
  }

  // ── Email no confirmado ───────────────────────────────────────────────────
  if (raw.contains('email not confirmed') ||
      raw.contains('email_not_confirmed')) {
    return 'Debes confirmar tu correo electrónico antes de iniciar sesión.\nRevisa tu bandeja de entrada.';
  }

  // ── Usuario ya existe ─────────────────────────────────────────────────────
  if (raw.contains('user already registered') ||
      raw.contains('already been registered') ||
      raw.contains('email already')) {
    return 'Ya existe una cuenta con ese correo electrónico.';
  }

  // ── Contraseña demasiado corta ────────────────────────────────────────────
  if (raw.contains('password should be at least') ||
      raw.contains('weak_password')) {
    return 'La contraseña debe tener al menos 6 caracteres.';
  }

  // ── Email inválido ────────────────────────────────────────────────────────
  if (raw.contains('invalid email') || raw.contains('unable to validate email')) {
    return 'La dirección de correo electrónico no es válida.';
  }

  // ── Demasiados intentos ───────────────────────────────────────────────────
  if (raw.contains('too many requests') ||
      raw.contains('over_request_rate_limit') ||
      raw.contains('rate limit')) {
    return 'Demasiados intentos seguidos. Espera unos minutos e inténtalo de nuevo.';
  }

  // ── Token expirado / sesión inválida ──────────────────────────────────────
  if (raw.contains('token expired') ||
      raw.contains('invalid refresh token') ||
      raw.contains('session_not_found')) {
    return 'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.';
  }

  // ── Sin conexión ──────────────────────────────────────────────────────────
  if (raw.contains('failed host lookup') ||
      raw.contains('network') ||
      raw.contains('socketexception')) {
    return 'No hay conexión a Internet. Comprueba tu red e inténtalo de nuevo.';
  }

  // ── Proveedor OAuth ───────────────────────────────────────────────────────
  if (raw.contains('provider') && raw.contains('not supported')) {
    return 'Este método de inicio de sesión no está disponible.';
  }

  // ── Fallback ──────────────────────────────────────────────────────────────
  return 'Ha ocurrido un error. Por favor, inténtalo de nuevo.';
}
