// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cityfix_mobile/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../shared/custom_text_field.dart';
import '../../../shared/custom_toast.dart';

import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // Shared
  final _nameCtrl = TextEditingController();

  // Phone tab
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _phonePassCtrl = TextEditingController();
  bool _phoneObscure = true;

  // Email tab
  final _emailFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  // Animation controller for the submit button
  late final AnimationController _btnAnimController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _btnAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _phonePassCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _btnAnimController.dispose();
    super.dispose();
  }

  // ── Phone registration ──────────────────────────────────────────────────
  Future<void> _submitPhone() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).registerWithPhone(
          _nameCtrl.text.trim(),
          _phoneCtrl.text.trim(),
          _phonePassCtrl.text,
        );

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      final l = AppLocalizations.of(context)!;
      ToastService.showError(context, _mapEmailError(authState.error, l));
    }
  }

  // ── Email registration ──────────────────────────────────────────────────
  Future<void> _submitEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      final l = AppLocalizations.of(context)!;
      ToastService.showError(context, _mapEmailError(authState.error, l));
    }
  }

  String _mapEmailError(Object? error, AppLocalizations l) {
    if (error == null) return l.registrationFailed('Unknown error');
    final e = error.toString().toLowerCase();
    if (e.contains('email-already-in-use')) return l.errorEmailInUse;
    if (e.contains('invalid-email')) return l.emailInvalid;
    if (e.contains('network-request-failed')) return l.errorNetwork;
    return l.registrationFailed(error.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l.createAccount, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: BackButton(onPressed: () => context.go('/login')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // ── Background Gradient & Shapes ─────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.surface,
                    cs.primary.withValues(alpha: 0.05),
                    cs.surface,
                    cs.secondary.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).custom(
                duration: 12.seconds,
                curve: Curves.easeInOut,
                builder: (context, value, child) => Transform.translate(
                      offset: Offset(30.0 * (value - 0.5), 0),
                      child: child,
                    )),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Icon & Header ──────────────────────────────────────────
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.3),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(Icons.person_add_rounded,
                              size: 48, color: cs.primary),
                        ),
                      ),
                    ).animate().fade(duration: 600.ms).scale(delay: 100.ms),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join CityFix',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 32),

                  // ── Glassmorphic Form Card ───────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.05),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Full Name (shared) ─────────────────────────
                            CustomTextField(
                              label: l.fullName,
                              hint: l.fullNameHint,
                              controller: _nameCtrl,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? l.fullNameRequired : null,
                            ),
                            const SizedBox(height: 24),

                            // ── Tab bar ──────────────────────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: TabBar(
                                controller: _tabController,
                                indicator: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                                labelColor: cs.onPrimary,
                                unselectedLabelColor: cs.onSurfaceVariant,
                                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                                tabs: [
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.phone_rounded, size: 16),
                                        const SizedBox(width: 8),
                                        Text(l.registerWithPhone),
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.email_rounded, size: 16),
                                        const SizedBox(width: 8),
                                        Text(l.registerWithEmail),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Tab content ──────────────────────────────
                            SizedBox(
                              height: 300, // Increased height for forms + button to prevent overflow
                              child: TabBarView(
                                controller: _tabController,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  // ── Phone tab ──
                                  Form(
                                    key: _phoneFormKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        CustomTextField(
                                          label: l.phoneNumber,
                                          hint: l.phoneHint,
                                          controller: _phoneCtrl,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          prefixIcon: const Icon(Icons.phone_rounded),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return l.phoneRequired;
                                            if (!v.startsWith('+') || v.length < 8) {
                                              return l.phoneInvalid;
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          label: l.password,
                                          controller: _phonePassCtrl,
                                          obscureText: _phoneObscure,
                                          textInputAction: TextInputAction.done,
                                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                                          suffixIcon: IconButton(
                                            icon: Icon(_phoneObscure
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded),
                                            onPressed: () =>
                                                setState(() => _phoneObscure = !_phoneObscure),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.length < 6) return l.passwordRequired;
                                            return null;
                                          },
                                        ),
                                        const Spacer(),
                                        _buildSubmitButton(
                                          isLoading: isLoading,
                                          onPressed: () {
                                            _btnAnimController.forward().then((_) => _btnAnimController.reverse());
                                            _submitPhone();
                                          },
                                          label: l.createAccount,
                                          icon: Icons.person_add_rounded,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ── Email tab ──
                                  Form(
                                    key: _emailFormKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
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
                                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscure
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded),
                                            onPressed: () =>
                                                setState(() => _obscure = !_obscure),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.length < 6) return l.passwordRequired;
                                            return null;
                                          },
                                        ),
                                        const Spacer(),
                                        _buildSubmitButton(
                                          isLoading: isLoading,
                                          onPressed: () {
                                            _btnAnimController.forward().then((_) => _btnAnimController.reverse());
                                            _submitEmail();
                                          },
                                          label: l.createAccount,
                                          icon: Icons.person_add_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Login Link ───────────────────────────────────────────
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: Text(l.alreadyHaveAccount),
                  ).animate().fade(delay: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton({
    required bool isLoading,
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _btnAnimController, curve: Curves.easeInOut),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cs.primary, cs.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(icon, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
