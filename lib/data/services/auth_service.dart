/// AdvisorMate - Authentication Service
/// 
/// Biometrische Authentifizierung mit FaceID/TouchID.
/// Erforderlich für DSGVO-konforme Sicherheit bei Finanzdaten.

library;

import 'package:local_auth/local_auth.dart';
import 'package:advisor_mate/core/errors.dart';

/// Service für biometrische Authentifizierung
/// 
/// Verwendet das `local_auth` Package für:
/// - Face ID (iOS)
/// - Touch ID (iOS)
/// - Fingerabdruck (Android)
/// - Iris-Scan (Android)
class AuthService {
  final LocalAuthentication _localAuth;
  
  AuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  /// Prüft ob biometrische Authentifizierung verfügbar ist
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Gibt die verfügbaren biometrischen Methoden zurück
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Führt biometrische Authentifizierung durch
  /// 
  /// [reason]: Wird dem Benutzer als Grund für die Authentifizierung angezeigt
  /// 
  /// Wirft [AuthException] bei Fehlern.
  Future<bool> authenticateWithBiometrics({
    String reason = 'Bitte authentifizieren Sie sich für den Zugriff auf Ihre Finanzdaten',
  }) async {
    // Prüfe Verfügbarkeit
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      throw AuthException.biometricNotAvailable();
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (!authenticated) {
        throw AuthException.biometricFailed();
      }

      return authenticated;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Authentifizierung fehlgeschlagen: ${e.toString()}',
        code: 'AUTH_ERROR',
        originalError: e,
      );
    }
  }

  /// Authentifiziert mit Biometrie oder Fallback auf PIN/Passwort
  Future<bool> authenticateWithFallback({
    String reason = 'Bitte authentifizieren Sie sich',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Erlaubt PIN/Passwort als Fallback
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      throw AuthException(
        message: 'Authentifizierung fehlgeschlagen: ${e.toString()}',
        code: 'AUTH_ERROR',
        originalError: e,
      );
    }
  }

  /// Stoppt laufende Authentifizierung
  Future<void> cancelAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}

/// Wrapper für authentifizierte Operationen
/// 
/// Stellt sicher, dass sensible Operationen nur nach
/// erfolgreicher Authentifizierung ausgeführt werden.
class SecureOperation<T> {
  final AuthService _authService;
  final Future<T> Function() _operation;
  final String _reason;

  SecureOperation({
    required AuthService authService,
    required Future<T> Function() operation,
    String reason = 'Authentifizierung für sensible Operation erforderlich',
  })  : _authService = authService,
        _operation = operation,
        _reason = reason;

  /// Führt die Operation nach erfolgreicher Authentifizierung aus
  Future<T> execute() async {
    final authenticated = await _authService.authenticateWithBiometrics(
      reason: _reason,
    );

    if (!authenticated) {
      throw AuthException.biometricFailed();
    }

    return await _operation();
  }
}
