class User {
  final String username;
  final String email;
  final String? imageFile;
  final String? imagePath;

  const User({
    required this.username,
    required this.email,
    this.imageFile,
    this.imagePath,
  });

  // This factory method converts the backend JSON into this Dart object.
  // Notice we use the exact python JSON keys here (e.g., 'image_file')
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      // Cast as String? because they might be null from the backend
      imageFile: json['image_file'] as String?, 
      imagePath: json['image_path'] as String?,
    );
  }
}