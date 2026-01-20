/// AdvisorMate - Asset & Liability Entities
/// 
/// Datenmodelle für Vermögenswerte und Verbindlichkeiten.
/// Teil der Vermögensbilanz im KYC-Prozess.

library;

import 'package:advisor_mate/core/encryption_utils.dart';
import 'package:advisor_mate/domain/entities/enums.dart';

/// Einzelner Vermögenswert eines Kunden
/// 
/// DSGVO-Hinweis: [value] enthält sensible Finanzdaten und muss
/// bei der Speicherung verschlüsselt werden.
class Asset {
  final String id;
  final String name;
  final AssetType type;
  
  /// Aktueller Wert in EUR
  /// 
  /// // ENCRYPTED: Vermögenswert - muss verschlüsselt gespeichert werden
  @SensitiveData(reason: 'Finanzieller Vermögenswert - DSGVO Art. 9')
  final double value;
  
  /// ISIN oder WKN für Wertpapiere (optional)
  final String? isin;
  
  /// Kaufdatum
  final DateTime? purchaseDate;
  
  /// Kaufpreis für Performance-Berechnung
  @SensitiveData(reason: 'Kaufpreis - DSGVO relevant')
  final double? purchasePrice;
  
  /// Notizen zum Vermögenswert
  final String? notes;

  const Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.isin,
    this.purchaseDate,
    this.purchasePrice,
    this.notes,
  });

  /// Berechnet die Performance seit Kauf in Prozent
  double? get performancePercent {
    if (purchasePrice == null || purchasePrice == 0) return null;
    return ((value - purchasePrice!) / purchasePrice!) * 100;
  }

  /// Berechnet den absoluten Gewinn/Verlust
  double? get absoluteGain {
    if (purchasePrice == null) return null;
    return value - purchasePrice!;
  }

  Asset copyWith({
    String? id,
    String? name,
    AssetType? type,
    double? value,
    String? isin,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? notes,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      isin: isin ?? this.isin,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'Asset($name: ${value.toStringAsFixed(2)} EUR)';
}

/// Verbindlichkeit eines Kunden
class Liability {
  final String id;
  final String name;
  final LiabilityType type;
  
  /// Restschuld in EUR
  /// 
  /// // ENCRYPTED: Verbindlichkeit - muss verschlüsselt gespeichert werden
  @SensitiveData(reason: 'Finanzielle Verbindlichkeit - DSGVO Art. 9')
  final double amount;
  
  /// Zinssatz in Prozent
  final double interestRate;
  
  /// Monatliche Rate
  @SensitiveData(reason: 'Monatliche Belastung')
  final double? monthlyPayment;
  
  /// Restlaufzeit in Monaten
  final int? remainingMonths;
  
  /// Kredite, bei dem die Verbindlichkeit besteht
  final String? creditor;

  const Liability({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.interestRate,
    this.monthlyPayment,
    this.remainingMonths,
    this.creditor,
  });

  /// Berechnet die gesamten Restkosten inkl. Zinsen
  double? get totalRemainingCost {
    if (monthlyPayment == null || remainingMonths == null) return null;
    return monthlyPayment! * remainingMonths!;
  }

  Liability copyWith({
    String? id,
    String? name,
    LiabilityType? type,
    double? amount,
    double? interestRate,
    double? monthlyPayment,
    int? remainingMonths,
    String? creditor,
  }) {
    return Liability(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      interestRate: interestRate ?? this.interestRate,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingMonths: remainingMonths ?? this.remainingMonths,
      creditor: creditor ?? this.creditor,
    );
  }

  @override
  String toString() => 'Liability($name: ${amount.toStringAsFixed(2)} EUR)';
}

/// Vermögensbilanz - Zusammenfassung aller Assets und Liabilities
class FinancialBalance {
  final List<Asset> assets;
  final List<Liability> liabilities;

  const FinancialBalance({
    required this.assets,
    required this.liabilities,
  });

  /// Gesamtvermögen (Summe aller Assets)
  double get totalAssets => assets.fold(0, (sum, asset) => sum + asset.value);

  /// Gesamtverbindlichkeiten
  double get totalLiabilities =>
      liabilities.fold(0, (sum, liability) => sum + liability.amount);

  /// Nettovermögen (Assets - Liabilities)
  double get netWorth => totalAssets - totalLiabilities;

  /// Verschuldungsgrad (Liabilities / Assets)
  double get debtRatio {
    if (totalAssets == 0) return 0;
    return totalLiabilities / totalAssets;
  }

  /// Asset-Allokation nach Typ
  Map<AssetType, double> get assetAllocation {
    final allocation = <AssetType, double>{};
    for (final asset in assets) {
      allocation[asset.type] = (allocation[asset.type] ?? 0) + asset.value;
    }
    return allocation;
  }

  /// Asset-Allokation in Prozent
  Map<AssetType, double> get assetAllocationPercent {
    if (totalAssets == 0) return {};
    return assetAllocation.map(
      (type, value) => MapEntry(type, (value / totalAssets) * 100),
    );
  }

  const FinancialBalance.empty()
      : assets = const [],
        liabilities = const [];

  @override
  String toString() =>
      'FinancialBalance(Net Worth: ${netWorth.toStringAsFixed(2)} EUR)';
}

/// Liquidität - Einnahmen und Ausgaben
class Liquidity {
  /// Monatliche Einnahmen (Gehalt, Mieteinnahmen, etc.)
  /// 
  /// // ENCRYPTED: Einkommensdaten
  @SensitiveData(reason: 'Monatliche Einnahmen - DSGVO Art. 9')
  final double monthlyIncome;

  /// Monatliche Fixkosten
  @SensitiveData(reason: 'Monatliche Ausgaben')
  final double monthlyExpenses;

  /// Zusätzliche variable Ausgaben
  final double? variableExpenses;

  /// Monatliche Sparrate
  final double? monthlySavings;

  const Liquidity({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    this.variableExpenses,
    this.monthlySavings,
  });

  /// Verfügbares Einkommen nach Ausgaben
  double get disposableIncome => monthlyIncome - monthlyExpenses - (variableExpenses ?? 0);

  /// Sparquote in Prozent
  double get savingsRate {
    if (monthlyIncome == 0) return 0;
    final savings = monthlySavings ?? disposableIncome;
    return (savings / monthlyIncome) * 100;
  }

  /// Prüft ob der Kunde liquide ist (Einnahmen > Ausgaben)
  bool get isLiquid => disposableIncome > 0;

  Liquidity copyWith({
    double? monthlyIncome,
    double? monthlyExpenses,
    double? variableExpenses,
    double? monthlySavings,
  }) {
    return Liquidity(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      variableExpenses: variableExpenses ?? this.variableExpenses,
      monthlySavings: monthlySavings ?? this.monthlySavings,
    );
  }

  @override
  String toString() =>
      'Liquidity(Disposable: ${disposableIncome.toStringAsFixed(2)} EUR/month)';
}
