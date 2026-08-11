import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';

class Token {
  final String accessToken;
  final String tokenType;

  Token({required this.accessToken, required this.tokenType});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }
}

class UserPrivate {
  final int id;
  final String username;
  final String email;
  final String? imageFile;
  final String? imagePath;

  UserPrivate({
    required this.id,
    required this.username,
    required this.email,
    this.imageFile,
    this.imagePath,
  });

  factory UserPrivate.fromJson(Map<String, dynamic> json) {
    return UserPrivate(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      imageFile: json['image_file'] as String?,
      imagePath: json['image_path'] as String?,
    );
  }
}

/// Service class handling API calls for Registration & Login
class AuthApi {
  final ApiClient _apiClient;

  // 🎯 Updated Constructor: No baseUrl required!
  AuthApi({ApiClient? apiClient, http.Client? client})
      : _apiClient = apiClient ?? ApiClient(client: client);

  /// 1. Register User 
  Future<UserPrivate> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    return _apiClient.postJson<UserPrivate>(
      path: '/users',
      endpointName: 'registerUser',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
      onSuccess: (data) => UserPrivate.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 2. Login User 
  Future<Token> loginForAccessToken({
    required String email,
    required String password,
  }) async {
    return _apiClient.postForm<Token>(
      path: '/users/token',
      endpointName: 'loginForAccessToken',
      body: {
        'username': email,
        'password': password,
      },
      onSuccess: (data) => Token.fromJson(data as Map<String, dynamic>),
    );
  }
}