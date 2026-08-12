import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../models/user.dart';

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


/// Service class handling API calls for Registration & Login
class AuthApi {
  final ApiClient _apiClient;

  // 🎯 Updated Constructor: No baseUrl required!
  AuthApi({ApiClient? apiClient, http.Client? client})
      : _apiClient = apiClient ?? ApiClient(client: client);

  /// 1. Register User 
  Future<User> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    return _apiClient.postJson<User>(
      path: '/users',
      endpointName: 'registerUser',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
      onSuccess: (data) => User.fromJson(data as Map<String, dynamic>),
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