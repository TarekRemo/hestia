class GiftCardRedemption {
  final int? id;
  final int userId;
  final String storeName;
  final int pointsSpent;
  final double euroValue;
  final String? redeemedAt;

  GiftCardRedemption({
    this.id,
    required this.userId,
    required this.storeName,
    required this.pointsSpent,
    required this.euroValue,
    this.redeemedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'points_spent': pointsSpent,
      'euro_value': euroValue,
      'redeemed_at': redeemedAt,
    };
  }

  factory GiftCardRedemption.fromMap(Map<String, dynamic> map) {
    return GiftCardRedemption(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      storeName: map['store_name'] as String,
      pointsSpent: map['points_spent'] as int,
      euroValue: (map['euro_value'] as num).toDouble(),
      redeemedAt: map['redeemed_at'] as String?,
    );
  }
}
