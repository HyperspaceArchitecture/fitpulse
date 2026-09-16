import 'dart:convert';
import 'package:fitpulse/features/coach/domain/coach_persona.dart';
import 'package:fitpulse/features/coach/domain/coach_service.dart';
import 'package:http/http.dart' as http;

/// OmniRoute-powered AI Coach service.
///
/// Routes coaching requests through a local or remote OmniRoute gateway
/// (https://github.com/diegosouzapw/OmniRoute), which provides:
/// - One endpoint across 352+ AI providers (150+ free)
/// - Auto-fallback if a provider hits quota or rate limits
/// - 15–95% token compression (RTK + Caveman)
/// - ~1.47B free tokens/month from pooled free tiers
///
/// Requires OmniRoute to be running at [endpoint] (default localhost:20128).
/// No API key needed for free providers like OpenCode, Mistral, Groq, etc.
///
/// Setup:
/// 1. Install OmniRoute: `npm install -g omniroute`
/// 2. Start server: `omniroute`
/// 3. Verify: `curl http://localhost:20128/v1/models`
class OmniRouteCoachService implements CoachService {
  OmniRouteCoachService({
    this.endpoint = 'http://localhost:20128',
    this.model = 'auto',
    this.apiKey,
    this.persona = CoachPersona.drill,
  });

  /// OmniRoute gateway root URL (no /v1 suffix).
  /// Default: http://localhost:20128 (local)
  /// Remote: http://192.168.1.100:20128 or https://omniroute.example.com
  final String endpoint;

  /// Which model/combo to use.
  /// - `auto` — OmniRoute picks the best provider (default, recommended)
  /// - `auto/cheap` — Lowest cost first
  /// - `auto/fast` — Lowest latency first
  /// - `auto/offline` — Most remaining quota first
  /// - `claude-opus-4-8` — Specific model
  /// - `kimi-k3` — Specific provider model
  final String model;

  /// Optional API key for authenticated providers (free tiers don't need one).
  /// If set, passed as x-api-key header.
  /// Can be read from env: `export OMNIROUTE_API_KEY=oma_live_xxx`
  final String? apiKey;

  /// Coaching voice, derived from the user's selected theme.
  /// See [CoachPersona.forTheme].
  final CoachPersona persona;

  static const _timeout = Duration(seconds: 30);
  static const _maxRetries = 2;

  /// Safety and scope rules shared by every persona. These are not
  /// overridable by voice: the persona changes tone, never the boundaries.
  static const _safetyPrompt = '''You are the FitPulse AI Coach, a fitness and recovery expert.

Your role:
- Provide safe, evidence-based coaching on workouts, form, recovery, and nutrition
- Prioritize user safety—flag any signs of overtraining, injury, or medical concerns
- Offer actionable guidance tailored to the user's fitness level (tone is set by VOICE below)
- Keep responses concise (under 150 words unless detail is critical)
- If asked about medical conditions, strongly encourage professional consultation

Never:
- Diagnose medical conditions
- Recommend stopping prescribed treatment
- Provide advice on unlicensed supplements or drugs
- Assume the user's fitness level or history
''';

  /// The full system prompt: shared safety rules plus the persona's voice.
  String get _systemPrompt => '${_safetyPrompt}\n\n${persona.voicePrompt}';

  @override
  Future<String> respond(String message) async {
    try {
      final uri = Uri.parse('$endpoint/v1/chat/completions');

      final payload = {
        'model': model,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': message},
        ],
        'temperature': 0.7,
        'max_tokens': 300,
      };

      final headers = {
        'Content-Type': 'application/json',
        if (apiKey != null) 'x-api-key': apiKey!,
      };

      // Attempt request with retry loop
      for (int attempt = 0; attempt <= _maxRetries; attempt++) {
        try {
          final response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(payload),
          ).timeout(_timeout);

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final content = data['choices'][0]['message']['content'] as String?;
            if (content != null && content.isNotEmpty) {
              return content;
            }
          } else if (response.statusCode == 429 && attempt < _maxRetries) {
            // Rate limited; backoff and retry
            await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
            continue;
          } else {
            // Other error; fall through to exception
            throw HttpException(
              'OmniRoute returned ${response.statusCode}',
              response.body,
            );
          }
        } on http.ClientException catch (e) {
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
            continue;
          }
          rethrow;
        }
      }

      throw Exception('Failed to get response from OmniRoute after $_maxRetries attempts');
    } catch (e) {
      // Fallback: return safe default response on any error
      return _fallbackResponse(e.toString());
    }
  }

  /// Safe fallback response when OmniRoute is unavailable.
  String _fallbackResponse(String error) {
    // Log the error (in a real app, use a logger)
    print('OmniRouteCoachService error: $error');

    // Return a helpful offline message
    return '''FitPulse Coach is offline—try again in a moment.

In the meantime: keep today simple, follow your planned session at a controlled effort, and leave two reps in reserve. You're building momentum. 💪''';
  }
}

/// HTTP exception wrapper for clearer error handling.
class HttpException implements Exception {
  HttpException(this.message, this.body);

  final String message;
  final String body;

  @override
  String toString() => 'HttpException: $message\nBody: $body';
}
