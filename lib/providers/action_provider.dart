import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/discipline_action.dart';
import '../models/action_time_slot.dart';
import '../models/action_importance.dart';

class ActionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<DisciplineAction> _actions = [];
  List<ActionImportance> _importanceLevels = [];
  bool _isLoading = false;

  List<DisciplineAction> get actions => _actions;
  List<ActionImportance> get importanceLevels => _importanceLevels;
  bool get isLoading => _isLoading;

  List<DisciplineAction> get positiveActions =>
      _actions.where((a) => a.isPositive).toList();

  List<DisciplineAction> get negativeActions =>
      _actions.where((a) => !a.isPositive).toList();

  Future<void> loadActions(int userId) async {
    _isLoading = true;
    notifyListeners();
    _actions = await _db.getActionsForUser(userId);
    _importanceLevels = await _db.getAllImportanceLevels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadImportanceLevels() async {
    _importanceLevels = await _db.getAllImportanceLevels();
    notifyListeners();
  }

  Future<int> addAction(DisciplineAction action, List<ActionTimeSlot> timeSlots) async {
    final actionId = await _db.insertAction(action);
    for (var slot in timeSlots) {
      await _db.insertTimeSlot(ActionTimeSlot(
        actionId: actionId,
        startTime: slot.startTime,
        endTime: slot.endTime,
      ));
    }
    final newAction = await _db.getAction(actionId);
    if (newAction != null) {
      _actions.insert(0, newAction);
    }
    notifyListeners();
    return actionId;
  }

  Future<void> updateAction(DisciplineAction action, List<ActionTimeSlot> timeSlots) async {
    await _db.updateAction(action);
    await _db.deleteTimeSlotsForAction(action.id!);
    for (var slot in timeSlots) {
      await _db.insertTimeSlot(ActionTimeSlot(
        actionId: action.id,
        startTime: slot.startTime,
        endTime: slot.endTime,
      ));
    }
    final updated = await _db.getAction(action.id!);
    if (updated != null) {
      final index = _actions.indexWhere((a) => a.id == action.id);
      if (index != -1) {
        _actions[index] = updated;
      }
    }
    notifyListeners();
  }

  Future<void> deleteAction(int actionId) async {
    await _db.deleteAction(actionId);
    _actions.removeWhere((a) => a.id == actionId);
    notifyListeners();
  }

  Future<List<ActionTimeSlot>> getTimeSlots(int actionId) async {
    return await _db.getTimeSlotsForAction(actionId);
  }

  Future<void> updateActionStreak(int actionId, int current, int record) async {
    await _db.updateActionStreak(actionId, current, record);
    final updated = await _db.getAction(actionId);
    if (updated != null) {
      final idx = _actions.indexWhere((a) => a.id == actionId);
      if (idx != -1) _actions[idx] = updated;
    }
    notifyListeners();
  }
}
