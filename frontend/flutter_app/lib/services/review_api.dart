import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';

class ReviewService {
  final String baseUrl = "http://127.0.0.1:8000";

  // 1. CREATE: Post a new review
  Future<Review> createReview({
    required int dishId,
    int userId = 1,  //required int userId,  --> for testing hard code now
    required int rating,
    String? tags,
    String? comment,
  }) async {
    final url = Uri.parse('$baseUrl/dishes/$dishId/reviews');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dish_id': dishId,
          'user_id': userId,
          'rating': rating,
          'tags': tags,
          'comment': comment,
        }..removeWhere((key, value) => value == null)),
      );

      if (response.statusCode == 201) {
        return Review.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 409 ||
          response.statusCode == 400 ||
          response.statusCode == 404) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to submit review');
      } else {
        throw Exception('Failed to submit review. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
  // 2. GET - show all reviews of everyone for that dish ? 
  // 3. GET - show all reviews of this user for all dishes that they reviewed before
  // 4. PATCH - user edits their previous review 
  // 5. DELETE - user removes their specific review 
}