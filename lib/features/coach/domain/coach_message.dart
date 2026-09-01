/// Author of a message in the coaching conversation.
enum CoachRole { member, coach }

/// One immutable message exchanged with the coach.
class CoachMessage {
  /// Creates a coaching message.
  const CoachMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  /// Stable message identifier.
  final String id;

  /// Message author.
  final CoachRole role;

  /// Plain-text message content.
  final String text;

  /// UTC creation timestamp.
  final DateTime createdAt;
}
