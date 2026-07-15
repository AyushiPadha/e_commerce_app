class AppUser {
  final String name;
  final String email;

  const AppUser({required this.name, required this.email});

  Map<String, dynamic> toJson() => {'name': name, 'email': email};

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}