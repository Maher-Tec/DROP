import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/drop_service.dart';
import '../widgets/lake_background.dart';

/// HISTORY SCREEN - Premium Drop Stats & Calendar
/// 
/// Features:
/// - Gorgeous stat cards with icons and gradients
/// - Interactive calendar with water drop indicators
/// - Motivational messaging
/// - Premium glassmorphism styling
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  
  bool _loading = true;
  int _totalDrops = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  List<DateTime> _dropDates = [];
  DateTime _displayedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    
    _loadStats();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    await dropService.init();
    if (mounted) {
      setState(() {
        _dropDates = dropService.dropHistory;
        _totalDrops = _dropDates.length;
        _currentStreak = dropService.currentStreak;
        _longestStreak = _calculateLongestStreak();
        _loading = false;
      });
      _animController.forward();
    }
  }

  int _calculateLongestStreak() {
    if (_dropDates.isEmpty) return 0;
    
    final sorted = List<DateTime>.from(_dropDates)
      ..sort((a, b) => a.compareTo(b));
    
    int longest = 1;
    int current = 1;
    
    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime(sorted[i - 1].year, sorted[i - 1].month, sorted[i - 1].day);
      final curr = DateTime(sorted[i].year, sorted[i].month, sorted[i].day);
      final diff = curr.difference(prev).inDays;
      
      if (diff == 1) {
        current++;
        longest = current > longest ? current : longest;
      } else if (diff > 1) {
        current = 1;
      }
    }
    
    return longest;
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
        1,
      );
    });
  }

  void _close() {
    Navigator.of(context).pop();
  }

  String _getMotivation() {
    if (_currentStreak >= 7) return '🔥 You\'re on fire! Keep releasing.';
    if (_currentStreak >= 3) return '✨ Beautiful consistency!';
    if (_totalDrops >= 10) return '💧 You\'ve let go of so much.';
    if (_totalDrops >= 1) return '🌊 Every drop counts.';
    return '💙 Start your journey today.';
  }

  @override
  Widget build(BuildContext context) {
    final fontScale = DropTheme.fontScale(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: LakeBackground(
        animate: true,
        showWaves: false,
        showReflections: true,
        showParticles: true,
        showMoonlight: true,
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      // Top bar
                      _buildTopBar(fontScale),
                      
                      const SizedBox(height: 8),
                      
                      // Motivational message
                      Text(
                        _getMotivation(),
                        style: DropTheme.taglineStyle.copyWith(
                          fontSize: 14 * fontScale,
                          color: DropTheme.softWhite.withValues(alpha: 0.6),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Premium Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildPremiumStatCard(
                              icon: Icons.water_drop_rounded,
                              value: _totalDrops.toString(),
                              label: 'TOTAL',
                              sublabel: 'drops released',
                              color: const Color(0xFF4FC3F7),
                              fontScale: fontScale,
                            ),
                            const SizedBox(width: 12),
                            _buildPremiumStatCard(
                              icon: Icons.local_fire_department_rounded,
                              value: _currentStreak.toString(),
                              label: 'STREAK',
                              sublabel: 'days in a row',
                              color: const Color(0xFFFFB74D),
                              isHighlight: _currentStreak > 0,
                              fontScale: fontScale,
                            ),
                            const SizedBox(width: 12),
                            _buildPremiumStatCard(
                              icon: Icons.emoji_events_rounded,
                              value: _longestStreak.toString(),
                              label: 'BEST',
                              sublabel: 'longest streak',
                              color: const Color(0xFFBA68C8),
                              fontScale: fontScale,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Calendar Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: DropTheme.dropAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'YOUR CALENDAR',
                              style: DropTheme.hintStyle.copyWith(
                                fontSize: 11 * fontScale,
                                color: DropTheme.dropAccent.withValues(alpha: 0.8),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Premium Calendar
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildPremiumCalendar(fontScale, size),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double fontScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    color: DropTheme.softWhite.withValues(alpha: 0.4),
                    size: 26,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'back',
                    style: DropTheme.hintStyle.copyWith(
                      fontSize: 13 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Your Journey',
                style: DropTheme.bodyStyle.copyWith(
                  fontSize: 18 * fontScale,
                  color: DropTheme.softWhite.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 30,
                height: 2,
                decoration: BoxDecoration(
                  color: DropTheme.dropAccent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildPremiumStatCard({
    required IconData icon,
    required String value,
    required String label,
    required String sublabel,
    required Color color,
    required double fontScale,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isHighlight ? 0.25 : 0.12),
              color.withValues(alpha: isHighlight ? 0.15 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: isHighlight ? 0.5 : 0.2),
            width: isHighlight ? 1.5 : 1,
          ),
          boxShadow: isHighlight
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Icon with glow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            // Value
            Text(
              value,
              style: DropTheme.titleStyle.copyWith(
                fontSize: 28 * fontScale,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: DropTheme.hintStyle.copyWith(
                fontSize: 10 * fontScale,
                color: color.withValues(alpha: 0.8),
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            // Sublabel
            Text(
              sublabel,
              style: DropTheme.hintStyle.copyWith(
                fontSize: 9 * fontScale,
                color: DropTheme.softWhite.withValues(alpha: 0.35),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCalendar(double fontScale, Size size) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday;
    
    final monthName = _getMonthName(_displayedMonth.month);
    final canGoForward = _displayedMonth.month < now.month || _displayedMonth.year < now.year;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DropTheme.deepBlue.withValues(alpha: 0.4),
            DropTheme.deepBlue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: DropTheme.softWhite.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                style: IconButton.styleFrom(
                  backgroundColor: DropTheme.softWhite.withValues(alpha: 0.05),
                ),
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: DropTheme.softWhite.withValues(alpha: 0.6),
                ),
              ),
              Column(
                children: [
                  Text(
                    monthName.toUpperCase(),
                    style: DropTheme.bodyStyle.copyWith(
                      fontSize: 14 * fontScale,
                      color: DropTheme.softWhite.withValues(alpha: 0.9),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_displayedMonth.year}',
                    style: DropTheme.hintStyle.copyWith(
                      fontSize: 11 * fontScale,
                      color: DropTheme.dropAccent.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: canGoForward ? () => _changeMonth(1) : null,
                style: IconButton.styleFrom(
                  backgroundColor: DropTheme.softWhite.withValues(alpha: canGoForward ? 0.05 : 0.02),
                ),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: DropTheme.softWhite.withValues(alpha: canGoForward ? 0.6 : 0.2),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Weekday headers with better styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((day) => SizedBox(
                      width: 36,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: DropTheme.hintStyle.copyWith(
                          fontSize: 9 * fontScale,
                          color: DropTheme.dropAccent.withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Calendar grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayOffset = index - (startWeekday - 1);
                
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox();
                }
                
                final day = dayOffset + 1;
                final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
                final hasDropped = _dropDates.any((d) =>
                    d.year == date.year && d.month == date.month && d.day == date.day);
                final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                final isFuture = date.isAfter(now);
                
                return Container(
                  decoration: BoxDecoration(
                    gradient: hasDropped
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              DropTheme.dropAccent.withValues(alpha: 0.4),
                              DropTheme.dropAccent.withValues(alpha: 0.2),
                            ],
                          )
                        : null,
                    color: isToday && !hasDropped
                        ? DropTheme.softWhite.withValues(alpha: 0.08)
                        : null,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(
                            color: DropTheme.dropAccent,
                            width: 2,
                          )
                        : null,
                    boxShadow: hasDropped
                        ? [
                            BoxShadow(
                              color: DropTheme.dropAccent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: hasDropped
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.water_drop_rounded,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 14,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '$day',
                                style: DropTheme.hintStyle.copyWith(
                                  fontSize: 10 * fontScale,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '$day',
                            style: DropTheme.hintStyle.copyWith(
                              fontSize: 13 * fontScale,
                              color: isFuture
                                  ? DropTheme.softWhite.withValues(alpha: 0.15)
                                  : isToday
                                      ? DropTheme.dropAccent
                                      : DropTheme.softWhite.withValues(alpha: 0.55),
                              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
