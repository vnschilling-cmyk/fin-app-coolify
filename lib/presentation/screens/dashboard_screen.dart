/// AdvisorMate - Dashboard Screen
///
/// Übersicht aller Kundenportfolios und Marktdaten.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:advisor_mate/domain/entities/client_entity.dart';
import 'package:advisor_mate/data/services/market_data_service.dart';
import 'package:advisor_mate/presentation/providers/providers.dart';
import 'package:advisor_mate/presentation/screens/client_detail_screen.dart';
import 'package:advisor_mate/presentation/screens/client_form_screen.dart';
import 'package:advisor_mate/presentation/screens/calculator_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:advisor_mate/presentation/widgets/document_scan_widget.dart';

/// Haupt-Dashboard für Finanzberater
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoScConsult'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Client search
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(clientsNotifierProvider);
          ref.invalidate(marketIndicesProvider);
          ref.invalidate(historicalMarketDataProvider('^GDAXI'));
          ref.invalidate(historicalMarketDataProvider('^GSPC'));
          ref.invalidate(historicalMarketDataProvider('^STOXX50E'));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marktdaten Trend Section
              _MarketTrendSection(),
              const SizedBox(height: 24),

              // Quick Actions
              _QuickActionsSection(),
              const SizedBox(height: 24),

              // Kundenliste
              _ClientsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientFormScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Neuer Kunde'),
      ),
    );
  }
}

/// Marktdaten-Trend (1 Jahr)
class _MarketTrendSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Markt-Trend (1 Jahr)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              children: [
                _LegendItem(label: 'DAX', color: Colors.blue),
                const SizedBox(width: 8),
                _LegendItem(label: 'S&P 500', color: Colors.green),
                const SizedBox(width: 8),
                _LegendItem(label: 'EuroStoxx', color: Colors.orange),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          child: Container(
            height: 250,
            padding: const EdgeInsets.fromLTRB(8, 24, 24, 8),
            child: _CombinedMarketChart(),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _CombinedMarketChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daxData = ref.watch(historicalMarketDataProvider('^GDAXI'));
    final sp500Data = ref.watch(historicalMarketDataProvider('^GSPC'));
    final stoxxData = ref.watch(historicalMarketDataProvider('^STOXX50E'));

    return daxData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
      data: (dax) => sp500Data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (sp500) => stoxxData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Fehler: $e')),
          data: (stoxx) => LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      );
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 30, // Show roughly every month
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < dax.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MM/yy').format(dax[index].date),
                            style: const TextStyle(
                                fontSize: 9, color: Colors.grey),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _generateLine(dax, Colors.blue),
                _generateLine(sp500, Colors.green),
                _generateLine(stoxx, Colors.orange),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final value = spot.y.toStringAsFixed(1);
                      return LineTooltipItem(
                        '$value%',
                        const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _generateLine(List<HistoricalPoint> points, Color color) {
    if (points.isEmpty) return LineChartBarData(spots: [], color: color);

    final startValue = points.first.value;

    return LineChartBarData(
      spots: points.asMap().entries.map((e) {
        final normalizedValue = (e.value.value / startValue) * 100;
        return FlSpot(e.key.toDouble(), normalizedValue);
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }
}

/// Quick Actions für Berater-Tools
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schnellzugriff',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.calculate,
                label: 'Finanzrechner',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DocumentScanWidget(
                onScanComplete: (path) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dokument gespeichert: $path')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon,
                  size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kundenliste mit Portfolio-Übersicht
class _ClientsSection extends ConsumerWidget {
  final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meine Kunden',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // TODO: View all clients
              },
              child: const Text('Alle anzeigen'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        clientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Fehler: $e'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(clientsProvider),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
          data: (clients) {
            if (clients.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Noch keine Kunden vorhanden',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Add first client
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Ersten Kunden anlegen'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: clients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final client = clients[index];
                return _ClientCard(
                  client: client,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientDetailScreen(clientId: client.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

  _ClientCard({
    required this.client,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '${client.firstName[0]}${client.lastName[0]}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(client.fullName),
        subtitle: Row(
          children: [
            Text(client.investmentGoal.displayName),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRiskColor(client.riskProfile).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Risiko ${client.riskProfile}',
                style: TextStyle(
                  fontSize: 10,
                  color: _getRiskColor(client.riskProfile),
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(client.netWorth),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (client.hasEsgPreferences)
              const Icon(Icons.eco, size: 16, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(int riskProfile) {
    if (riskProfile <= 3) return Colors.green;
    if (riskProfile <= 6) return Colors.orange;
    return Colors.red;
  }
}
