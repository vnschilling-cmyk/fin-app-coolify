/// NoScConsult - Mobile App für Finanzberater
///
/// Haupteinstiegspunkt der Anwendung.
///
/// Features:
/// - CRM & KYC Management
/// - Dashboard mit Marktdaten
/// - Finanzrechner (Zinseszins, Rentenlücke)
/// - Biometrische Authentifizierung
/// - DSGVO-konforme Datenverschlüsselung

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advisor_mate/core/encryption_utils.dart';
import 'package:advisor_mate/presentation/providers/providers.dart';
import 'package:advisor_mate/presentation/screens/dashboard_screen.dart';
import 'package:advisor_mate/presentation/widgets/biometric_auth_guard.dart';
import 'package:advisor_mate/core/constants.dart';
import 'package:advisor_mate/data/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI Konfiguration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Orientierung auf Portrait beschränken
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Verschlüsselung initialisieren
  final encryptionUtils = EncryptionUtils();
  await encryptionUtils.initialize();

  // Database initialisieren
  final pbService =
      PocketBaseDatabaseService(baseUrl: ApiConstants.pocketBaseUrl);
  await pbService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        encryptionUtilsProvider.overrideWithValue(encryptionUtils),
        databaseServiceProvider.overrideWithValue(pbService),
      ],
      child: const AdvisorMateApp(),
    ),
  );
}

/// Haupt-App Widget
class AdvisorMateApp extends ConsumerWidget {
  const AdvisorMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NoScConsult',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const BiometricAuthGuard(
        child: DashboardScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF007BFF), // NoSc Blue
        brightness: Brightness.light,
        surface: const Color(0xFFFCFCFD), // Fresher white
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Very light grey
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1C1E),
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF1F3F5), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A5F7A),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }
}
