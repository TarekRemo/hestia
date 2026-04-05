import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/app_user.dart';
import '../models/discipline_badge.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  AppUser? _user;
  List<DisciplineBadge> _badges = [];
  DisciplineBadge? _currentBadge;
  bool _isLoading = true;

  AppUser? get user => _user;
  List<DisciplineBadge> get badges => _badges;
  DisciplineBadge? get currentBadge => _currentBadge;
  bool get isLoading => _isLoading;
  bool get hasUser => _user != null;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    _user = await _db.getUser();
    _badges = await _db.getAllBadges();
    if (_user != null) {
      _currentBadge = await _db.getBadgeForStreak(_user!.currentDisciplineStreak);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUser(AppUser user) async {
    final id = await _db.insertUser(user);
    _user = user.copyWith(id: id);
    _currentBadge = await _db.getBadgeForStreak(0);
    notifyListeners();
  }

  Future<void> updateUser(AppUser user) async {
    await _db.updateUser(user);
    _user = user;
    _currentBadge = await _db.getBadgeForStreak(user.currentDisciplineStreak);
    notifyListeners();
  }

  Future<void> updateScore(int newScore) async {
    if (_user == null) return;
    await _db.updateUserScore(_user!.id!, newScore);
    _user = _user!.copyWith(totalScore: newScore);
    notifyListeners();
  }

  Future<void> refreshScore() async {
    if (_user == null) return;
    final score = await _db.calculateTotalScore(_user!.id!);
    await updateScore(score);
  }

  Future<void> updateStreak(int current, int max) async {
    if (_user == null) return;
    await _db.updateUserStreak(_user!.id!, current, max);
    _user = _user!.copyWith(currentDisciplineStreak: current, maxDisciplineStreak: max);
    _currentBadge = await _db.getBadgeForStreak(current);
    notifyListeners();
  }
}
