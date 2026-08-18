import 'restaurant.dart';
import 'review.dart';

class Dish {
  final int id;
  final String name;
  final double price;
  final double rating;
  final String menuCategory;
  final bool isSpicy;
  final String? description;
  final String? imageUrl;
  
  // Restaurant Info from FastAPI Flattened Response
  final int? restaurantId;
  final String? restaurantName;
  final String? restaurantAddress;

  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.menuCategory,
    this.isSpicy = false,
    this.description,
    this.imageUrl,
    this.restaurantId,
    this.restaurantName,
    this.restaurantAddress,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['dish_id'] as int,
      name: json['dish_name'] as String? ?? 'Unknown Dish',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      menuCategory: json['menu_category'] as String? ?? 'Uncategorized',
      isSpicy: json['is_spicy'] as bool? ?? false,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      restaurantId: json['restaurant_id'] as int?,
      restaurantName: json['restaurant_name'] as String?,
      restaurantAddress: json['restaurant_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dish_id': id,
      'dish_name': name,
      'price': price,
      'average_rating': rating,
      'menu_category': menuCategory,
      'is_spicy': isSpicy,
      'description': description,
      'image_url': imageUrl,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'restaurant_address': restaurantAddress,
    };
  }
}

class DishDetail extends Dish {
  final List<Review> reviews;
  final Restaurant? restaurant;

  const DishDetail({
    required super.id,
    required super.name,
    required super.price,
    required super.rating,
    required super.menuCategory,
    super.isSpicy = false,
    super.description,
    super.imageUrl,
    super.restaurantId,
    super.restaurantName,
    super.restaurantAddress,
    required this.reviews,
    this.restaurant,
  });

  factory DishDetail.fromJson(Map<String, dynamic> json) {
    // 1. Parse reviews
    var rawReviews = json['reviews'] as List? ?? [];
    List<Review> parsedReviews =
        rawReviews.map((r) => Review.fromJson(r)).toList();

    // 2. Parse restaurant
    Restaurant? parsedRestaurant = json['restaurant'] != null
        ? Restaurant.fromJson(json['restaurant'])
        : null;

    // 3. Return the fully populated object (All missing fields added below!)
    return DishDetail(
      id: json['id'] ?? json['dish_id'] ?? 0,
      name: json['name'] ?? json['dish_name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // 👈 WAS MISSING
      rating: (json['average_rating'] as num?)?.toDouble() ?? 
              (json['rating'] as num?)?.toDouble() ?? 0.0,
      menuCategory: json['menu_category'] ?? '',         // 👈 WAS MISSING
      isSpicy: json['is_spicy'] ?? false,                // 👈 WAS MISSING
      description: json['description'],                  // 👈 WAS MISSING
      imageUrl: json['imageUrl'] ?? json['image_url'],   // 👈 WAS MISSING
      restaurantId: json['restaurant_id'] ?? json['restaurant']?['id'],
      restaurantName: json['restaurant_name'] ?? json['restaurant']?['name'],
      restaurantAddress: json['restaurant_address'] ?? json['restaurant']?['address'],
      reviews: parsedReviews,
      restaurant: parsedRestaurant, 
    );
  }
}