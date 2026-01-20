/// AdvisorMate - Client Repository Interface
/// 
/// Definiert die Geschäftslogik für den Zugriff auf Kundendaten.

library;

import 'package:advisor_mate/domain/entities/client_entity.dart';

abstract class ClientRepository {
  /// Lädt alle Kunden
  Future<List<Client>> getAllClients();

  /// Lädt einen einzelnen Kunden by ID
  Future<Client?> getClientById(String id);

  /// Speichert einen neuen Kunden
  Future<void> saveClient(Client client);

  /// Aktualisiert einen bestehenden Kunden
  Future<void> updateClient(Client client);

  /// Löscht einen Kunden
  Future<void> deleteClient(String id);
}
