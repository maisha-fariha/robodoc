import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/assessment_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_snackbar.dart';
import '../widgets/robodoc_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _secondary = Color(0xFF21CDC0);
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;
  bool _didAttemptRemoteLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAttemptRemoteLoad) return;
    _didAttemptRemoteLoad = true;
    _loadRemoteProfileImage();
  }

  Reference _profileImageRef(String uid) =>
      FirebaseStorage.instance.ref().child('users/$uid/profile/avatar.jpg');

  Future<void> _loadRemoteProfileImage() async {
    final auth = Get.find<AuthController>();
    final assessment = Get.find<AssessmentController>();
    final uid = auth.user.value?.uid;
    if (uid == null) return;
    final existing = assessment.profileImagePath.value ?? '';
    if (existing.startsWith('http://') || existing.startsWith('https://')) return;

    try {
      final url = await _profileImageRef(uid).getDownloadURL();
      assessment.setProfileImagePath(url);
    } on FirebaseException catch (e) {
      // Silent on profile-open background fetch to avoid noisy UX.
      if (e.code == 'object-not-found') return;
    } catch (_) {
      // Silent: profile image may not exist yet or storage may be unavailable.
    }
  }

  Future<void> _uploadProfileImage(XFile file) async {
    final auth = Get.find<AuthController>();
    final assessment = Get.find<AssessmentController>();
    final uid = auth.user.value?.uid;
    if (uid == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final ref = _profileImageRef(uid);
      await ref.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await ref.getDownloadURL();
      assessment.setProfileImagePath(url);
      AppSnackbar.show('Profile image', 'Profile image updated.', isError: false);
    } on FirebaseException catch (e) {
      final code = e.code.toLowerCase();
      final message = (e.message ?? '').toLowerCase();
      final notSetup = code == 'object-not-found' &&
          (message.contains('no object exists') ||
              message.contains('does not exist') ||
              message.contains('desired reference'));
      AppSnackbar.show(
        'Upload failed',
        notSetup
            ? 'Firebase Storage is not ready for this project yet. '
                'Open Firebase Console > Storage > Get Started, then try again.'
            : (e.message?.isNotEmpty == true
                ? e.message!
                : 'Could not upload profile image.'),
      );
    } catch (_) {
      AppSnackbar.show('Upload failed', 'Could not upload profile image.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = Get.find<AuthController>();
    final assessment = Get.find<AssessmentController>();

    String currentDisplayName() {
      if (auth.user.value?.displayName?.trim().isNotEmpty == true) {
        return auth.user.value!.displayName!.trim();
      }
      if (auth.localUser.value?.fullName.trim().isNotEmpty == true) {
        return auth.localUser.value!.fullName.trim();
      }
      return 'User';
    }

    String currentEmail() {
      if (auth.user.value?.email?.trim().isNotEmpty == true) {
        return auth.user.value!.email!.trim();
      }
      if (auth.localUser.value?.email.trim().isNotEmpty == true) {
        return auth.localUser.value!.email.trim();
      }
      return '—';
    }

    final isVerified = auth.user.value?.emailVerified == true;

    Future<void> pickProfileImage(ImageSource source) async {
      try {
        // Give the bottom sheet time to close to avoid activity launch race conditions on some devices.
        await Future.delayed(const Duration(milliseconds: 150));
        final file = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 1024,
        );
        if (file == null) return;
        assessment.setProfileImagePath(file.path);
        if (auth.user.value != null) {
          await _uploadProfileImage(file);
        } else {
          AppSnackbar.show(
            'Saved locally',
            'Sign in online to sync profile image to your account.',
            isError: false,
          );
        }
      } on PlatformException catch (e) {
        AppSnackbar.show(
          'Image selection failed',
          e.code == 'camera_access_denied'
              ? 'Camera permission denied. Please allow camera access.'
              : e.code == 'photo_access_denied'
                  ? 'Photo permission denied. Please allow photo access.'
                  : (e.message?.isNotEmpty == true ? e.message! : 'Please try again.'),
        );
      } catch (e) {
        AppSnackbar.show('Image selection failed', 'Please try again.');
      }
    }

    void openImagePickerSheet() {
      Get.bottomSheet(
        SafeArea(
          top: false,
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Choose from gallery'),
                    onTap: () async {
                      Get.back();
                      await pickProfileImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('Take a photo'),
                    onTap: () async {
                      Get.back();
                      await pickProfileImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Future<void> openHealthProfileEditor() async {
      final saved = await Get.bottomSheet<bool>(
        _HealthProfileEditorSheet(
          initialAge: assessment.age.value,
          initialGender: assessment.sexAtBirth.value,
          initialBlood: assessment.bloodType.value,
          onSave: (age, gender, blood) {
            assessment.setFromAssessment(
              age: age,
              sexAtBirth: gender,
              bloodType: blood,
            );
          },
        ),
        isScrollControlled: true,
      );

      if (saved == true) {
        AppSnackbar.show('Saved', 'Health profile updated.', isError: false);
      }
    }

    void openHelpCenter() {
      Get.bottomSheet(
        SafeArea(
          top: false,
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help Center',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...const [
                    (
                      'How does RoboDoc assessment work?',
                      'Complete steps 1-4, then AI generates tailored follow-up questions for steps 5-7.',
                    ),
                    (
                      'Are results a medical diagnosis?',
                      'No. RoboDoc provides informational triage support only. Please consult a licensed clinician for diagnosis.',
                    ),
                    (
                      'How can I view old assessments?',
                      'Go to the History tab to open previous result summaries.',
                    ),
                  ].map(
                    (item) => ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 10),
                      title: Text(
                        item.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.$2,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.65),
                              height: 1.3,
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

    void openContactSupport() {
      const supportEmail = 'info@encoderit.com';
      Get.bottomSheet(
        SafeArea(
          top: false,
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'For support or account help, contact our team.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outline_rounded),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            supportEmail,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              const ClipboardData(text: supportEmail),
                            );
                            AppSnackbar.show(
                              'Copied',
                              'Support email copied: $supportEmail',
                              isError: false,
                            );
                          },
                          child: const Text('Copy'),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: auth.isLoading.value
                  ? null
                  : () async {
                      await auth.signOut();
                    },
              icon: auth.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
              tooltip: 'Log out',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const RoboDocBottomNav(selected: RoboDocTab.profile),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Obx(() {
                      final path = assessment.profileImagePath.value;
                      if (path != null && path.isNotEmpty) {
                        final isRemote =
                            path.startsWith('http://') || path.startsWith('https://');
                        if (isRemote) {
                          return Image.network(
                            path,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stackTrace) => Container(
                              width: 96,
                              height: 96,
                              color: Colors.black.withValues(alpha: 0.08),
                              child: const Icon(Icons.person_rounded, size: 56),
                            ),
                          );
                        }
                        return Image.file(
                          File(path),
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stackTrace) => Container(
                            width: 96,
                            height: 96,
                            color: Colors.black.withValues(alpha: 0.08),
                            child: const Icon(Icons.person_rounded, size: 56),
                          ),
                        );
                      }
                      return Container(
                        width: 96,
                        height: 96,
                        color: Colors.black.withValues(alpha: 0.08),
                        child: const Icon(Icons.person_rounded, size: 56),
                      );
                    }),
                  ),
                  if (_isUploadingImage)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3B36),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isUploadingImage ? null : openImagePickerSheet,
                          borderRadius: BorderRadius.circular(10),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(
                () => Text(
                  currentDisplayName(),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  currentEmail(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _Pill(
                    text: 'PREMIUM MEMBER',
                    bg: _secondary.withValues(alpha: 0.25),
                    fg: Colors.black.withValues(alpha: 0.7),
                  ),
                  _Pill(
                    text: isVerified ? 'VERIFIED' : 'UNVERIFIED',
                    bg: Colors.black.withValues(alpha: 0.06),
                    fg: Colors.black.withValues(alpha: 0.6),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'HEALTH PROFILE',
                actionText: 'Edit',
                onAction: openHealthProfileEditor,
              ),
              const SizedBox(height: 12),
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.badge_rounded,
                        value: assessment.ageDisplay,
                        label: 'AGE',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.transgender_rounded,
                        value: assessment.genderDisplay,
                        label: 'GENDER',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.bloodtype_rounded,
                        value: assessment.bloodDisplay,
                        label: 'BLOOD',
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 18),
              _SectionLabel(title: 'APP SETTINGS'),
              const SizedBox(height: 10),
              _ListTileCard(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () => AppSnackbar.show(
                  'Coming soon',
                  'Notifications settings will be available in a future update.',
                  isError: false,
                ),
              ),
              const SizedBox(height: 10),
              _ListTileCard(
                icon: Icons.shield_outlined,
                title: 'Security',
                onTap: () => AppSnackbar.show(
                  'Coming soon',
                  'Security settings will be available in a future update.',
                  isError: false,
                ),
              ),
              const SizedBox(height: 10),
              _ListTileCard(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy',
                onTap: () => AppSnackbar.show(
                  'Coming soon',
                  'Privacy settings will be available in a future update.',
                  isError: false,
                ),
              ),
              const SizedBox(height: 18),
              _SectionLabel(title: 'SUPPORT'),
              const SizedBox(height: 10),
              _SupportCard(
                icon: Icons.help_outline_rounded,
                title: 'Help Center',
                subtitle: 'FAQs & Guides',
                onTap: openHelpCenter,
              ),
              const SizedBox(height: 12),
              _SupportCard(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Us',
                subtitle: '24/7 Support',
                onTap: openContactSupport,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () async {
                    await auth.signOut();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.03),
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LOG OUT',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'ROBO DOC AI v1.0.0',
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(
            color: Colors.black.withValues(alpha: 0.45),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onAction,
          child: Text(
            actionText,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.55),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: Colors.black.withValues(alpha: 0.45),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.black.withValues(alpha: 0.75), size: 20),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: textTheme.labelSmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.45),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ListTileCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.black.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black.withValues(alpha: 0.7)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.black.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3B36),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.black.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _HealthProfileEditorSheet extends StatefulWidget {
  final int initialAge;
  final String? initialGender; // 'male' | 'female' | 'self'
  final String? initialBlood;
  final void Function(int age, String? gender, String? blood) onSave;

  const _HealthProfileEditorSheet({
    required this.initialAge,
    required this.initialGender,
    required this.initialBlood,
    required this.onSave,
  });

  @override
  State<_HealthProfileEditorSheet> createState() => _HealthProfileEditorSheetState();
}

class _HealthProfileEditorSheetState extends State<_HealthProfileEditorSheet> {
  static const _primary = Color(0xFF0E204D);

  late final TextEditingController _ageCtrl;
  late final TextEditingController _bloodCtrl;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _ageCtrl =
        TextEditingController(text: widget.initialAge > 0 ? '${widget.initialAge}' : '');
    _bloodCtrl = TextEditingController(text: widget.initialBlood ?? '');
    _gender = widget.initialGender;
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _bloodCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    Widget sectionLabel(String text) {
      return Text(
        text,
        style: textTheme.labelLarge?.copyWith(
          color: Colors.black.withValues(alpha: 0.45),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      );
    }

    InputDecoration fieldDecoration({required String hint}) {
      return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
    }

    Widget genderChoice(String label, String value) {
      final selected = _gender == value;
      return Expanded(
        child: SizedBox(
          height: 44,
          child: TextButton(
            onPressed: () => setState(() => _gender = value),
            style: TextButton.styleFrom(
              backgroundColor:
                  selected ? _primary : Colors.black.withValues(alpha: 0.03),
              foregroundColor: selected
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      );
    }

    void save() {
      final parsedAge = int.tryParse(_ageCtrl.text.trim());
      if (parsedAge == null || parsedAge <= 0 || parsedAge > 120) {
        AppSnackbar.show('Invalid age', 'Please enter a valid age.');
        return;
      }

      final blood = _bloodCtrl.text.trim();
      widget.onSave(parsedAge, _gender, blood.isEmpty ? null : blood);
      Get.back(result: true);
    }

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + bottomInset),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Edit Health Profile',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withValues(alpha: 0.9),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(result: false),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                sectionLabel('AGE'),
                const SizedBox(height: 6),
                TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: fieldDecoration(hint: 'Enter age'),
                ),
                const SizedBox(height: 12),
                sectionLabel('GENDER'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    genderChoice('Male', 'male'),
                    const SizedBox(width: 10),
                    genderChoice('Female', 'female'),
                    const SizedBox(width: 10),
                    genderChoice('Other', 'self'),
                  ],
                ),
                const SizedBox(height: 12),
                sectionLabel('BLOOD'),
                const SizedBox(height: 6),
                TextField(
                  controller: _bloodCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: fieldDecoration(hint: 'e.g. O+'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
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

