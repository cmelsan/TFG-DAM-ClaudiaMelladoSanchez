/// Validadores centralizados para formularios.
class Validators {
  const Validators._();

  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email obligatorio';
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Email no válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña obligatoria';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opcional
    final regex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!regex.hasMatch(value.trim())) return 'Teléfono no válido';
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value != null && value.length > max) {
      return 'Máximo $max caracteres';
    }
    return null;
  }
}
