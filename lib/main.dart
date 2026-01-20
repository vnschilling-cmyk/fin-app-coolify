/// AdvisorMate - Mobile App für Finanzberater
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
  final pbService = PocketBaseDatabaseService(baseUrl: ApiConstants.pocketBaseUrl);
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
      title: 'AdvisorMate',
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
        seedColor: const Color(0xFF1A5F7A), // Fintech Blue
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
      cardTheme: CardTheme(
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
