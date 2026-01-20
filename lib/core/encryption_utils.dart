/// AdvisorMate - Encryption Utilities
/// 
/// DSGVO/GDPR-konforme Verschlüsselung für sensible Kundendaten.
/// 
/// WICHTIG: Diese Utilities MÜSSEN für alle personenbezogenen Daten
/// wie Vermögenswerte, Einkommen und Steuerstatus verwendet werden.

library;

import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Verschlüsselungs-Service für sensible Daten
/// 
/// Verwendet AES-256-CBC Verschlüsselung für DSGVO-Compliance.
class EncryptionUtils {
  static const String _keyStorageKey = 'advisor_mate_encryption_key';
  static const String _ivStorageKey = 'advisor_mate_encryption_iv';
  
  final FlutterSecureStorage _secureStorage;
  
  Encrypter? _encrypter;
  IV? _iv;
  bool _isInitialized = false;

  EncryptionUtils({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initialisiert den Verschlüsselungs-Service
  /// 
  /// Muss vor der ersten Verwendung aufgerufen werden.
  Future<void> initialize() async {
    if (_isInitialized) return;

    String? storedKey = await _secureStorage.read(key: _keyStorageKey);
    String? storedIv = await _secureStorage.read(key: _ivStorageKey);

    if (storedKey == null || storedIv == null) {
      // Generiere neue Schlüssel beim ersten Start
      final key = Key.fromSecureRandom(32); // 256-bit key
      final iv = IV.fromSecureRandom(16);   // 128-bit IV
      
      await _secureStorage.write(key: _keyStorageKey, value: key.base64);
      await _secureStorage.write(key: _ivStorageKey, value: iv.base64);
      
      storedKey = key.base64;
      storedIv = iv.base64;
    }

    final key = Key.fromBase64(storedKey);
    _iv = IV.fromBase64(storedIv);
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    _isInitialized = true;
  }

  /// Verschlüsselt einen String-Wert
  /// 
  /// Beispiel:
  /// ```dart
  /// final encrypted = await encryptionUtils.encrypt('50000.00');
  /// ```
  /// 
  /// Wirft [StateError] wenn nicht initialisiert.
  String encrypt(String plainText) {
    _ensureInitialized();
    final encrypted = _encrypter!.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Entschlüsselt einen verschlüsselten String
  /// 
  /// Beispiel:
  /// ```dart
  /// final decrypted = await encryptionUtils.decrypt(encryptedValue);
  /// ```
  String decrypt(String encryptedText) {
    _ensureInitialized();
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter!.decrypt(encrypted, iv: _iv);
  }

  /// Verschlüsselt einen numerischen Wert (z.B. Vermögen, Einkommen)
  /// 
  /// // ENCRYPTED: Vermögenswerte
  String encryptDouble(double value) {
    return encrypt(value.toString());
  }

  /// Entschlüsselt einen numerischen Wert
  double decryptDouble(String encryptedValue) {
    final decrypted = decrypt(encryptedValue);
    return double.parse(decrypted);
  }

  /// Verschlüsselt ein Map-Objekt (z.B. für komplexe Finanzdaten)
  String encryptMap(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encrypt(jsonString);
  }

  /// Entschlüsselt ein Map-Objekt
  Map<String, dynamic> decryptMap(String encryptedData) {
    final jsonString = decrypt(encryptedData);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'EncryptionUtils muss vor der Verwendung initialisiert werden. '
        'Rufen Sie initialize() auf.',
      );
    }
  }

  /// Löscht alle Verschlüsselungsschlüssel (z.B. bei Logout oder Datenlöschung)
  /// 
  /// ACHTUNG: Alle verschlüsselten Daten werden dadurch unlesbar!
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
    _encrypter = null;
    _iv = null;
    _isInitialized = false;
  }
}

/// Marker-Annotation für Felder, die verschlüsselt gespeichert werden müssen
/// 
/// Verwendung:
/// ```dart
/// @SensitiveData(reason: 'Vermögenswert - DSGVO Art. 9')
/// final double totalAssets;
/// ```
class SensitiveData {
  final String reason;
  
  const SensitiveData({required this.reason});
}
