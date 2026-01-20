/// AdvisorMate - Database Service Abstraction
///
/// Abstrakte Schnittstelle für Backend-Operationen.
/// Ermöglicht einfachen Wechsel zwischen PocketBase, Supabase, Firebase, etc.

library;

import 'package:pocketbase/pocketbase.dart';
import 'package:advisor_mate/domain/entities/client_entity.dart';
import 'package:advisor_mate/domain/entities/asset_entity.dart';
import 'package:advisor_mate/domain/entities/enums.dart';

/// Abstrakte Datenbank-Service Schnittstelle
abstract class DatabaseService {
  Future<void> initialize();
  Future<void> dispose();
  bool get isConnected;
}

/// Client-spezifische Datenbankoperationen
abstract class ClientDatabaseService extends DatabaseService {
  Future<List<Client>> getAllClients();
  Future<Client?> getClientById(String clientId);
  Future<Client> createClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String clientId);
  Future<List<Client>> searchClients(String query);
}

/// PocketBase Implementierung des DatabaseService
class PocketBaseDatabaseService implements ClientDatabaseService {
  final String baseUrl;
  late final PocketBase _pb;
  bool _isConnected = false;

  PocketBaseDatabaseService({required this.baseUrl}) {
    _pb = PocketBase(baseUrl);
  }

  @override
  Future<void> initialize() async {
    try {
      await _pb.health.check();
      _isConnected = true;
    } catch (_) {
      _isConnected = false;
    }
  }

  @override
  Future<void> dispose() async {
    _isConnected = false;
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<List<Client>> getAllClients() async {
    final records = await _pb.collection('clients').getFullList(
          sort: '-created',
        );
    return records.map((r) => _mapRecordToClient(r)).toList();
  }

  @override
  Future<Client?> getClientById(String clientId) async {
    try {
      final record = await _pb.collection('clients').getOne(clientId);
      return _mapRecordToClient(record);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Client> createClient(Client client) async {
    final body = _mapClientToMap(client);
    final record = await _pb.collection('clients').create(body: body);
    return _mapRecordToClient(record);
  }

  @override
  Future<Client> updateClient(Client client) async {
    final body = _mapClientToMap(client);
    final record =
        await _pb.collection('clients').update(client.id, body: body);
    return _mapRecordToClient(record);
  }

  @override
  Future<void> deleteClient(String clientId) async {
    await _pb.collection('clients').delete(clientId);
  }

  @override
  Future<List<Client>> searchClients(String query) async {
    final records = await _pb.collection('clients').getList(
          filter:
              'firstName ~ "$query" || lastName ~ "$query" || email ~ "$query"',
        );
    return records.items.map((r) => _mapRecordToClient(r)).toList();
  }

  // ========== MAPPING HELPER ==========

  Client _mapRecordToClient(RecordModel record) {
    return Client(
      id: record.id,
      firstName: record.getStringValue('firstName'),
      lastName: record.getStringValue('lastName'),
      email: record.getStringValue('email'),
      dateOfBirth: DateTime.parse(record.getStringValue('dateOfBirth')),
      financialBalance: _mapJsonToBalance(
          record.getDataValue<Map<String, dynamic>>('financialBalance') ?? {}),
      liquidity: _mapJsonToLiquidity(
          record.getDataValue<Map<String, dynamic>>('liquidity') ?? {}),
      taxStatus: TaxStatus.fromApiValue(record.getStringValue('taxStatus')),
      riskProfile: record.getIntValue('riskProfile'),
      investmentGoal:
          InvestmentGoal.fromApiValue(record.getStringValue('investmentGoal')),
      experienceLevel: ExperienceLevel.fromApiValue(
          record.getStringValue('experienceLevel')),
      investmentHorizonYears: record.getIntValue('investmentHorizonYears', 10),
      esgPreferences: _mapJsonToEsg(
          record.getDataValue<Map<String, dynamic>>('esgPreferences') ?? {}),
      createdAt: DateTime.parse(record.created),
      updatedAt: DateTime.parse(record.updated),
    );
  }

  Map<String, dynamic> _mapClientToMap(Client client) {
    return {
      'firstName': client.firstName,
      'lastName': client.lastName,
      'email': client.email,
      'dateOfBirth': client.dateOfBirth.toIso8601String(),
      'riskProfile': client.riskProfile,
      'investmentGoal': client.investmentGoal.apiValue,
      'experienceLevel': client.experienceLevel.apiValue,
      'investmentHorizonYears': client.investmentHorizonYears,
      'taxStatus': client.taxStatus.apiValue,
      'financialBalance': {
        'totalAssets': client.financialBalance.totalAssets,
        'totalLiabilities': client.financialBalance.totalLiabilities,
      },
      'liquidity': {
        'monthlyIncome': client.liquidity.monthlyIncome,
        'monthlyExpenses': client.liquidity.monthlyExpenses,
      },
      'esgPreferences': {
        'prefersArticle8': client.esgPreferences.prefersArticle8,
        'prefersArticle9': client.esgPreferences.prefersArticle9,
      },
    };
  }

  FinancialBalance _mapJsonToBalance(Map<String, dynamic> json) {
    // In einer echten App würden hier die Details aus dem JSON gemappt werden
    return FinancialBalance(
      assets: [
        Asset(
            id: '1',
            name: 'Gesamt',
            type: AssetType.cash,
            value: (json['totalAssets'] ?? 0).toDouble())
      ],
      liabilities: [
        Liability(
            id: '1',
            name: 'Gesamt',
            type: LiabilityType.other,
            amount: (json['totalLiabilities'] ?? 0).toDouble(),
            interestRate: 0)
      ],
    );
  }

  Liquidity _mapJsonToLiquidity(Map<String, dynamic> json) {
    return Liquidity(
      monthlyIncome: (json['monthlyIncome'] ?? 0).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] ?? 0).toDouble(),
    );
  }

  EsgPreferences _mapJsonToEsg(Map<String, dynamic> json) {
    return EsgPreferences(
      prefersArticle8: json['prefersArticle8'] ?? false,
      prefersArticle9: json['prefersArticle9'] ?? false,
    );
  }
}

/// Mock-Implementierung für Entwicklung und Tests
class MockDatabaseService implements ClientDatabaseService {
  final List<Client> _clients = [];
  bool _isConnected = false;

  @override
  Future<void> initialize() async {
    _isConnected = true;
    _clients.add(
      Client(
        id: 'mock-1',
        firstName: 'Max (Mock)',
        lastName: 'Mustermann',
        email: 'max@example.com',
        dateOfBirth: DateTime(1985, 5, 20),
        financialBalance: const FinancialBalance.empty(),
        liquidity: const Liquidity(monthlyIncome: 4500, monthlyExpenses: 3200),
        taxStatus: TaxStatus.residentTaxable,
        riskProfile: 6,
        investmentGoal: InvestmentGoal.retirement,
        experienceLevel: ExperienceLevel.intermediate,
        investmentHorizonYears: 25,
        esgPreferences: const EsgPreferences.none(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
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
    return _clients
        .where(
          (c) =>
              c.fullName.toLowerCase().contains(lowerQuery) ||
              c.email.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
