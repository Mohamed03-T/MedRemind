import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class CalendarProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  // cache of completed medication IDs per date (yyyy-MM-dd)
  // Mapping date -> {medicationId -> count}
  final Map<String, Map<int, int>> _completionsCache = {};
  DateTime? _lastLoadedMonth;

  CalendarProvider() {
    // Listen for completion updates from notifications
    NotificationService().onDataChanged = () {
      if (_lastLoadedMonth != null) {
        loadForMonth(_lastLoadedMonth!);
      } else {
        _completionsCache.clear();
        notifyListeners();
      }
    };
  }

  int completionsFor(DateTime date, int medId) {
    final key = _key(date);
    return _completionsCache[key]?[medId] ?? 0;
  }

  /// Returns total count of all completions on this date
  int totalCompletionsFor(DateTime date) {
    final key = _key(date);
    int sum = 0;
    _completionsCache[key]?.forEach((_, count) => sum += count);
    return sum;
  }

  Future<void> loadForDate(DateTime date) async {
    final key = _key(date);
    final list = await _db.getCompletionsForDate(key);
    
    final Map<int, int> counts = {};
    for (var medId in list) {
      counts[medId] = (counts[medId] ?? 0) + 1;
    }
    _completionsCache[key] = counts;
    notifyListeners();
  }

  Future<void> toggleCompletion(DateTime date, int medicationId) async {
    final key = _key(date);
    final counts = _completionsCache.putIfAbsent(key, () => <int, int>{});
    
    // Toggle logic is tricky with multiple occurrences.
    if (counts.containsKey(medicationId) && counts[medicationId]! > 0) {
      counts.remove(medicationId);
      await _db.deleteCompletion(key, medicationId);
    } else {
      counts[medicationId] = 1;
      await _db.insertCompletion(key, medicationId);
    }
    notifyListeners();
  }

  Future<void> addOccurrenceCompletion(DateTime date, int medicationId) async {
    final key = _key(date);
    final counts = _completionsCache.putIfAbsent(key, () => <int, int>{});
    counts[medicationId] = (counts[medicationId] ?? 0) + 1;
    await _db.insertCompletion(key, medicationId);
    
    // Decrement pills and check for low stock
    final remaining = await _db.decrementPills(medicationId);
    if (remaining != null && remaining > 0 && remaining <= 5) {
      await NotificationService().showLowStockNotification(medicationId, remaining);
    }
    
    notifyListeners();
  }

  Future<void> deleteCompletionsForMed(int medicationId) async {
    await _db.deleteCompletionsForMed(medicationId);
    // remove from cache
    for (final key in _completionsCache.keys) {
      _completionsCache[key]?.remove(medicationId);
    }
    notifyListeners();
  }

  Future<void> loadForMonth(DateTime month) async {
    _lastLoadedMonth = month;
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    
    final startDateStr = _key(start);
    final endDateStr = _key(end);
    
    final list = await _db.getCompletionsForRange(startDateStr, endDateStr);
    
    // Clear and refill relevant month data
    _completionsCache.clear(); 
    for (var completion in list) {
      final key = completion['date'] as String;
      final medId = completion['medicationId'] as int;
      final counts = _completionsCache.putIfAbsent(key, () => <int, int>{});
      counts[medId] = (counts[medId] ?? 0) + 1;
    }
    notifyListeners();
  }

  String _key(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
