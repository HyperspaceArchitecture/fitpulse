import 'package:fitpulse/features/coach/domain/coach_service.dart';

/// Placeholder boundary for the future secure Gemini proxy.
///
/// The API key must live on a server-side proxy; Flutter should never ship it
/// in the client bundle. Until that proxy is configured, the offline service
/// remains the active implementation.
class GeminiCoachService implements CoachService {
  const GeminiCoachService({this.endpoint = '/api/pulse'});

  final String endpoint;

  @override
  Future<String> respond(String message) async {
    throw StateError(
      'Gemini is not configured. Connect the secure proxy at $endpoint.',
    );
  }
}
