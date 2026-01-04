import 'package:shared_preferences/shared_preferences.dart';

/// Drop Service - Manages app state and persistence
/// 
/// Core State:
/// - hasDroppedToday: Whether user has dropped today
/// - lastDropDate: DateTime of last drop
/// - dropHistory: List of all drop dates
class DropService {
  static const String _lastDropDateKey = 'lastDropDate';
  static const String _dropHistoryKey = 'dropHistory';
  
  SharedPreferences? _prefs;
  
  DateTime? _lastDropDate;
  List<DateTime> _dropHistory = [];
  
  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadState();
  }
  
  /// Load persisted state
  void _loadState() {
    final lastDropString = _prefs?.getString(_lastDropDateKey);
    if (lastDropString != null) {
      _lastDropDate = DateTime.tryParse(lastDropString);
    }
    
    final historyStrings = _prefs?.getStringList(_dropHistoryKey) ?? [];
    _dropHistory = historyStrings
        .map((s) => DateTime.tryParse(s))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }
  
  /// Check if user can drop today
  bool canDropToday() {
    if (_lastDropDate == null) return true;
    return !_isSameDay(_lastDropDate!, DateTime.now());
  }
  
  /// Check if user has already dropped today
  bool get hasDroppedToday => !canDropToday();
  
  /// Get last drop date
  DateTime? get lastDropDate => _lastDropDate;
  
  /// Get drop history
  List<DateTime> get dropHistory => List.unmodifiable(_dropHistory);
  
  /// Save a new drop
  Future<void> saveDrop() async {
    final now = DateTime.now();
    _lastDropDate = now;
    _dropHistory.add(now);
    
    await _prefs?.setString(_lastDropDateKey, now.toIso8601String());
    await _prefs?.setStringList(
      _dropHistoryKey,
      _dropHistory.map((d) => d.toIso8601String()).toList(),
    );
  }
  
  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// Get number of total drops
  int get totalDrops => _dropHistory.length;
  
  /// Calculate current streak (consecutive days of dropping)
  int get currentStreak {
    if (_dropHistory.isEmpty) return 0;
    
    // Sort history by date
    final sorted = List<DateTime>.from(_dropHistory)
      ..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // If already dropped today, start counting from today
    if (hasDroppedToday) {
      streak = 1;
      checkDate = DateTime.now().subtract(const Duration(days: 1));
    }
    
    // Count consecutive days going backwards
    for (final dropDate in sorted) {
      if (_isSameDay(dropDate, checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (dropDate.isBefore(checkDate)) {
        // Gap found, streak ends
        break;
      }
    }
    
    return streak;
  }
  
  /// Reset for testing (optional)
  Future<void> reset() async {
    _lastDropDate = null;
    _dropHistory.clear();
    await _prefs?.remove(_lastDropDateKey);
    await _prefs?.remove(_dropHistoryKey);
  }
}

/// Global singleton instance
final dropService = DropService();
