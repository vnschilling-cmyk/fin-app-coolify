/// AdvisorMate - App-weite Konstanten
/// 
/// Zentrale Konfiguration für API-Endpunkte, Feature-Flags und App-Einstellungen.

library;

/// API Konfiguration
class ApiConstants {
  ApiConstants._();
  
  /// PocketBase Backend URL - deines Coolify-PocketBase Dienstes.
  static const String pocketBaseUrl = 'https://pocketbase-fin-app-coolify.195.201.231.49.nip.io';
  
  /// Yahoo Finance API Platzhalter
  static const String marketDataApiUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';
  
  /// API Timeout in Sekunden
  static const int apiTimeout = 30;
}

/// Feature Flags
class FeatureFlags {
  FeatureFlags._();
  
  /// Biometrische Authentifizierung aktivieren
  static const bool biometricAuthEnabled = true;
  
  /// Dokumenten-Scan Feature aktivieren
  static const bool documentScanEnabled = true;
  
  /// ESG-Präferenzen anzeigen
  static const bool showEsgPreferences = true;
}

/// App Konfiguration
class AppConfig {
  AppConfig._();
  
  /// App Name
  static const String appName = 'AdvisorMate';
  
  /// Maximaler Risikoprofil-Score
  static const int maxRiskScore = 10;
  
  /// Minimaler Risikoprofil-Score
  static const int minRiskScore = 1;
  
  /// Standard Inflationsrate für Berechnungen (in %)
  static const double defaultInflationRate = 2.0;
}
