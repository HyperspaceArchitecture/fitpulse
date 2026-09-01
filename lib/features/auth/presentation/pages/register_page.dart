import 'package:fitpulse/core/routing/app_router.dart';
import 'package:fitpulse/features/auth/domain/auth_validators.dart';
import 'package:fitpulse/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Account-creation presentation with validation and explicit consent state.
class RegisterPage extends StatefulWidget {
  /// Creates the registration screen.
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePreview() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !_acceptedTerms) return;
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Form is valid. Connect an auth service to create accounts.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Build your plan',
      subtitle: 'Create the profile your adaptive coaching will grow from.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthConnectionNotice(),
            const SizedBox(height: 22),
            AuthTextField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              validator: AuthValidators.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.alternate_email_rounded,
              validator: AuthValidators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername],
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: 'Create password',
              icon: Icons.lock_outline_rounded,
              validator: AuthValidators.password,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _acceptedTerms,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I accept the Terms and Privacy Policy'),
                onChanged: (value) {
                  setState(() => _acceptedTerms = value ?? false);
                },
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _acceptedTerms ? _validatePreview : null,
              child: const Text('Validate account details'),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already a member?'),
                TextButton(
                  onPressed: () => context.go(AppRoutes.signIn),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
