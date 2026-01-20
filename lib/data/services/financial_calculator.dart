/// AdvisorMate - Financial Calculator Service
/// 
/// Berechnungslogik für Finanzrechner-Tools.
/// Enthält Zinseszins, Rentenlücke und weitere Finanzberechnungen.

library;

import 'dart:math' as math;

/// Service-Klasse für Finanzberechnungen
/// 
/// Stellt verschiedene Rechner für die Finanzberatung bereit:
/// - Zinseszins-Rechner
/// - Rentenlücken-Rechner (inflationsbereinigt)
/// - Annuitäten-Rechner
class FinancialCalculator {
  /// Standard-Inflationsrate für Deutschland (in Dezimal, z.B. 0.02 für 2%)
  static const double defaultInflationRate = 0.02;

  /// Berechnet Zinseszins (Compound Interest)
  /// 
  /// Formel: A = P(1 + r/n)^(nt)
  /// 
  /// Parameter:
  /// - [principal]: Anfangskapital (P)
  /// - [annualRate]: Jährlicher Zinssatz in Dezimal (r), z.B. 0.05 für 5%
  /// - [compoundingPerYear]: Anzahl der Zinsperioden pro Jahr (n)
  /// - [years]: Anlagedauer in Jahren (t)
  /// 
  /// Rückgabe: Endkapital nach [years] Jahren
  /// 
  /// Beispiel:
  /// ```dart
  /// final calculator = FinancialCalculator();
  /// final result = calculator.calculateCompoundInterest(
  ///   principal: 10000,
  ///   annualRate: 0.05,
  ///   compoundingPerYear: 12,
  ///   years: 10,
  /// );
  /// // Result: ~16,470.09 EUR
  /// ```
  double calculateCompoundInterest({
    required double principal,
    required double annualRate,
    int compoundingPerYear = 12,
    required int years,
  }) {
    if (principal < 0) {
      throw ArgumentError('Anfangskapital kann nicht negativ sein');
    }
    if (annualRate < 0) {
      throw ArgumentError('Zinssatz kann nicht negativ sein');
    }
    if (years < 0) {
      throw ArgumentError('Anlagedauer kann nicht negativ sein');
    }

    final n = compoundingPerYear;
    final t = years;
    final r = annualRate;

    // A = P(1 + r/n)^(nt)
    return principal * math.pow(1 + r / n, n * t);
  }

