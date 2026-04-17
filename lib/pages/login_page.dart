import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_snackbar.dart';
import '../widgets/focus_fill_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);
  static const _encoderItBlue = Color(0xFF1480D6);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = Get.find<AuthController>();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    Future<void> openForgotPasswordDialog() async {
      await Get.dialog<bool>(
        _ForgotPasswordDialog(
          initialEmail: _emailController.text.trim(),
          onSend: (email) => auth.sendPasswordResetEmail(email: email),
        ),
        barrierDismissible: true,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 18, 24, 18 + keyboardInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _primary.withValues(alpha: 0.08),
                    ),
                    child: Image.asset(
                      'assets/images/robo_doc_app_logo.png',
                      width: 50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Robo Doc',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome to RoboDoc.',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                  color: Colors.black,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign in to your dashboard.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.8),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 32),
              _FieldLabel('EMAIL ADDRESS'),
              const SizedBox(height: 10),
              FocusFillTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                hintText: 'Enter your email address',
                baseFillColor: const Color(0xFFEFEFEF),
                focusedFillColor: _secondary.withValues(alpha: 0.12),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Email is required';
                  if (!AuthController.isValidEmail(value)) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 22),
              _FieldLabel('PASSWORD'),
              const SizedBox(height: 10),
              FocusFillTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                hintText: 'Enter your password',
                baseFillColor: const Color(0xFFEFEFEF),
                focusedFillColor: _secondary.withValues(alpha: 0.12),
                textInputAction: TextInputAction.done,
                validator: (v) {
                  final value = (v ?? '');
                  if (value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Minimum 6 characters';
                  return null;
                },
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) =>
                                  setState(() => _rememberMe = value ?? false),
                              activeColor: _primary,
                            ),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: openForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: _secondary,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(10, 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 47,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Obx(() {
                  final loading = auth.isLoading.value;
                  return ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            final ok = _formKey.currentState?.validate() ?? false;
                            if (!ok) return;
                            auth.signInWithEmail(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                  );
                }),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.black.withValues(alpha: 0.08), height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.45),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.black.withValues(alpha: 0.08), height: 1),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      onPressed: auth.isLoading.value ? null : () => auth.signInWithGoogle(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.apple,
                      label: 'Apple ID',
                      onPressed: () => AppSnackbar.show(
                        'Coming soon',
                        'Apple ID login will be available in a future update.',
                        isError: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      'New to RoboDoc? ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.signUp),
                      style: TextButton.styleFrom(
                        foregroundColor: _secondary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(10, 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Create an account',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                Text(
                                  'Powered By',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/encoder_it_logo.jpeg',
                                  height: 18,
                                  width: 18,
                                ),
                                Text(
                                  'EncoderIT Limited',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: _encoderItBlue,
                                    fontWeight: FontWeight.w800,
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
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.black.withValues(alpha: 0.55),
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  final Future<bool> Function(String email) onSend;

  const _ForgotPasswordDialog({
    required this.initialEmail,
    required this.onSend,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _emailCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_loading) return;
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      AppSnackbar.show('Email required', 'Please enter your email address.');
      return;
    }
    setState(() => _loading = true);
    if (mounted) {
      Get.back(result: true);
    }
    await widget.onSend(email);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'Enter your email',
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _loading ? null : _send,
          child: Text(_loading ? 'Sending...' : 'Send'),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: Colors.black.withValues(alpha: 0.8)),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.85),
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.03),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

