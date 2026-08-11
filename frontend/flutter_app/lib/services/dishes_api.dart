import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../core/network/network_exceptions.dart';
import '../models/dish.dart';

class DishService {
  final ApiClient _apiClient;

  DishService({ApiClient? apiClient, http.Client? client}): _apiClient = apiClient ?? ApiClient(client: client);

  /// 1. Search Dishes with Optional Filters
  Future<List<Dish>> searchDishes({
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

    return _apiClient.getJson<List<Dish>>(
      path: '/dishes/search',
      queryParameters: queryParams,
      endpointName: 'searchDishes',
      onSuccess: (data) {
        if (data is! List) {
          developer.log(
            'JSON format error: Expected List but got ${data.runtimeType}',
            name: 'DishService.searchDishes',
          );
          throw NetworkException(
            'Expected a List from server, but got ${data.runtimeType}',
          );
        }

        return data.map((item) {
          try {
            return Dish.fromJson(item as Map<String, dynamic>);
          } catch (e, stack) {
            developer.log(
              'Failed to parse Dish item: $item',
              error: e,
              stackTrace: stack,
              name: 'DishService.searchDishes',
            );
            throw NetworkException('Failed to parse Dish: $e\nItem payload: $item');
          }
        }).toList();
      },
    );
  }

  /// 2. Fetch Dish Details by ID
  Future<DishDetail> fetchDishDetail(int dishId) async {
    return _apiClient.getJson<DishDetail>(
      path: '/dishes/$dishId',
      endpointName: 'fetchDishDetail',
      onSuccess: (data) => DishDetail.fromJson(data as Map<String, dynamic>),
    );
  }
}