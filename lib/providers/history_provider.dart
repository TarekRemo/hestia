import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/action_history.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<ActionHistory> _history = [];
  List<ActionHistory> _todayHistory = [];
  bool _isLoading = false;

  List<ActionHistory> get history => _history;
  List<ActionHistory> get todayHistory => _todayHistory;
  bool get isLoading => _isLoading;

  Future<void> loadHistory(int userId, {String? startDate, String? endDate}) async {
    _isLoading = true;
    notifyListeners();
    _history = await _db.getHistoryForUser(userId, startDate: startDate, endDate: endDate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayHistory(int userId) async {
    _todayHistory = await _db.getTodayHistory(userId);
    notifyListeners();
  }

  Future<void> logAction(ActionHistory entry) async {
    await _db.insertHistory(entry);
    // Refresh today history
    notifyListeners();
  }

  Future<void> updateEntry(ActionHistory entry) async {
    await _db.updateHistory(entry);
    notifyListeners();
  }

  Future<List<ActionHistory>> getActionHistory(int actionId, {int? limit}) async {
    return await _db.getHistoryForAction(actionId, limit: limit);
  }

  Future<double> getSuccessRate(int actionId) async {
    return await _db.getActionSuccessRate(actionId);
  }

  Future<Map<String, double>> getScoreEvolution(int userId, int days) async {
    return await _db.getScoreEvolution(userId, days);
  }

  int calculateDayScore(List<ActionHistory> entries) {
    int score = 0;
    for (var entry in entries) {
      score += entry.scoreImpact;
    }
    return score;
  }
}
