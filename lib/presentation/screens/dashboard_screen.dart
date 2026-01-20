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
import 'package:advisor_mate/presentation/widgets/document_scan_widget.dart';

/// Haupt-Dashboard für Finanzberater
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdvisorMate'),
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
          ref.invalidate(clientsProvider);
          ref.invalidate(marketIndicesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marktdaten Widget
              _MarketDataSection(),
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

/// Marktdaten-Übersicht
class _MarketDataSection extends ConsumerWidget {
  final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(marketIndicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marktübersicht',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120, // Increased from 100 to fix overflow
          child: indicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child:
                  Text('Fehler: $e', style: const TextStyle(color: Colors.red)),
            ),
            data: (indices) => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: indices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final idx = indices[index];
                return _MarketIndexCard(index: idx);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketIndexCard extends StatelessWidget {
  final MarketIndex index;

  const _MarketIndexCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final isPositive = index.isPositive;
    final color = isPositive ? Colors.green : Colors.red;

    return Card(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              index.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat('#,##0.00', 'de_DE').format(index.value),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: color,
                ),
                Text(
                  '${isPositive ? '+' : ''}${index.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
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
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
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
    final clientsAsync = ref.watch(clientsProvider);

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
