import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/dish.dart';

class NetworkException implements Exception {
  final String message;
  final dynamic originalError;

  NetworkException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class SearchApiService {
  // 💡 Tip: Move baseUrl to an environment configuration file in production!
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List<Dish>> searchDishes({
    String? q,
    double? maxPrice,
    double? minRating,
    String? menuCategory,
  }) async {
    final Map<String, String> queryParams = {};

    if (q != null && q.trim().isNotEmpty) queryParams['q'] = q.trim();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (minRating != null) queryParams['min_rating'] = minRating.toString();
    if (menuCategory != null && menuCategory.trim().isNotEmpty) {
      queryParams['menu_category'] = menuCategory.trim();
    }

    final url = Uri.parse('$baseUrl/search/dishes').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic rawJson = json.decode(response.body);

        if (rawJson is! List) {
          developer.log(
            'JSON format error: Expected List but got ${rawJson.runtimeType}',
            name: 'SearchApiService',
          );
          throw NetworkException('Expected a List from server, but got ${rawJson.runtimeType}');
        }

        return rawJson.map((item) {
          try {
            return Dish.fromJson(item as Map<String, dynamic>);
          } catch (e, stack) {
            // Highlights exact JSON parsing failure (e.g. missing field or type mismatch)
            developer.log(
              'Failed to parse Dish item: $item',
              error: e,
              stackTrace: stack,
              name: 'SearchApiService',
            );
            // Re-throwing as NetworkException with exact item and error details
            throw NetworkException('Failed to parse Dish: $e\nItem payload: $item');
          }
        }).toList();
      } else {
        // Detailed log of backend error status & response body
        developer.log(
          'Server Error [${response.statusCode}]: ${response.body}',
          name: 'SearchApiService',
        );
        throw NetworkException('Server Error (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e, stackTrace) {
      developer.log('Network unreachable: $e', error: e, stackTrace: stackTrace, name: 'SearchApiService');
      throw NetworkException('Network Connection Failed: $e', e);
    } on TimeoutException catch (e, stackTrace) {
      developer.log('Request timed out: $url', error: e, stackTrace: stackTrace, name: 'SearchApiService');
      throw NetworkException('Timeout Error: Server took too long to respond.', e);
    } on FormatException catch (e, stackTrace) {
      developer.log('JSON Decoding Error', error: e, stackTrace: stackTrace, name: 'SearchApiService');
      throw NetworkException('JSON Format Exception: $e', e);
    } on TypeError catch (e, stackTrace) {
      // 🎯 Passes $e directly to the UI screen so you see the exact type mismatch!
      developer.log('Data Type Mismatch Error', error: e, stackTrace: stackTrace, name: 'SearchApiService');
      throw NetworkException('Type Error (Data Mismatch): $e', e);
    } catch (e, stackTrace) {
      developer.log('Unexpected Error in searchDishes', error: e, stackTrace: stackTrace, name: 'SearchApiService');
      throw NetworkException('Unexpected Error: $e', e);
    }
  }
}