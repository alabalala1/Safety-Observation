import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'user_role.dart';

/// Phase-one offline role codes. This shared key is intentionally a role gate,
/// not a secure identity credential; move issuance to a signing-key design later.
class RoleCode {
  static const _key = 'safety-observation-role-codes-phase-one-2026';
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static UserRole? decode(String value) {
    final normalized = value.trim().toUpperCase().replaceAll(' ', '');
    final match = RegExp(r'^SO1-(EMP|SUP)-([A-Z2-9]{10})-([A-F0-9]{8})$')
        .firstMatch(normalized);
    if (match == null) return null;
    final prefix = 'SO1-${match.group(1)}-${match.group(2)}';
    final expected = _digest(prefix).substring(0, 8).toUpperCase();
    if (expected != match.group(3)) return null;
    return match.group(1) == 'SUP' ? UserRole.supervisor : UserRole.employee;
  }

  static String generate(UserRole role, {Random? random}) {
    final source = random ?? Random.secure();
    final code = List.generate(_alphabet.length, (i) => _alphabet[i]);
    final token =
        List.generate(10, (_) => code[source.nextInt(code.length)]).join();
    final prefix = 'SO1-${role == UserRole.supervisor ? 'SUP' : 'EMP'}-$token';
    return '$prefix-${_digest(prefix).substring(0, 8).toUpperCase()}';
  }

  static String _digest(String input) =>
      Hmac(sha256, utf8.encode(_key)).convert(utf8.encode(input)).toString();
}
