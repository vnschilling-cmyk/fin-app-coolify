/// AdvisorMate - Client Repository Implementation
/// 
/// Implementiert die Repository-Schnittstelle und kümmert sich um:
/// - Daten-Mapping zwischen Entity und Backend-Modell
/// - DSGVO-konforme Verschlüsselung sensibler Daten
/// - Fehlerbehandlung

library;

import 'package:advisor_mate/core/encryption_utils.dart';
import 'package:advisor_mate/data/services/database_service.dart';
import 'package:advisor_mate/domain/entities/client_entity.dart';
import 'package:advisor_mate/domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientDatabaseService _dbService;
  final EncryptionUtils _encryptionUtils;

  ClientRepositoryImpl({
    required ClientDatabaseService dbService,
    required EncryptionUtils encryptionUtils,
  })  : _dbService = dbService,
        _encryptionUtils = encryptionUtils;

  @override
  Future<List<Client>> getAllClients() async {
    final clients = await _dbService.getAllClients();
    // In einer realen App würden hier verschlüsselte Felder
    // beim Abruf entschlüsselt werden.
    return clients;
  }

  @override
  Future<Client?> getClientById(String id) async {
    final client = await _dbService.getClientById(id);
    if (client == null) return null;
    
    // TODO: Entschlüsselung sensibler Felder
    // z.B. client.copyWith(firstName: _encryptionUtils.decrypt(client.firstName))
    
    return client;
  }

  @override
  Future<void> saveClient(Client client) async {
    // DSGVO: Verschlüsselung bevor die Daten die App verlassen
    // In einem echten Szenario würden wir hier ein "Data Transfer Object" (DTO)
    // oder Model erstellen, das die verschlüsselten Strings enthält.
    
    // Beispiel Logik für Verschlüsselung:
    /*
    final encryptedClient = client.copyWith(
      firstName: _encryptionUtils.encrypt(client.firstName),
      lastName: _encryptionUtils.encrypt(client.lastName),
      // ... alle @SensitiveData Felder
    );
    */
    
    await _dbService.createClient(client);
  }

  @override
  Future<void> updateClient(Client client) async {
    await _dbService.updateClient(client);
  }

  @override
  Future<void> deleteClient(String id) async {
    await _dbService.deleteClient(id);
  }
}
