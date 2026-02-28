// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../shared/custom_text_field.dart';
import '../../../shared/custom_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
    
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      final l = AppLocalizations.of(context)!;
      final errorMessage = _getErrorMessage(authState.error, l);
      ToastService.showError(context, errorMessage);
    }
  }

  String _getErrorMessage(Object? error, AppLocalizations l) {
    if (error == null) return l.loginFailed('Unknown error');
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('invalid-credential') || 
        errorStr.contains('user-not-found') || 
        errorStr.contains('wrong-password')) {
      return l.errorInvalidCredentials;
    } else if (errorStr.contains('network-request-failed')) {
      return l.errorNetwork;
    } else if (errorStr.contains('too-many-requests')) {
      return l.errorTooManyRequests;
    }
    
    return l.loginFailed(error.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo / branding ──────────────────────────────────────
                  Icon(Icons.location_city_rounded,
                      size: 72, color: cs.primary),
                  const SizedBox(height: 8),
                  Text(
                    'CityFix',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l.appSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),

                  // ── Fields ───────────────────────────────────────────────
                  CustomTextField(
                    label: l.email,
                    hint: l.emailHint,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l.emailRequired;
                      if (!v.contains('@')) return l.emailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l.password,
                    controller: _passCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return l.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Submit ───────────────────────────────────────────────
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FilledButton(
                          onPressed: _submit,
                          child: Text(l.login),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(l.noAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
