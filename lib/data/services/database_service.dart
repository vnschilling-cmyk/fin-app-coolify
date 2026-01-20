/// AdvisorMate - Database Service Abstraction
/// 
/// Abstrakte Schnittstelle für Backend-Operationen.
/// Ermöglicht einfachen Wechsel zwischen PocketBase, Supabase, Firebase, etc.

library;

import 'package:advisor_mate/domain/entities/client_entity.dart';

/// Abstrakte Datenbank-Service Schnittstelle
/// 
/// Diese Abstraktion ermöglicht:
/// - Einfachen Wechsel des Backend-Providers
/// - Bessere Testbarkeit durch Mocking
/// - Trennung von Geschäftslogik und Datenzugriff
abstract class DatabaseService {
  /// Initialisiert die Datenbankverbindung
  Future<void> initialize();

  /// Beendet die Datenbankverbindung
  Future<void> dispose();

  /// Prüft ob eine Verbindung besteht
  bool get isConnected;
}

/// Client-spezifische Datenbankoperationen
abstract class ClientDatabaseService extends DatabaseService {
  /// Lädt alle Kunden des aktuellen Beraters
  Future<List<Client>> getAllClients();

  /// Lädt einen einzelnen Kunden by ID
  Future<Client?> getClientById(String clientId);

  /// Erstellt einen neuen Kunden
  /// 
  /// HINWEIS: Implementierung muss sensible Daten vor dem
  /// Speichern verschlüsseln!
  Future<Client> createClient(Client client);

  /// Aktualisiert einen bestehenden Kunden
  Future<Client> updateClient(Client client);

  /// Löscht einen Kunden (DSGVO: Recht auf Löschung)
  Future<void> deleteClient(String clientId);

  /// Sucht Kunden nach Name
  Future<List<Client>> searchClients(String query);
}

/// PocketBase Implementierung des DatabaseService
/// 
/// TODO: Implementierung mit pocketbase_dart Package
class PocketBaseDatabaseService implements ClientDatabaseService {
  final String baseUrl;
  bool _isConnected = false;

  PocketBaseDatabaseService({required this.baseUrl});

  @override
  Future<void> initialize() async {
    // TODO: PocketBase Client initialisieren
    // final pb = PocketBase(baseUrl);
    // await pb.health.check();
    _isConnected = true;
  }

  @override
  Future<void> dispose() async {
    _isConnected = false;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<List<Client>> getAllClients() async {
    // TODO: Implementierung mit PocketBase
    // final records = await pb.collection('clients').getFullList();
    // return records.map((r) => Client.fromRecord(r)).toList();
    throw UnimplementedError('PocketBase Integration pending');
  }

  @override
  Future<Client?> getClientById(String clientId) async {
    // TODO: Implementierung mit PocketBase
    throw UnimplementedError('PocketBase Integration pending');
  }

  @override
  Future<Client> createClient(Client client) async {
    // TODO: Implementierung mit PocketBase
    // WICHTIG: Sensible Daten vor dem Speichern verschlüsseln!
    throw UnimplementedError('PocketBase Integration pending');
  }

  @override
  Future<Client> updateClient(Client client) async {
    // TODO: Implementierung mit PocketBase
    throw UnimplementedError('PocketBase Integration pending');
  }

  @override
  Future<void> deleteClient(String clientId) async {
    // TODO: Implementierung mit PocketBase
    // DSGVO: Komplette Löschung aller Kundendaten
    throw UnimplementedError('PocketBase Integration pending');
  }

  @override
  Future<List<Client>> searchClients(String query) async {
    // TODO: Implementierung mit PocketBase
    throw UnimplementedError('PocketBase Integration pending');
  }
}

/// Mock-Implementierung für Entwicklung und Tests
class MockDatabaseService implements ClientDatabaseService {
  final List<Client> _clients = [];
  bool _isConnected = false;

  @override
  Future<void> initialize() async {
    _isConnected = true;
  }

  @override
  Future<void> dispose() async {
    _isConnected = false;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<List<Client>> getAllClients() async {
    return List.unmodifiable(_clients);
  }

  @override
  Future<Client?> getClientById(String clientId) async {
    try {
      return _clients.firstWhere((c) => c.id == clientId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Client> createClient(Client client) async {
    _clients.add(client);
    return client;
  }

  @override
  Future<Client> updateClient(Client client) async {
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index >= 0) {
      _clients[index] = client;
    }
    return client;
  }

  @override
  Future<void> deleteClient(String clientId) async {
    _clients.removeWhere((c) => c.id == clientId);
  }

  @override
  Future<List<Client>> searchClients(String query) async {
    final lowerQuery = query.toLowerCase();
    return _clients.where((c) =>
        c.fullName.toLowerCase().contains(lowerQuery) ||
        c.email.toLowerCase().contains(lowerQuery)).toList();
  }
}
