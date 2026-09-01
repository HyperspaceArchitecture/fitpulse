/// Boundary for local or remote coaching response generation.
abstract interface class CoachService {
  /// Produces a safe coaching response to [message].
  Future<String> respond(String message);
}
