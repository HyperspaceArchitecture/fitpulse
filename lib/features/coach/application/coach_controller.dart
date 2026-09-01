import 'package:fitpulse/features/coach/data/offline_coach_service.dart';
import 'package:fitpulse/features/coach/domain/coach_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable state for the coaching conversation.
class CoachState {
  /// Creates coaching state.
  const CoachState({required this.messages, required this.responding});

  /// Ordered conversation messages.
  final List<CoachMessage> messages;

  /// Whether a response is being prepared.
  final bool responding;

  CoachState copyWith({List<CoachMessage>? messages, bool? responding}) {
    return CoachState(
      messages: messages ?? this.messages,
      responding: responding ?? this.responding,
    );
  }
}

/// Manages message validation and coaching responses.
class CoachController extends Notifier<CoachState> {
  @override
  CoachState build() {
    return CoachState(
      responding: false,
      messages: [
        CoachMessage(
          id: 'welcome',
          role: CoachRole.coach,
          text: 'I’m your offline FitPulse coach. I can help adjust training, recovery, nutrition habits, and motivation without sending this chat off your device.',
          createdAt: DateTime.now().toUtc(),
        ),
      ],
    );
  }

  /// Adds a member message and requests one response.
  Future<void> send(String rawMessage) async {
    final message = rawMessage.trim();
    if (message.isEmpty || state.responding) return;

    final now = DateTime.now().toUtc();
    state = state.copyWith(
      responding: true,
      messages: [
        ...state.messages,
        CoachMessage(
          id: 'member-${now.microsecondsSinceEpoch}',
          role: CoachRole.member,
          text: message,
          createdAt: now,
        ),
      ],
    );

    final response = await ref.read(coachServiceProvider).respond(message);
    final responseTime = DateTime.now().toUtc();
    state = state.copyWith(
      responding: false,
      messages: [
        ...state.messages,
        CoachMessage(
          id: 'coach-${responseTime.microsecondsSinceEpoch}',
          role: CoachRole.coach,
          text: response,
          createdAt: responseTime,
        ),
      ],
    );
  }

  /// Starts a fresh conversation while preserving the safety introduction.
  void clear() {
    state = build();
  }
}

/// Owns the current offline coaching conversation.
final coachControllerProvider = NotifierProvider<CoachController, CoachState>(
  CoachController.new,
);
