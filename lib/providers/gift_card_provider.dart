import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/gift_card_redemption.dart';
import '../models/partner_store.dart';

class GiftCardProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<GiftCardRedemption> _redemptions = [];
  bool _isLoading = false;

  List<GiftCardRedemption> get redemptions => _redemptions;
  bool get isLoading => _isLoading;

  Future<void> loadRedemptions(int userId) async {
    _isLoading = true;
    notifyListeners();
    _redemptions = await _db.getGiftCardRedemptions(userId);
    _isLoading = false;
    notifyListeners();
  }

  /// Returns available points (totalScore minus already redeemed points).
  Future<int> getAvailablePoints(int userId, int totalScore) async {
    final redeemed = await _db.getTotalPointsRedeemed(userId);
    final available = totalScore - redeemed;
    return available > 0 ? available : 0;
  }

  /// Redeems a gift card. Returns true on success.
  Future<bool> redeemGiftCard({
    required int userId,
    required int totalScore,
    required PartnerStore store,
    required int euroAmount,
  }) async {
    final pointsCost = PartnerStore.euroToPoints(euroAmount);
    final available = await getAvailablePoints(userId, totalScore);
    if (pointsCost > available) return false;

    final redemption = GiftCardRedemption(
      userId: userId,
      storeName: store.name,
      pointsSpent: pointsCost,
      euroValue: euroAmount.toDouble(),
    );
    await _db.insertGiftCardRedemption(redemption);
    await loadRedemptions(userId);
    return true;
  }
}
