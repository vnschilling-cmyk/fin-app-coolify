/// AdvisorMate - Client Entity
/// 
/// Haupt-Datenmodell für Kunden mit allen KYC-Informationen.
/// Enthält harte Fakten, weiche Fakten und ESG-Präferenzen.

library;

import 'package:advisor_mate/core/encryption_utils.dart';
import 'package:advisor_mate/domain/entities/asset_entity.dart';
import 'package:advisor_mate/domain/entities/enums.dart';

/// ESG-Präferenzen des Kunden nach EU-Offenlegungsverordnung
class EsgPreferences {
  /// Präferenz für Artikel 8 Produkte ("Light Green")
  /// Produkte, die ökologische oder soziale Merkmale fördern
  final bool prefersArticle8;

  /// Präferenz für Artikel 9 Produkte ("Dark Green")
  /// Produkte mit nachhaltigen Investitionen als Ziel
  final bool prefersArticle9;

  /// Mindestanteil nachhaltiger Anlagen (in %)
  final double? minimumSustainablePercentage;

  /// Ausschlusskriterien (z.B. Waffen, Kohle, etc.)
  final List<String> exclusionCriteria;

  const EsgPreferences({
    required this.prefersArticle8,
    required this.prefersArticle9,
    this.minimumSustainablePercentage,
    this.exclusionCriteria = const [],
  });

  /// Gibt die höchste ESG-Klassifizierung zurück
  EsgClassification get classification {
    if (prefersArticle9) return EsgClassification.article9;
    if (prefersArticle8) return EsgClassification.article8;
    return EsgClassification.none;
  }

  /// Prüft ob irgendeine ESG-Präferenz vorhanden ist
  bool get hasPreference => prefersArticle8 || prefersArticle9;

  EsgPreferences copyWith({
    bool? prefersArticle8,
    bool? prefersArticle9,
    double? minimumSustainablePercentage,
    List<String>? exclusionCriteria,
  }) {
    return EsgPreferences(
      prefersArticle8: prefersArticle8 ?? this.prefersArticle8,
      prefersArticle9: prefersArticle9 ?? this.prefersArticle9,
      minimumSustainablePercentage:
          minimumSustainablePercentage ?? this.minimumSustainablePercentage,
      exclusionCriteria: exclusionCriteria ?? this.exclusionCriteria,
    );
  }

  const EsgPreferences.none()
      : prefersArticle8 = false,
        prefersArticle9 = false,
        minimumSustainablePercentage = null,
        exclusionCriteria = const [];
}

/// Kundeninformationen für die Finanzberatung
/// 
/// DSGVO-HINWEIS: Diese Klasse enthält umfangreiche personenbezogene Daten.
/// Alle Felder mit [SensitiveData] Annotation müssen verschlüsselt 
/// gespeichert werden.
class Client {
  /// Eindeutige Kunden-ID
  final String id;

  /// Vorname
  @SensitiveData(reason: 'Personenbezogene Daten')
  final String firstName;

  /// Nachname
  @SensitiveData(reason: 'Personenbezogene Daten')
  final String lastName;

  /// E-Mail-Adresse
  @SensitiveData(reason: 'Kontaktdaten')
  final String email;

  /// Telefonnummer (optional)
  @SensitiveData(reason: 'Kontaktdaten')
  final String? phone;

  /// Geburtsdatum
  @SensitiveData(reason: 'Personenbezogene Daten')
  final DateTime dateOfBirth;

  // ========== HARTE FAKTEN ==========

  /// Vermögensbilanz (Assets vs. Liabilities)
  /// 
  /// // ENCRYPTED: Enthält alle Vermögenswerte und Verbindlichkeiten
  final FinancialBalance financialBalance;

  /// Liquidität (Einnahmen/Ausgaben)
  /// 
  /// // ENCRYPTED: Enthält Einkommens- und Ausgabendaten
  final Liquidity liquidity;

  /// Steuerstatus des Kunden
  final TaxStatus taxStatus;

  // ========== WEICHE FAKTEN ==========

  /// Risikoprofil (Score 1-10)
  /// 1 = sehr konservativ, 10 = sehr risikofreudig
  final int riskProfile;

  /// Primäres Anlageziel
  final InvestmentGoal investmentGoal;

  /// Sekundäre Anlageziele (optional)
  final List<InvestmentGoal> secondaryGoals;

  /// Erfahrungsstufe mit Finanzanlagen
  final ExperienceLevel experienceLevel;

  /// Anlagehorizont in Jahren
  final int investmentHorizonYears;

  // ========== ESG-PRÄFERENZEN ==========

  /// ESG-Präferenzen nach EU-Offenlegungsverordnung
  final EsgPreferences esgPreferences;

  // ========== METADATEN ==========

  /// Erstellungsdatum des Kundenprofils
  final DateTime createdAt;

  /// Letztes Update
  final DateTime updatedAt;

  /// Berater-ID (zuständiger Finanzberater)
  final String? advisorId;

  /// Notizen zum Kunden
  final String? notes;

  const Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.dateOfBirth,
    required this.financialBalance,
    required this.liquidity,
    required this.taxStatus,
    required this.riskProfile,
    required this.investmentGoal,
    this.secondaryGoals = const [],
    required this.experienceLevel,
    required this.investmentHorizonYears,
    required this.esgPreferences,
    required this.createdAt,
    required this.updatedAt,
    this.advisorId,
    this.notes,
  }) : assert(riskProfile >= 1 && riskProfile <= 10,
            'Risikoprofil muss zwischen 1 und 10 liegen');

  /// Vollständiger Name
  String get fullName => '$firstName $lastName';

  /// Alter des Kunden
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Nettovermögen (Kurzform)
  double get netWorth => financialBalance.netWorth;

  /// Prüft ob Kunde ESG-Präferenzen hat
  bool get hasEsgPreferences => esgPreferences.hasPreference;

  /// Risikoprofil als Text
  String get riskProfileText {
    if (riskProfile <= 2) return 'Sehr konservativ';
    if (riskProfile <= 4) return 'Konservativ';
    if (riskProfile <= 6) return 'Ausgewogen';
    if (riskProfile <= 8) return 'Wachstumsorientiert';
    return 'Sehr risikofreudig';
  }

  /// Prüft ob die KYC-Daten vollständig sind
  bool get isKycComplete {
    return financialBalance.assets.isNotEmpty &&
        riskProfile > 0 &&
        investmentHorizonYears > 0;
  }

  Client copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    FinancialBalance? financialBalance,
    Liquidity? liquidity,
    TaxStatus? taxStatus,
    int? riskProfile,
    InvestmentGoal? investmentGoal,
    List<InvestmentGoal>? secondaryGoals,
    ExperienceLevel? experienceLevel,
    int? investmentHorizonYears,
    EsgPreferences? esgPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? advisorId,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      financialBalance: financialBalance ?? this.financialBalance,
      liquidity: liquidity ?? this.liquidity,
      taxStatus: taxStatus ?? this.taxStatus,
      riskProfile: riskProfile ?? this.riskProfile,
      investmentGoal: investmentGoal ?? this.investmentGoal,
      secondaryGoals: secondaryGoals ?? this.secondaryGoals,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      investmentHorizonYears:
          investmentHorizonYears ?? this.investmentHorizonYears,
      esgPreferences: esgPreferences ?? this.esgPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      advisorId: advisorId ?? this.advisorId,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'Client($fullName, Net Worth: ${netWorth.toStringAsFixed(2)} EUR)';
}
