import 'user.dart'; // Make sure you have your User model created too!

class Review {
  // Base fields (from ReviewBase)
  final int dishId;
  final int userId;
  final int rating;
  final String? tags;
  final String? comment;

  // Response fields (from ReviewResponse)
  final int reviewId;
  final DateTime createdAt;
  final User reviewer;

  const Review({
    required this.dishId,
    required this.userId,
    required this.rating,
    this.tags,
    this.comment,
    required this.reviewId,
    required this.createdAt,
    required this.reviewer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      dishId: json['dish_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] ?? 5, // Default to 5 matching your Python Field
      comment: json['comment'],
      reviewId: json['id'] ?? json['review_id'] ?? 0, // Handles validation_alias="id"
      createdAt: DateTime.parse(json['created_at']),
      reviewer: User.fromJson(json['reviewer'] ?? {}),
    );
  }
}