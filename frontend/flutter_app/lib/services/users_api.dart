// for get user profile, update profile, uplaod user iamge, change pwd, delete account 
// for user's actions on their account

import '../core/network/api_client.dart';
import '../models/user.dart'; // Make sure this points to your updated User model file

class UsersApi {
  final ApiClient _apiClient;

  // Clean constructor: ApiClient handles everything automatically
  UsersApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch Current User Profile
  Future<User> getUserProfile() async {
    return _apiClient.getJson<User>(
      path: '/users/me', 
      endpointName: 'getUserProfile',
      onSuccess: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }
  ///  Delete User Account
  Future<void> deleteUserAccount() async {
    return _apiClient.deleteJson<void>(
      path: '/users/me', 
      endpointName: 'deleteUserAccount',
      onSuccess: (_) {}, 
    );
  }
}