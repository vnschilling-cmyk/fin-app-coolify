/// AdvisorMate - Custom Error Handling
/// 
/// Definiert app-spezifische Exceptions für bessere Fehlerbehandlung.

library;

/// Basis-Exception für alle App-Fehler
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Authentifizierungsfehler
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Biometrische Authentifizierung fehlgeschlagen
  factory AuthException.biometricFailed() => const AuthException(
        message: 'Biometrische Authentifizierung fehlgeschlagen',
        code: 'BIOMETRIC_FAILED',
      );

  /// Biometrie nicht verfügbar auf diesem Gerät
  factory AuthException.biometricNotAvailable() => const AuthException(
        message: 'Biometrische Authentifizierung nicht verfügbar',
        code: 'BIOMETRIC_NOT_AVAILABLE',
      );

  /// Session abgelaufen
  factory AuthException.sessionExpired() => const AuthException(
        message: 'Sitzung abgelaufen. Bitte erneut anmelden.',
        code: 'SESSION_EXPIRED',
      );
}

/// Datenzugriffsfehler
class DataException extends AppException {
  const DataException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Kunde nicht gefunden
  factory DataException.clientNotFound(String clientId) => DataException(
        message: 'Kunde mit ID $clientId nicht gefunden',
        code: 'CLIENT_NOT_FOUND',
      );

  /// Netzwerkfehler
  factory DataException.networkError() => const DataException(
        message: 'Keine Netzwerkverbindung',
        code: 'NETWORK_ERROR',
      );

  /// Datenbankfehler
  factory DataException.databaseError([String? details]) => DataException(
        message: 'Datenbankfehler${details != null ? ': $details' : ''}',
        code: 'DATABASE_ERROR',
      );
}

/// Verschlüsselungsfehler (DSGVO-relevant)
class EncryptionException extends AppException {
  const EncryptionException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Verschlüsselung fehlgeschlagen
  factory EncryptionException.encryptionFailed() => const EncryptionException(
        message: 'Sensible Daten konnten nicht verschlüsselt werden',
        code: 'ENCRYPTION_FAILED',
      );

  /// Entschlüsselung fehlgeschlagen
  factory EncryptionException.decryptionFailed() => const EncryptionException(
        message: 'Daten konnten nicht entschlüsselt werden',
        code: 'DECRYPTION_FAILED',
      );
}

/// Validierungsfehler
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  /// Risikoprofil außerhalb des gültigen Bereichs
  factory ValidationException.invalidRiskProfile(int value) =>
      ValidationException(
        message: 'Risikoprofil muss zwischen 1 und 10 liegen (eingegeben: $value)',
        code: 'INVALID_RISK_PROFILE',
      );
}
