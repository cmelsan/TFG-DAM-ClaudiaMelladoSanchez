class ContactAdminMessage {
  const ContactAdminMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.isRead,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String subject;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  ContactAdminMessage copyWith({
    bool? isRead,
  }) {
    return ContactAdminMessage(
      id: id,
      name: name,
      email: email,
      phone: phone,
      subject: subject,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory ContactAdminMessage.fromJson(Map<String, dynamic> json) {
    return ContactAdminMessage(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Cliente',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      subject: (json['subject'] as String?) ?? 'Consulta',
      message: (json['message'] as String?) ?? '',
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
    );
  }
}
