// for get user profile, update profile, uplaod user iamge, change pwd, delete account 
// for user's actions on their account

import '../core/network/api_client.dart';
import '../models/user.dart'; // Make sure this points to your updated User model file

class UsersApi {
  final ApiClient _apiClient;

  // Clean constructor: ApiClient handles everything automatically
  UsersApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch Current User Profile
  /// Hits GET /users/me and converts the response into a Dart User object
  Future<User> getUserProfile() async {
    return _apiClient.getJson<User>(
      path: '/users/me', 
      endpointName: 'getUserProfile',
      onSuccess: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  /// 🚨 Delete Entire User Account
  /// Hits DELETE /users/me and returns void (Because the backend returns 204 No Content)
  Future<void> deleteUserAccount() async {
    return _apiClient.deleteJson<void>(
      path: '/users/me', 
      endpointName: 'deleteUserAccount',
      onSuccess: (_) {}, // Do nothing with the body since 204 has no content
    );
  }
}