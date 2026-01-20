/// AdvisorMate - Document Scan Widget
///
/// UI-Button für Dokumenten-Scan mit Kamera-Integration.
/// Nutzt camerawesome als Platzhalter für die Implementierung.

library;

import 'package:flutter/material.dart';

/// Widget für Dokumenten-Scan Funktion
///
/// Öffnet die Kamera zum Scannen von Dokumenten und generiert ein PDF.
///
/// HINWEIS: Dies ist ein Platzhalter. Für die vollständige Implementierung:
/// 1. Füge `camerawesome` oder `edge_detection` zu pubspec.yaml hinzu
/// 2. Implementiere die Kamera-Capture-Logik
/// 3. Nutze ein PDF-Package wie `pdf` oder `syncfusion_flutter_pdf`
class DocumentScanWidget extends StatelessWidget {
  /// Callback wenn Scan abgeschlossen
  final void Function(String documentPath)? onScanComplete;

  /// Callback bei Fehler
  final void Function(String error)? onError;

  const DocumentScanWidget({
    super.key,
    this.onScanComplete,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _startDocumentScan(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.document_scanner,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dokument scannen',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDocumentScan(BuildContext context) {
    // TODO: Implementierung mit camerawesome oder edge_detection
    //
    // Beispiel-Implementierung:
    // ```dart
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => CameraAwesomeBuilder.awesome(
    //       saveConfig: SaveConfig.photoAndVideo(),
    //       onMediaTap: (mediaCapture) {
    //         // Process captured image
    //         _processDocument(mediaCapture.filePath);
    //       },
    //     ),
    //   ),
    // );
    // ```

    showModalBottomSheet(
      context: context,
      builder: (context) => _DocumentScanBottomSheet(
        onScanComplete: onScanComplete,
        onError: onError,
      ),
    );
  }
}

class _DocumentScanBottomSheet extends StatelessWidget {
  final void Function(String documentPath)? onScanComplete;
  final void Function(String error)? onError;

  const _DocumentScanBottomSheet({
    this.onScanComplete,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.document_scanner,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Dokument scannen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Diese Funktion wird bald verfügbar sein.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Für die Implementierung wird das camerawesome Package verwendet.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Schließen'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Simuliere einen erfolgreichen Scan
                    Navigator.pop(context);
                    onScanComplete?.call(
                        '/documents/scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Demo Scan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Standalone Button-Version des Document Scan Widgets
class DocumentScanButton extends StatelessWidget {
  final void Function(String documentPath)? onScanComplete;
  final void Function(String error)? onError;

  const DocumentScanButton({
    super.key,
    this.onScanComplete,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _DocumentScanBottomSheet(
            onScanComplete: onScanComplete,
            onError: onError,
          ),
        );
      },
      icon: const Icon(Icons.document_scanner),
      label: const Text('Dokument scannen'),
    );
  }
}
