import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String? productId;
  final String? reviewerId;
  final int rating;
  final String comment;
  final bool flagged;
  final DateTime? createdAt;

  const ReviewEntity({
    required this.id,
    this.productId,
    this.reviewerId,
    this.rating = 0,
    this.comment = '',
    this.flagged = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    reviewerId,
    rating,
    comment,
    flagged,
    createdAt,
  ];
}
