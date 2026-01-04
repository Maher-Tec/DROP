import 'dart:math';

/// Motivation Service - Random calming quotes and affirmations
/// 
/// Provides motivational messages for the completed drop state
class MotivationService {
  static final Random _random = Random();
  
  /// Calming quotes for after dropping
  static const List<String> _completedQuotes = [
    "You chose peace today.",
    "What you release can no longer weigh you down.",
    "Every drop lightens the load.",
    "You made space for calm.",
    "Letting go is an act of courage.",
    "You trusted the process.",
    "Today you chose yourself.",
    "Some things are better released than held.",
    "You gave yourself permission to let go.",
    "Release is a form of self-care.",
    "You honored your feelings today.",
    "The weight you carried is now gone.",
    "Peace begins with small releases.",
    "You showed up for yourself.",
    "Not everything needs to be carried forever.",
  ];
  
  /// Short affirmations for main screen
  static const List<String> _shortAffirmations = [
    "You released today.",
    "Today's thought is gone.",
    "It's in the water now.",
    "You let something go.",
    "One less weight to carry.",
  ];
  
  /// Get a random completed quote
  static String getRandomQuote() {
    return _completedQuotes[_random.nextInt(_completedQuotes.length)];
  }
  
  /// Get a random short affirmation
  static String getRandomAffirmation() {
    return _shortAffirmations[_random.nextInt(_shortAffirmations.length)];
  }
  
  /// Get streak message based on count
  static String getStreakMessage(int streak) {
    if (streak <= 0) return '';
    if (streak == 1) return '1 day of releasing';
    if (streak < 7) return '$streak days of releasing';
    if (streak < 30) return '$streak day streak 🔥';
    return '$streak day streak ✨';
  }
  
  /// Get time-based greeting
  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening';
    } else {
      return 'Welcome back';
    }
  }
  
  /// Get calming sub-greeting for home screen
  static String getSubGreeting() {
    final greetings = [
      'Take a moment for yourself.',
      'Ready to release?',
      'Find your calm.',
      'This is your safe space.',
      'Breathe. Release. Let go.',
    ];
    return greetings[_random.nextInt(greetings.length)];
  }
}
