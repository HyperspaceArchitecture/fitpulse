import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/features/auth/domain/auth_validators.dart';
import 'package:fitpulse/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Password-recovery presentation that never claims to send without a backend.
class ForgotPasswordPage extends StatefulWidget {
  /// Creates the password recovery screen.
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validatePreview() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email is valid. No recovery message was sent.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset your password',
      subtitle: 'Enter the email associated with your FitPulse account.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthConnectionNotice(),
            const SizedBox(height: 22),
            AuthTextField(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.alternate_email_rounded,
              validator: AuthValidators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _validatePreview,
              child: const Text('Validate recovery email'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.signIn),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
