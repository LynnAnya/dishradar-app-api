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
    required int rating,
    String? comment,
  }) async {
    final Map<String, dynamic> body = {
      'dish_id': dishId,
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

  Future<Review> updateReview({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    final Map<String, dynamic> body = {
      'rating': rating,
      'comment': comment != null && comment.trim().isNotEmpty ? comment.trim() : null,
    };

   
    return _apiClient.patchJson<Review>(
      path: '/reviews/$reviewId', // Or '/reviews/$reviewId' depending on your router prefix
      endpointName: 'updateReview',
      body: body,
      onSuccess: (data) => Review.fromJson(data as Map<String, dynamic>),
    );
  }

}