/// AdvisorMate - Market Data Service
///
/// Platzhalter für die Anbindung an Marktdaten-APIs (z.B. Yahoo Finance).
/// Liefert Aktienkurse, Indizes und Marktübersichten.

library;

import 'dart:math';

/// Marktdaten für ein Wertpapier
class MarketQuote {
  final String symbol;
  final String name;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double? previousClose;
  final double? open;
  final double? dayHigh;
  final double? dayLow;
  final int? volume;
  final DateTime timestamp;

  const MarketQuote({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    this.previousClose,
    this.open,
    this.dayHigh,
    this.dayLow,
    this.volume,
    required this.timestamp,
  });

  bool get isPositive => change >= 0;

  @override
  String toString() =>
      '$symbol: ${currentPrice.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)';
}

/// Datenpunkt für Historische Daten
class HistoricalPoint {
  final DateTime date;
  final double value;

  const HistoricalPoint(this.date, this.value);
}

/// Index-Übersicht (DAX, S&P 500, etc.)
class MarketIndex {
  final String symbol;
  final String name;
  final double value;
  final double change;
  final double changePercent;
  final DateTime timestamp;

  const MarketIndex({
    required this.symbol,
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
    required this.timestamp,
  });

  bool get isPositive => change >= 0;
}

/// Service für Marktdaten-Abruf
abstract class MarketDataService {
  /// Lädt aktuelle Quote für ein Symbol
  Future<MarketQuote> getQuote(String symbol);

  /// Lädt Quotes für mehrere Symbole
  Future<List<MarketQuote>> getQuotes(List<String> symbols);

  /// Lädt die wichtigsten Markt-Indizes
  Future<List<MarketIndex>> getMajorIndices();

  /// Lädt historische Daten für ein Symbol
  Future<List<HistoricalPoint>> getHistoricalData(String symbol,
      {required Duration duration});

  /// Sucht nach Wertpapieren
  Future<List<MarketQuote>> searchSecurities(String query);
}

/// Mock-Service für Entwicklung und Tests
class MockMarketDataService implements MarketDataService {
  @override
  Future<MarketQuote> getQuote(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MarketQuote(
      symbol: symbol,
      name: 'Mock Security $symbol',
      currentPrice: 100.0 + (symbol.hashCode % 100),
      change: 2.5,
      changePercent: 2.5,
      previousClose: 97.5,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<MarketQuote>> getQuotes(List<String> symbols) async {
    return Future.wait(symbols.map(getQuote));
  }

  @override
  Future<List<MarketIndex>> getMajorIndices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      MarketIndex(
        symbol: '^GDAXI',
        name: 'DAX',
        value: 18542.75,
        change: 125.30,
        changePercent: 0.68,
        timestamp: DateTime.now(),
      ),
      MarketIndex(
        symbol: '^GSPC',
        name: 'S&P 500',
        value: 5234.18,
        change: 42.15,
        changePercent: 0.81,
        timestamp: DateTime.now(),
      ),
      MarketIndex(
        symbol: '^STOXX50E',
        name: 'EURO STOXX 50',
        value: 4892.45,
        change: -15.20,
        changePercent: -0.31,
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<HistoricalPoint>> getHistoricalData(String symbol,
      {required Duration duration}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final random = Random(symbol.hashCode);
    final points = <HistoricalPoint>[];
    final now = DateTime.now();

    // Startwert basierend auf aktuellem Mock-Wert
    double currentValue = 100.0;
    if (symbol == '^GDAXI') currentValue = 18542.75;
    if (symbol == '^GSPC') currentValue = 5234.18;
    if (symbol == '^STOXX50E') currentValue = 4892.45;

    // Rückwärts generieren
    final days = duration.inDays;
    final interval =
        days > 30 ? 7 : 1; // Wöchentlich bei 1 Jahr, täglich bei 1 Monat

    for (int i = days; i >= 0; i -= interval) {
      final date = now.subtract(Duration(days: i));
      // Random Walk: +/- 1% pro Schritt
      final change = (random.nextDouble() - 0.5) * 0.02;
      currentValue = currentValue * (1 + change);
      points.add(HistoricalPoint(date, currentValue));
    }

    return points;
  }

  @override
  Future<List<MarketQuote>> searchSecurities(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      MarketQuote(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        currentPrice: 178.50,
        change: 1.25,
        changePercent: 0.71,
        timestamp: DateTime.now(),
      ),
    ];
  }
}
