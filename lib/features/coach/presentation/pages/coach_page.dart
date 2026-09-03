import 'package:fitpulse/core/theme/app_theme.dart';
import 'package:fitpulse/features/coach/application/coach_controller.dart';
import 'package:fitpulse/features/coach/domain/coach_message.dart';
import 'package:fitpulse/shared/widgets/glass_panel.dart';
import 'package:fitpulse/shared/widgets/member_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Privacy-first coaching conversation with an offline fallback.
class CoachPage extends ConsumerStatefulWidget {
  /// Creates the coach page.
  const CoachPage({super.key});

  @override
  ConsumerState<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends ConsumerState<CoachPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggestion]) async {
    final message = suggestion ?? _messageController.text;
    if (message.trim().isEmpty) return;
    _messageController.clear();
    await ref.read(coachControllerProvider.notifier).send(message);
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coachControllerProvider);
    final colors = Theme.of(context).extension<FitPulseColors>()!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -280,
            bottom: -320,
            child: _CoachGlow(color: colors.glow),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      MemberPageHeader(
                        actionIcon: Icons.refresh_rounded,
                        actionTooltip: 'New conversation',
                        onAction: ref
                            .read(coachControllerProvider.notifier)
                            .clear,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GlassPanel(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              const _CoachHeading(),
                              const Divider(height: 1),
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(22),
                                  itemCount:
                                      state.messages.length +
                                      (state.responding ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == state.messages.length) {
                                      return const _ThinkingBubble();
                                    }
                                    return _MessageBubble(
                                      message: state.messages[index],
                                    );
                                  },
                                ),
                              ),
                              _Composer(
                                controller: _messageController,
                                enabled: !state.responding,
                                onSend: _send,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              [
                                    'I feel tired today',
                                    'Help with motivation',
                                    'What should I eat?',
                                    'The scale is stuck',
                                  ]
                                  .map(
                                    (text) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ActionChip(
                                        label: Text(text),
                                        onPressed: state.responding
                                            ? null
                                            : () => _send(text),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachHeading extends StatelessWidget {
  const _CoachHeading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Text('🙂', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pulse', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  'Offline guidance · not medical advice',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text('PRIVATE'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final CoachMessage message;

  @override
  Widget build(BuildContext context) {
    final member = message.role == CoachRole.member;
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: member ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 610),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: member ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(member ? 20 : 5),
            bottomRight: Radius.circular(member ? 5 : 20),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: member ? scheme.onPrimary : scheme.onSurface),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          key: const Key('coach-message-field'),
          controller: controller,
          enabled: enabled,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            hintText: 'Ask about today’s plan…',
            suffixIcon: IconButton(
              tooltip: 'Send message',
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachGlow extends StatelessWidget {
  const _CoachGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.24), color.withValues(alpha: 0)],
          ),
        ),
        child: const SizedBox.square(dimension: 700),
      ),
    );
  }
}
