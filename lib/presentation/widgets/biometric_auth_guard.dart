/// AdvisorMate - Biometric Authentication Guard
///
/// Wrapper-Widget das biometrische Authentifizierung erfordert
/// bevor der Inhalt angezeigt wird.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advisor_mate/core/errors.dart';
import 'package:advisor_mate/core/constants.dart';
import 'package:advisor_mate/presentation/providers/providers.dart';

/// Guard-Widget für biometrische Authentifizierung
///
/// Zeigt einen Authentifizierungs-Screen an, bis der Benutzer
/// sich erfolgreich per FaceID/TouchID authentifiziert hat.
class BiometricAuthGuard extends ConsumerStatefulWidget {
  final Widget child;

  const BiometricAuthGuard({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<BiometricAuthGuard> createState() => _BiometricAuthGuardState();
}

class _BiometricAuthGuardState extends ConsumerState<BiometricAuthGuard>
    with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Starte Authentifizierung nach dem ersten Frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FeatureFlags.biometricAuthEnabled) {
        _authenticate();
      } else {
        setState(() => _isAuthenticated = true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-authentifizieren wenn App aus dem Hintergrund kommt
    if (state == AppLifecycleState.resumed &&
        _isAuthenticated &&
        FeatureFlags.biometricAuthEnabled) {
      // Optional: Re-auth nach bestimmter Zeit im Hintergrund
      // Für höhere Sicherheit hier _authenticate() aufrufen
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.authenticateWithBiometrics(
        reason:
            'Bitte authentifizieren Sie sich für den Zugriff auf AdvisorMate',
      );

      if (success) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
        ref.read(isAuthenticatedProvider.notifier).state = true;
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isAuthenticating = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentifizierung fehlgeschlagen';
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Sicherer Zugang für Finanzberater',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),

                if (_isAuthenticating) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Authentifizierung läuft...'),
                ] else ...[
                  // Biometric Icon
                  Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  ElevatedButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Mit Biometrie anmelden'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () async {
                      // Fallback: PIN/Passwort
                      try {
                        final authService = ref.read(authServiceProvider);
                        final success =
                            await authService.authenticateWithFallback(
                          reason: 'Bitte geben Sie Ihren Geräte-PIN ein',
                        );
                        if (success) {
                          setState(() => _isAuthenticated = true);
                          ref.read(isAuthenticatedProvider.notifier).state =
                              true;
                        }
                      } catch (e) {
                        setState(() {
                          _errorMessage = 'Authentifizierung fehlgeschlagen';
                        });
                      }
                    },
                    child: const Text('Alternative Anmeldung'),
                  ),
                ],

                const SizedBox(height: 48),

                // Security Hinweis
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ihre Daten werden DSGVO-konform verschlüsselt gespeichert.',
                          style: TextStyle(fontSize: 12),
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
}
