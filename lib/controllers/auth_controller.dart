import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../routes/app_routes.dart';
import '../services/local_auth_service.dart';
import '../utils/app_snackbar.dart';

class AuthController extends GetxController {
  AuthController({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required LocalAuthService localAuth,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _localAuth = localAuth;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final LocalAuthService _localAuth;
  late final Future<void> _localReady;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final Rxn<LocalAuthUser> localUser = Rxn<LocalAuthUser>();
  final RxBool isOfflineSession = false.obs;

  @override
  void onInit() {
    super.onInit();
    _localReady = _restoreOfflineSessionIfNeeded();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((u) {
      user.value = u;
    });
  }

  Future<void> _restoreOfflineSessionIfNeeded() async {
    final sessionEmail = _localAuth.sessionEmail;
    if (sessionEmail != null && _auth.currentUser == null) {
      final u = await _localAuth.getUserByEmail(sessionEmail);
      if (u != null) {
        localUser.value = u;
        isOfflineSession.value = true;
      } else {
        await _localAuth.clearSession();
      }
    }
  }

  bool get isLoggedIn => _auth.currentUser != null || isOfflineSession.value;

  static bool isValidEmail(String value) {
    final v = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 7));
      isOfflineSession.value = false;
      localUser.value = null;
      Get.offAllNamed(AppRoutes.assessment);
    } on FirebaseAuthException catch (e) {
      // Offline fallback on network failures.
      if (_shouldTryOffline(e)) {
        await _localReady;
        try {
          final u = await _localAuth.signInOffline(email: email, password: password);
          localUser.value = u;
          isOfflineSession.value = true;
          Get.offAllNamed(AppRoutes.assessment);
          Get.snackbar('Offline login', 'You are logged in using local data.');
          return;
        } on LocalAuthException catch (le) {
          Get.snackbar('Offline login failed', _localMessage(le));
          return;
        } catch (_) {
          Get.snackbar('Offline login failed', 'Local account data is invalid. Please sign in online.');
          return;
        }
      }
      Get.snackbar('Login failed', _firebaseMessage(e));
    } on TimeoutException {
      await _localReady;
      try {
        final u = await _localAuth.signInOffline(email: email, password: password);
        localUser.value = u;
        isOfflineSession.value = true;
        Get.offAllNamed(AppRoutes.assessment);
        Get.snackbar('Offline login', 'No internet. Logged in using local data.');
      } on LocalAuthException catch (le) {
        Get.snackbar('Offline login failed', _localMessage(le));
      } catch (_) {
        Get.snackbar('Offline login failed', 'Local account data is invalid. Please sign in online.');
      }
    } catch (e) {
      // Some platforms throw non-FirebaseAuthException errors when offline.
      if (_shouldTryOffline(e)) {
        await _localReady;
        try {
          final u = await _localAuth.signInOffline(email: email, password: password);
          localUser.value = u;
          isOfflineSession.value = true;
          Get.offAllNamed(AppRoutes.assessment);
          Get.snackbar('Offline login', 'You are logged in using local data.');
          return;
        } on LocalAuthException catch (le) {
          Get.snackbar('Offline login failed', _localMessage(le));
          return;
        } catch (_) {
          Get.snackbar('Offline login failed', 'Local account data is invalid. Please sign in online.');
          return;
        }
      }
      Get.snackbar('Login failed', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 7));
      await cred.user?.updateDisplayName(fullName.trim());
      await cred.user?.reload();
      user.value = _auth.currentUser;
      // Persist for offline sign-in later (we have the password only here).
      await _localReady;
      await _localAuth.persistFromOnlineSignup(
        fullName: fullName,
        email: email,
        password: password,
      );
      // Firebase signs the user in automatically after sign-up.
      // Per UX: take them back to Login to sign in explicitly.
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('Account created', 'Please sign in to continue.');
    } on FirebaseAuthException catch (e) {
      if (_shouldTryOffline(e)) {
        await _localReady;
        try {
          await _localAuth.signUpOffline(
            fullName: fullName,
            email: email,
            password: password,
          );
          Get.offAllNamed(AppRoutes.login);
          Get.snackbar('Offline sign up', 'Account created locally. Sign in to continue.');
          return;
        } on LocalAuthException catch (le) {
          Get.snackbar('Offline sign up failed', _localMessage(le));
          return;
        }
      }
      Get.snackbar('Sign up failed', _firebaseMessage(e));
    } on TimeoutException {
      await _localReady;
      try {
        await _localAuth.signUpOffline(
          fullName: fullName,
          email: email,
          password: password,
        );
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar('Offline sign up', 'No internet. Account created locally.');
      } on LocalAuthException catch (le) {
        Get.snackbar('Offline sign up failed', _localMessage(le));
      }
    } catch (e) {
      if (_shouldTryOffline(e)) {
        await _localReady;
        try {
          await _localAuth.signUpOffline(
            fullName: fullName,
            email: email,
            password: password,
          );
          Get.offAllNamed(AppRoutes.login);
          Get.snackbar('Offline sign up', 'Account created locally. Sign in to continue.');
          return;
        } on LocalAuthException catch (le) {
          Get.snackbar('Offline sign up failed', _localMessage(le));
          return;
        }
      }
      Get.snackbar('Sign up failed', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      // Google sign-in requires network and can't be done offline.
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled.
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      user.value = _auth.currentUser;
      isOfflineSession.value = false;
      localUser.value = null;

      Get.offAllNamed(AppRoutes.assessment);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Google sign-in failed', _firebaseMessage(e));
    } catch (e) {
      Get.snackbar('Google sign-in failed', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    final e = email.trim();
    if (!isValidEmail(e)) {
      AppSnackbar.show('Invalid email', 'Please enter a valid email address.');
      return false;
    }

    if (isLoading.value) {
      AppSnackbar.show(
        'Please wait',
        'Another request is in progress. Try again in a moment.',
      );
      return false;
    }
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: e).timeout(const Duration(seconds: 7));
      AppSnackbar.show(
        'Email sent',
        'Password reset link has been sent to your email.',
        isError: false,
      );
      return true;
    } on FirebaseAuthException catch (ex) {
      // Common: user-not-found (don’t leak too much info; keep UX simple).
      final msg = ex.code == 'user-not-found'
          ? 'If an account exists for that email, you’ll receive a reset link.'
          : _firebaseMessage(ex);
      AppSnackbar.show('Password reset', msg);
      return false;
    } on TimeoutException {
      AppSnackbar.show('Password reset', 'Network timeout. Please try again.');
      return false;
    } catch (ex) {
      if (_shouldTryOffline(ex)) {
        AppSnackbar.show(
          'Password reset',
          'No internet connection. Please try again online.',
        );
      } else {
        AppSnackbar.show('Password reset', 'Please try again.');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _auth.signOut();
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // ignore
      }
      try {
        await _localReady;
        await _localAuth.clearSession();
      } catch (_) {
        // If local storage isn't ready, still allow logout/navigation.
      }
      isOfflineSession.value = false;
      localUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  static bool _shouldTryOffline(Object e) {
    if (e is FirebaseAuthException) {
      return e.code == 'network-request-failed' ||
          (e.message?.toLowerCase().contains('network') ?? false);
    }
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('timeout') ||
        msg.contains('unavailable') ||
        msg.contains('connection') ||
        msg.contains('socketexception');
  }

  static String _localMessage(LocalAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No offline account found for this email.';
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered offline.';
      case 'corrupt-local-user':
        return 'Local account data is invalid. Please sign in online once.';
      default:
        return 'Offline auth failed. Please try again.';
    }
  }

  static String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}

