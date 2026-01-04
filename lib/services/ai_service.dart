import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI Service - OpenAI integration for personalized affirmations
/// 
/// Uses GPT to generate calming, personalized messages
class AIService {
  static const String _apiKey =
      "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";
  
  static const String _baseUrl = "https://api.openai.com/v1/chat/completions";
  
  // Fallback affirmations if API fails
  static const List<String> _fallbackAffirmations = [
    "You did the right thing.",
    "This moment matters.",
    "You're lighter now.",
    "It's okay to let go.",
    "Peace begins with release.",
    "You chose yourself today.",
    "Healing happens in small drops.",
    "Your feelings are valid.",
    "You made space for calm.",
    "This was an act of self-love.",
  ];
  
  /// Generate a personalized affirmation using AI
  /// Falls back to preset affirmations if API fails
  static Future<String> generateAffirmation({String? context}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a gentle, calming voice for people releasing emotional thoughts. 
Generate ONE short, comforting affirmation (max 8 words) for someone who just let go of a difficult thought.
Be warm but not preachy. Be simple but profound. No emojis. No punctuation except periods.
Examples: "You did the right thing." "Peace begins with release." "You chose yourself today."'''
            },
            {
              'role': 'user',
              'content': context ?? 'Generate a calming affirmation for emotional release.'
            }
          ],
          'max_tokens': 30,
          'temperature': 0.8,
        }),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['choices'][0]['message']['content'] as String;
        return message.trim();
      }
    } catch (e) {
      // Silently fall back to preset affirmations
    }
    
    // Return random fallback
    return _getRandomFallback();
  }
  
  /// Get a random preset affirmation
  static String _getRandomFallback() {
    final index = DateTime.now().millisecondsSinceEpoch % _fallbackAffirmations.length;
    return _fallbackAffirmations[index];
  }
  
  /// Get a quick affirmation (no API call)
  static String getQuickAffirmation() {
    return _getRandomFallback();
  }
}
