import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:gems_data_layer/gems_data_layer.dart' show DatabaseService;

class LocalAuthUser {
  final String email;
  final String fullName;
  final String passwordSalt; // base64
  final String passwordHash; // hex of sha256(salt + password)

  const LocalAuthUser({
    required this.email,
    required this.fullName,
    required this.passwordSalt,
    required this.passwordHash,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'passwordSalt': passwordSalt,
        'passwordHash': passwordHash,
      };

  static LocalAuthUser fromJson(Map<dynamic, dynamic> json) => LocalAuthUser(
        email: (json['email'] as String?) ?? '',
        fullName: (json['fullName'] as String?) ?? '',
        passwordSalt: (json['passwordSalt'] as String?) ?? '',
        passwordHash: (json['passwordHash'] as String?) ?? '',
      );
}

class LocalAuthService {
  static const _boxName = 'robodoc_auth';
  static const _usersKeyPrefix = 'user:';
  static const _sessionEmailKey = 'session_email';

  final DatabaseService _db;
  LocalAuthService(this._db);

  Future<void> initialize() async {
    await _db.openBox(_boxName);
  }

  String? get sessionEmail => _db.get<String>(_sessionEmailKey, boxName: _boxName);

  Future<void> clearSession() => _db.delete(_sessionEmailKey, boxName: _boxName);

  Future<LocalAuthUser?> getUserByEmail(String email) async {
    final key = '$_usersKeyPrefix${email.trim().toLowerCase()}';
    final raw = _db.get<Map<dynamic, dynamic>>(key, boxName: _boxName);
    if (raw == null) return null;
    return LocalAuthUser.fromJson(raw);
  }

  Future<bool> userExists(String email) async {
    final key = '$_usersKeyPrefix${email.trim().toLowerCase()}';
    return _db.containsKey(key, boxName: _boxName);
  }

  Future<void> signUpOffline({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    if (await userExists(e)) {
      throw const LocalAuthException('email-already-in-use');
    }
    final salt = _generateSalt();
    final hash = _hashPassword(salt, password);
    final user = LocalAuthUser(
      email: e,
      fullName: fullName.trim(),
      passwordSalt: base64Encode(salt),
      passwordHash: hash,
    );
    final key = '$_usersKeyPrefix$e';
    await _db.save<Map<String, dynamic>>(key, user.toJson(), boxName: _boxName);
  }

  Future<LocalAuthUser> signInOffline({
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    final user = await getUserByEmail(e);
    if (user == null) {
      throw const LocalAuthException('user-not-found');
    }
    final saltBytes = base64Decode(user.passwordSalt);
    final computed = _hashPassword(saltBytes, password);
    if (computed != user.passwordHash) {
      throw const LocalAuthException('wrong-password');
    }
    await _db.save<String>(_sessionEmailKey, e, boxName: _boxName);
    return user;
  }

  Future<void> persistFromOnlineSignup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    final salt = _generateSalt();
    final hash = _hashPassword(salt, password);
    final user = LocalAuthUser(
      email: e,
      fullName: fullName.trim(),
      passwordSalt: base64Encode(salt),
      passwordHash: hash,
    );
    final key = '$_usersKeyPrefix$e';
    await _db.save<Map<String, dynamic>>(key, user.toJson(), boxName: _boxName);
  }

  static List<int> _generateSalt() {
    final rand = Random.secure();
    return List<int>.generate(16, (_) => rand.nextInt(256));
  }

  static String _hashPassword(List<int> saltBytes, String password) {
    final bytes = <int>[...saltBytes, ...utf8.encode(password)];
    return sha256.convert(bytes).toString();
  }
}

class LocalAuthException implements Exception {
  final String code;
  const LocalAuthException(this.code);
}

