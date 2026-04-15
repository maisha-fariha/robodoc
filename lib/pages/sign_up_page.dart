import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/focus_fill_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const _primary = Color(0xFF0E204D);
  static const _secondary = Color(0xFF21CDC0);

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agree = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                'Create your RoboDoc Account.',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                  color: Colors.black,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Join the premium standard of RoboDoc management.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black.withValues(alpha: 0.8),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const _FieldLabel('FULL NAME'),
                   const SizedBox(height: 8),
                   FocusFillTextField(
                     controller: _fullNameController,
                     focusNode: _fullNameFocus,
                     hintText: 'Enter your Full Name',
                     baseFillColor: const Color(0xFFEFEFEF),
                     focusedFillColor: _secondary.withValues(alpha: 0.12),
                     textInputAction: TextInputAction.next,
                     onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                     validator: (v) {
                       final value = (v ?? '').trim();
                       if (value.isEmpty) return 'Full name is required';
                       if (value.length < 2) return 'Enter a valid name';
                       return null;
                     },
                   ),
                   const SizedBox(height: 14),
                   const _FieldLabel('EMAIL ADDRESS'),
                   const SizedBox(height: 8),
                   FocusFillTextField(
                     controller: _emailController,
                     focusNode: _emailFocus,
                     hintText: 'Enter your Email Address',
                     keyboardType: TextInputType.emailAddress,
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
                   const SizedBox(height: 14),
                   const _FieldLabel('PASSWORD'),
                   const SizedBox(height: 8),
                   FocusFillTextField(
                     controller: _passwordController,
                     focusNode: _passwordFocus,
                     hintText: 'Enter your Password',
                     obscureText: _obscurePassword,
                     baseFillColor: const Color(0xFFEFEFEF),
                     focusedFillColor: _secondary.withValues(alpha: 0.12),
                     textInputAction: TextInputAction.next,
                     onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                     validator: (v) {
                       final value = (v ?? '');
                       if (value.isEmpty) return 'Password is required';
                       if (value.length < 6) return 'Minimum 6 characters';
                       return null;
                     },
                     suffixIcon: IconButton(
                       onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                       icon: Icon(
                         _obscurePassword
                             ? Icons.visibility_off_outlined
                             : Icons.visibility_outlined,
                        color: Colors.black.withValues(alpha: 0.55),
                       ),
                     ),
                   ),
                   const SizedBox(height: 14),
                   const _FieldLabel('CONFIRM'),
                   const SizedBox(height: 8),
                   FocusFillTextField(
                     controller: _confirmController,
                     focusNode: _confirmFocus,
                     hintText: 'Confirm your Password',
                     obscureText: _obscureConfirm,
                     baseFillColor: const Color(0xFFEFEFEF),
                     focusedFillColor: _secondary.withValues(alpha: 0.12),
                     textInputAction: TextInputAction.done,
                     validator: (v) {
                       final value = (v ?? '');
                       if (value.isEmpty) return 'Confirm your password';
                       if (value != _passwordController.text) return 'Passwords do not match';
                       return null;
                     },
                     suffixIcon: IconButton(
                       onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                       icon: Icon(
                         _obscureConfirm
                             ? Icons.visibility_off_outlined
                             : Icons.visibility_outlined,
                        color: Colors.black.withValues(alpha: 0.55),
                       ),
                     ),
                   ),
                   const SizedBox(height: 10),
                   InkWell(
                     onTap: () => setState(() => _agree = !_agree),
                     borderRadius: BorderRadius.circular(12),
                     child: Padding(
                       padding: const EdgeInsets.symmetric(vertical: 6),
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Checkbox(
                             value: _agree,
                             onChanged: (v) => setState(() => _agree = v ?? false),
                             activeColor: _primary,
                             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                             visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                           ),
                           const SizedBox(width: 10),
                           Expanded(
                             child: Text.rich(
                               TextSpan(
                                 text: 'I agree to the ',
                                 style: textTheme.bodySmall?.copyWith(
                                   color: Colors.black.withValues(alpha: 0.55),
                                   height: 1.25,
                                   fontWeight: FontWeight.w600,
                                 ),
                                 children: [
                                   TextSpan(
                                     text: 'Terms and Conditions',
                                     style: TextStyle(
                                       color: _secondary.withValues(alpha: 0.95),
                                       fontWeight: FontWeight.w800,
                                     ),
                                   ),
                                   const TextSpan(text: ' and the '),
                                   TextSpan(
                                     text: 'Privacy Protocol',
                                     style: TextStyle(
                                       color: _secondary.withValues(alpha: 0.95),
                                       fontWeight: FontWeight.w800,
                                     ),
                                   ),
                                   const TextSpan(text: '.'),
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 12),
                   SizedBox(
                     width: double.infinity,
                     height: 47,
                     child: Obx(() {
                       final loading = auth.isLoading.value;
                       return ElevatedButton(
                       onPressed: loading
                           ? null
                           : () {
                               final ok = _formKey.currentState?.validate() ?? false;
                               if (!ok) return;
                               if (!_agree) {
                                 Get.snackbar(
                                   'Agreement required',
                                   'Please accept Terms and Conditions and Privacy Protocol.',
                                 );
                                 return;
                               }
                               auth.signUpWithEmail(
                                 fullName: _fullNameController.text,
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
                               'SIGN UP',
                               style: TextStyle(
                                 fontWeight: FontWeight.w900,
                                 letterSpacing: 1.2,
                               ),
                             ),
                       );
                     }),
                   ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.black.withValues(alpha: 0.08),
                          height: 1,
                        ),
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
                        child: Divider(
                          color: Colors.black.withValues(alpha: 0.08),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: Obx(() {
                      final loading = auth.isLoading.value;
                      return OutlinedButton.icon(
                        onPressed: loading ? null : () => auth.signInWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black.withValues(alpha: 0.85),
                          side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded),
                        label: const Text(
                          'Google',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      );
                    }),
                  ),
                   const SizedBox(height: 12),
                   Center(
                     child: Wrap(
                       crossAxisAlignment: WrapCrossAlignment.center,
                       children: [
                         Text(
                           'Already registered? ',
                           style: textTheme.bodySmall?.copyWith(
                             color: Colors.black.withValues(alpha: 0.55),
                             fontWeight: FontWeight.w700,
                           ),
                         ),
                         TextButton(
                           onPressed: () => Get.offAllNamed(AppRoutes.login),
                           style: TextButton.styleFrom(
                             foregroundColor: _secondary,
                             padding: EdgeInsets.zero,
                             minimumSize: const Size(10, 10),
                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                           child: const Text(
                             'Sign In',
                             style: TextStyle(fontWeight: FontWeight.w900),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),

              const SizedBox(height: 18),

              // Security standard info panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _secondary.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SECURITY STANDARD',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.black.withValues(alpha: 0.55),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'AES-256',
                            style: textTheme.titleLarge?.copyWith(
                              color: _primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your clinical data\nis protected by\nhospital-grade\nencryption\nprotocols.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.black.withValues(alpha: 0.55),
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
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
