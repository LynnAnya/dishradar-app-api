import 'user.dart';

class Review {
  final int reviewId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final User reviewer;

  const Review({
    required this.reviewId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.reviewer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      // Maps FastAPI's 'review_id' (or 'id') directly
      reviewId: json['review_id'] ?? json['id'] ?? 0,
      rating: json['rating'] ?? 5,
      comment: json['comment'] as String?,
      // Safe DateTime parsing
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      reviewer: User.fromJson(json['reviewer'] as Map<String, dynamic>? ?? {}),
    );
  }
}