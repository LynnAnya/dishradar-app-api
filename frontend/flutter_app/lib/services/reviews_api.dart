import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../models/review.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService({ApiClient? apiClient, http.Client? client})
      : _apiClient = apiClient ?? ApiClient(client: client);

  ///1.  Submits a new review for a dish
  Future<Review> createReview({
    required int dishId,
    int userId = 1,
    required int rating,
    String? comment,
  }) async {
    final Map<String, dynamic> body = {
      'dish_id': dishId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    }..removeWhere((key, value) => value == null);

    return _apiClient.postJson<Review>(
      path: '/dishes/$dishId/reviews',
      endpointName: 'createReview',
      body: body,
      onSuccess: (data) => Review.fromJson(data as Map<String, dynamic>),
    );
  }
}