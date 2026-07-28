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
      // 🎯 Strict Primary Key (No fake fallback)
      id: json['dish_id'] as int,

      // 🎯 Direct field matches from FastAPI JSON
      name: json['dish_name'] as String? ?? 'Unknown Dish',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      menuCategory: json['menu_category'] as String? ?? 'Uncategorized',
      isSpicy: json['is_spicy'] as bool? ?? false,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,

      // 🎯 Restaurant fields flattened by FastAPI validation_alias
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