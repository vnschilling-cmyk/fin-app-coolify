/// AdvisorMate - Enumerations
/// 
/// Typsichere Enums für alle Auswahl-Felder im KYC-Prozess.

library;

/// Anlageziele des Kunden
/// 
/// Definiert die primären finanziellen Ziele für die Beratung.
enum InvestmentGoal {
  /// Altersvorsorge / Ruhestandsplanung
  retirement('Altersvorsorge', 'retirement'),
  
  /// Immobilienerwerb
  realEstate('Immobilienerwerb', 'real_estate'),
  
  /// Vermögenserhalt / Kapitalerhaltung
  wealthPreservation('Vermögenserhalt', 'wealth_preservation'),
  
  /// Vermögensaufbau
  wealthBuilding('Vermögensaufbau', 'wealth_building'),
  
  /// Einkommenserzielung
  incomeGeneration('Einkommenserzielung', 'income_generation');

  final String displayName;
  final String apiValue;
  
  const InvestmentGoal(this.displayName, this.apiValue);
  
  /// Konvertiert API-Wert zu Enum
  static InvestmentGoal fromApiValue(String value) {
    return InvestmentGoal.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => InvestmentGoal.wealthPreservation,
    );
  }
}

/// Steuerstatus des Kunden
enum TaxStatus {
  /// Unbeschränkt steuerpflichtig in Deutschland
  residentTaxable('Unbeschränkt steuerpflichtig', 'resident'),
  
  /// Beschränkt steuerpflichtig
  limitedTaxable('Beschränkt steuerpflichtig', 'limited'),
  
  /// Steuerausländer
  nonResident('Steuerausländer', 'non_resident'),
  
  /// Körperschaft
  corporate('Körperschaft', 'corporate');

  final String displayName;
  final String apiValue;
  
  const TaxStatus(this.displayName, this.apiValue);
  
  static TaxStatus fromApiValue(String value) {
    return TaxStatus.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => TaxStatus.residentTaxable,
    );
  }
}

/// Erfahrungsstufe des Kunden mit Finanzanlagen
enum ExperienceLevel {
  /// Keine Erfahrung
  none('Keine Erfahrung', 'none', 0),
  
  /// Grundkenntnisse (< 2 Jahre)
  basic('Grundkenntnisse', 'basic', 1),
  
  /// Fortgeschritten (2-5 Jahre)
  intermediate('Fortgeschritten', 'intermediate', 2),
  
  /// Erfahren (5-10 Jahre)
  experienced('Erfahren', 'experienced', 3),
  
  /// Experte (> 10 Jahre)
  expert('Experte', 'expert', 4);

  final String displayName;
  final String apiValue;
  final int level;
  
  const ExperienceLevel(this.displayName, this.apiValue, this.level);
  
  static ExperienceLevel fromApiValue(String value) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => ExperienceLevel.none,
    );
  }
}

/// Art des Vermögenswerts
enum AssetType {
  /// Bargeld und Bankeinlagen
  cash('Bargeld/Bankeinlagen', 'cash'),
  
  /// Aktien
  stocks('Aktien', 'stocks'),
  
  /// Anleihen
  bonds('Anleihen', 'bonds'),
  
  /// Investmentfonds
  funds('Investmentfonds', 'funds'),
  
  /// ETFs
  etf('ETFs', 'etf'),
  
  /// Immobilien
  realEstate('Immobilien', 'real_estate'),
  
  /// Edelmetalle
  preciousMetals('Edelmetalle', 'precious_metals'),
  
  /// Kryptowährungen
  crypto('Kryptowährungen', 'crypto'),
  
  /// Versicherungen/Lebensversicherungen
  insurance('Versicherungen', 'insurance'),
  
  /// Sonstige
  other('Sonstige', 'other');

  final String displayName;
  final String apiValue;
  
  const AssetType(this.displayName, this.apiValue);
  
  static AssetType fromApiValue(String value) {
    return AssetType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => AssetType.other,
    );
  }
}

/// Art der Verbindlichkeit
enum LiabilityType {
  /// Hypothek/Immobilienkredit
  mortgage('Hypothek', 'mortgage'),
  
  /// Konsumentenkredit
  consumerLoan('Konsumentenkredit', 'consumer_loan'),
  
  /// Autokredit
  carLoan('Autokredit', 'car_loan'),
  
  /// Studienkredit
  studentLoan('Studienkredit', 'student_loan'),
  
  /// Kreditkartenschulden
  creditCard('Kreditkartenschulden', 'credit_card'),
  
  /// Sonstige Verbindlichkeiten
  other('Sonstige', 'other');

  final String displayName;
  final String apiValue;
  
  const LiabilityType(this.displayName, this.apiValue);
  
  static LiabilityType fromApiValue(String value) {
    return LiabilityType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => LiabilityType.other,
    );
  }
}

/// ESG-Klassifizierung nach EU-Offenlegungsverordnung
enum EsgClassification {
  /// Keine ESG-Präferenz
  none('Keine Präferenz', 'none'),
  
  /// Artikel 6 - Keine Nachhaltigkeitsmerkmale
  article6('Artikel 6', 'article_6'),
  
  /// Artikel 8 - "Light Green" - Fördert ökologische/soziale Merkmale
  article8('Artikel 8 (Light Green)', 'article_8'),
  
  /// Artikel 9 - "Dark Green" - Hat nachhaltige Investitionen als Ziel
  article9('Artikel 9 (Dark Green)', 'article_9');

  final String displayName;
  final String apiValue;
  
  const EsgClassification(this.displayName, this.apiValue);
}