  /// Berechnet Zinseszins mit regelmäßigen Einzahlungen
  /// 
  /// [monthlyContribution]: Monatliche Sparrate
  /// 
  /// Berücksichtigt sowohl das Anfangskapital als auch monatliche Einzahlungen.
  double calculateCompoundInterestWithContributions({
    required double principal,
    required double monthlyContribution,
    required double annualRate,
    required int years,
  }) {
    final monthlyRate = annualRate / 12;
    final totalMonths = years * 12;

    // Zinseszins auf Anfangskapital
    final principalGrowth = principal * math.pow(1 + monthlyRate, totalMonths);

    // Future Value of Annuity (Sparplan)
    // FV = PMT * [((1 + r)^n - 1) / r]
    final contributionGrowth = monthlyContribution *
        ((math.pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate);

    return principalGrowth + contributionGrowth;
  }

  /// Berechnet die Rentenlücke (Inflation-adjusted Savings Goal)
  /// 
  /// Ermittelt, wie viel Kapital benötigt wird, um eine gewünschte
  /// monatliche Rente über einen bestimmten Zeitraum zu finanzieren,
  /// unter Berücksichtigung der Inflation.
  /// 
  /// Parameter:
  /// - [desiredMonthlyIncome]: Gewünschtes monatliches Einkommen im Ruhestand
  /// - [currentMonthlyIncome]: Aktuelles monatliches Einkommen
  /// - [expectedPension]: Erwartete gesetzliche/betriebliche Rente
  /// - [yearsUntilRetirement]: Jahre bis zum Ruhestand
  /// - [retirementDurationYears]: Geplante Rentenbezugsdauer
  /// - [inflationRate]: Jährliche Inflationsrate (Standard: 2%)
  /// - [expectedReturnRate]: Erwartete Rendite im Ruhestand
  /// 
  /// Rückgabe: Benötigtes Kapital bei Renteneintritt
  double calculateRetirementGap({
    required double desiredMonthlyIncome,
    required double expectedPension,
    required int yearsUntilRetirement,
    int retirementDurationYears = 25,
    double inflationRate = defaultInflationRate,
    double expectedReturnRate = 0.03,
  }) {
    // Inflationsbereinigtes gewünschtes Einkommen
    final inflatedDesiredIncome = desiredMonthlyIncome *
        math.pow(1 + inflationRate, yearsUntilRetirement);

    // Inflationsbereinigte erwartete Rente
    final inflatedPension =
        expectedPension * math.pow(1 + inflationRate, yearsUntilRetirement);

    // Monatliche Lücke
    final monthlyGap = inflatedDesiredIncome - inflatedPension;
    if (monthlyGap <= 0) return 0; // Keine Lücke

    // Realrendite (Rendite - Inflation)
    final realReturnRate = expectedReturnRate - inflationRate;
    final monthlyRealRate = realReturnRate / 12;
    final totalMonths = retirementDurationYears * 12;

    // Present Value of Annuity (benötigtes Kapital)
    // PV = PMT * [(1 - (1 + r)^-n) / r]
    if (monthlyRealRate <= 0) {
      // Keine oder negative Realrendite: einfache Multiplikation
      return monthlyGap * totalMonths;
    }

    return monthlyGap *
        ((1 - math.pow(1 + monthlyRealRate, -totalMonths)) / monthlyRealRate);
  }

  /// Berechnet die benötigte monatliche Sparrate um ein Ziel zu erreichen
  /// 
  /// [targetAmount]: Zielkapital
  /// [currentSavings]: Aktuelles Kapital
  /// [annualRate]: Erwartete jährliche Rendite
  /// [years]: Jahre bis zum Ziel
  double calculateRequiredMonthlySavings({
    required double targetAmount,
    double currentSavings = 0,
    required double annualRate,
    required int years,
  }) {
    final monthlyRate = annualRate / 12;
    final totalMonths = years * 12;

    // Wachstum des aktuellen Kapitals
    final currentSavingsGrowth =
        currentSavings * math.pow(1 + monthlyRate, totalMonths);

    // Verbleibendes Ziel
    final remainingTarget = targetAmount - currentSavingsGrowth;
    if (remainingTarget <= 0) return 0; // Ziel bereits erreicht

    // PMT = FV * r / [(1 + r)^n - 1]
    return remainingTarget *
        monthlyRate /
        (math.pow(1 + monthlyRate, totalMonths) - 1);
  }

  /// Berechnet die monatliche Annuität (Rate) für einen Kredit
  /// 
  /// [loanAmount]: Kreditsumme
  /// [annualInterestRate]: Jährlicher Zinssatz
  /// [termYears]: Laufzeit in Jahren
  double calculateLoanPayment({
    required double loanAmount,
    required double annualInterestRate,
    required int termYears,
  }) {
    final monthlyRate = annualInterestRate / 12;
    final totalPayments = termYears * 12;

    // PMT = P * [r(1+r)^n] / [(1+r)^n - 1]
    final numerator = monthlyRate * math.pow(1 + monthlyRate, totalPayments);
    final denominator = math.pow(1 + monthlyRate, totalPayments) - 1;

    return loanAmount * (numerator / denominator);
  }

  /// Berechnet den Barwert (Present Value) einer zukünftigen Summe
  /// 
  /// [futureValue]: Zukünftiger Wert
  /// [discountRate]: Diskontierungsrate (jährlich)
  /// [years]: Jahre in der Zukunft
  double calculatePresentValue({
    required double futureValue,
    required double discountRate,
    required int years,
  }) {
    return futureValue / math.pow(1 + discountRate, years);
  }

  /// Berechnet die effektive Jahresrendite aus verschiedenen Perioden
  /// 
  /// [nominalRate]: Nominaler Zinssatz
  /// [periodsPerYear]: Verzinsungsperioden pro Jahr
  double calculateEffectiveAnnualRate({
    required double nominalRate,
    int periodsPerYear = 12,
  }) {
    return math.pow(1 + nominalRate / periodsPerYear, periodsPerYear) - 1;
  }
}
