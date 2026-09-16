import 'package:fitpulse/features/coach/domain/coach_service.dart';

/// Replaced by OmniRouteCoachService (v4.0+).
///
/// OmniRoute provides:
/// - 352+ AI providers (150+ free) through one endpoint
/// - Auto-fallback + quota management
/// - 15–95% token compression
/// - ~1.47B free tokens/month from pooled free tiers
///
/// The API key requirement is eliminated: OmniRoute routes through free tiers
/// (OpenCode, Mistral, Groq, etc.) by default, with auto-fallback.
/// See: https://github.com/diegosouzapw/OmniRoute
@Deprecated('Use OmniRouteCoachService instead. Kept for reference only.')
class GeminiCoachService implements CoachService {
  const GeminiCoachService({this.endpoint = '/api/pulse'});

  final String endpoint;

  @override
  Future<String> respond(String message) async {
    throw StateError(
      'Gemini service is deprecated. Use OmniRouteCoachService instead.\n'
      'See: https://github.com/diegosouzapw/OmniRoute',
    );
  }
}
