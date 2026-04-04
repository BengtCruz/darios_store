import 'dart:io';

import 'package:backend/repositories/user_repository.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dbcrypt/dbcrypt.dart';

class AuthService {

  AuthService(
    this._userRepo, {
    String? jwtSecret,
    Duration? tokenExpiry,
  })  : _jwtSecret =
            jwtSecret ?? Platform.environment['JWT_SECRET'] ?? 'darios-store-secret-change-in-production',
        _tokenExpiry = tokenExpiry ?? const Duration(hours: 24);
  final UserRepository _userRepo;
  final String _jwtSecret;
  final Duration _tokenExpiry;

  static final _bcrypt = DBCrypt();

  String hashPassword(String password) {
    return _bcrypt.hashpw(password, _bcrypt.gensalt());
  }

  bool verifyPassword(String password, String hash) {
    return _bcrypt.checkpw(password, hash);
  }

  String generateToken(Map<String, dynamic> user) {
    final jwt = JWT(
      {
        'sub': user['id'],
        'email': user['email'],
        'role': user['role'],
      },
      issuer: 'darios-store',
    );
    return jwt.sign(
      SecretKey(_jwtSecret),
      expiresIn: _tokenExpiry,
    );
  }

  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final existing = await _userRepo.findByEmail(email);
    if (existing != null) return null;

    final hash = hashPassword(password);
    final user = await _userRepo.create(
      email: email,
      name: name,
      passwordHash: hash,
    );
    return user;
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final user = await _userRepo.findByEmail(email);
    if (user == null) return null;

    if (user['isActive'] != true) return null;

    if (!verifyPassword(password, user['passwordHash'] as String)) return null;

    return user;
  }
}
