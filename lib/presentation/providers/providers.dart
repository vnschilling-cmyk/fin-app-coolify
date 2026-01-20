/// AdvisorMate - Riverpod Providers
///
/// Zentrale Provider-Definitionen für State Management.

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advisor_mate/data/services/auth_service.dart';
import 'package:advisor_mate/data/services/database_service.dart';
import 'package:advisor_mate/data/services/financial_calculator.dart';
import 'package:advisor_mate/data/services/market_data_service.dart';
import 'package:advisor_mate/domain/entities/client_entity.dart';
import 'package:advisor_mate/core/encryption_utils.dart';
import 'package:advisor_mate/core/constants.dart';
import 'package:advisor_mate/data/repositories/client_repository_impl.dart';
import 'package:advisor_mate/domain/repositories/client_repository.dart';

// ========== SERVICES ==========

/// Encryption Utils Provider
final encryptionUtilsProvider = Provider<EncryptionUtils>((ref) {
  return EncryptionUtils();
});

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Database Service Provider
///
/// Nutzt PocketBaseDatabaseService mit der URL aus den Konstanten.
final databaseServiceProvider = Provider<ClientDatabaseService>((ref) {
  return PocketBaseDatabaseService(baseUrl: ApiConstants.pocketBaseUrl);
});

/// Financial Calculator Provider
final financialCalculatorProvider = Provider<FinancialCalculator>((ref) {
  return FinancialCalculator();
});

/// Market Data Service Provider
final marketDataServiceProvider = Provider<MarketDataService>((ref) {
  return MockMarketDataService();
});
// ========== REPOSITORIES ==========

/// Client Repository Provider
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final encryptionUtils = ref.watch(encryptionUtilsProvider);
  return ClientRepositoryImpl(
    dbService: dbService,
    encryptionUtils: encryptionUtils,
  );
});

// ========== STATE ==========

/// Authentifizierungs-Status
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

/// Aktuell ausgewählter Kunde
final selectedClientIdProvider = StateProvider<String?>((ref) => null);

// ========== ASYNC DATA ==========

/// Alle Kunden des Beraters
final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getAllClients();
});

/// Einzelner Kunde by ID
final clientByIdProvider =
    FutureProvider.family<Client?, String>((ref, clientId) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getClientById(clientId);
});

/// Markt-Indizes für Dashboard
final marketIndicesProvider = FutureProvider<List<MarketIndex>>((ref) async {
  final marketService = ref.watch(marketDataServiceProvider);
  return await marketService.getMajorIndices();
});

/// Historische Daten für Markt-Indizes (1 Jahr)
final historicalMarketDataProvider =
    FutureProvider.family<List<HistoricalPoint>, String>((ref, symbol) async {
  final marketService = ref.watch(marketDataServiceProvider);
  return await marketService.getHistoricalData(symbol,
      duration: const Duration(days: 365));
});

// ========== NOTIFIERS ==========

/// Notifier für Client-Liste mit CRUD-Operationen
class ClientsNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    final dbService = ref.watch(databaseServiceProvider);
    return await dbService.getAllClients();
  }

  Future<void> addClient(Client client) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.createClient(client);
    ref.invalidateSelf();
  }

  Future<void> updateClient(Client client) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.updateClient(client);
    ref.invalidateSelf();
  }

  Future<void> deleteClient(String clientId) async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.deleteClient(clientId);
    ref.invalidateSelf();
  }
}

final clientsNotifierProvider =
    AsyncNotifierProvider<ClientsNotifier, List<Client>>(() {
  return ClientsNotifier();
});

/// Notifier für Zinseszins-Berechnung
class CompoundInterestNotifier extends StateNotifier<CompoundInterestState> {
  final FinancialCalculator _calculator;

  CompoundInterestNotifier(this._calculator)
      : super(const CompoundInterestState());

  void updatePrincipal(double value) {
    state = state.copyWith(principal: value);
    _calculate();
  }

  void updateAnnualRate(double value) {
    state = state.copyWith(annualRate: value / 100); // Convert from percentage
    _calculate();
  }

  void updateYears(int value) {
    state = state.copyWith(years: value);
    _calculate();
  }

  void updateMonthlyContribution(double value) {
    state = state.copyWith(monthlyContribution: value);
    _calculate();
  }

  void _calculate() {
    if (state.principal <= 0 || state.years <= 0) {
      state = state.copyWith(result: null);
      return;
    }

    final result = _calculator.calculateCompoundInterestWithContributions(
      principal: state.principal,
      monthlyContribution: state.monthlyContribution,
      annualRate: state.annualRate,
      years: state.years,
    );

    state = state.copyWith(result: result);
  }
}

class CompoundInterestState {
  final double principal;
  final double annualRate;
  final int years;
  final double monthlyContribution;
  final double? result;

  const CompoundInterestState({
    this.principal = 0,
    this.annualRate = 0.05,
    this.years = 10,
    this.monthlyContribution = 0,
    this.result,
  });

  CompoundInterestState copyWith({
    double? principal,
    double? annualRate,
    int? years,
    double? monthlyContribution,
    double? result,
  }) {
    return CompoundInterestState(
      principal: principal ?? this.principal,
      annualRate: annualRate ?? this.annualRate,
      years: years ?? this.years,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      result: result ?? this.result,
    );
  }
}

final compoundInterestProvider =
    StateNotifierProvider<CompoundInterestNotifier, CompoundInterestState>(
        (ref) {
  final calculator = ref.watch(financialCalculatorProvider);
  return CompoundInterestNotifier(calculator);
});
