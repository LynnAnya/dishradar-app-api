import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dish.dart';



class DishService {
  // 🌐 Change this to match your environment
  static const String baseUrl = "http://127.0.0.1:8000";

  /// Fetches detailed information for a specific dish by ID.
  /// Matches FastAPI Endpoint: GET /dishes/{dish_id}
  Future<DishDetail> fetchDishDetail(int dishId) async {
    final uri = Uri.parse('$baseUrl/dishes/$dishId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return DishDetail.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Dish not found (404)');
      } else {
        throw Exception('Failed to load dish details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching dish: $e');
    }
  }
}