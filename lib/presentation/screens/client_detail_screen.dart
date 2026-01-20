/// AdvisorMate - Client Detail Screen
///
/// Übersichtliche Darstellung aller KYC-Daten eines Kunden.
/// Aufgeteilt in Abschnitte: Finanzdaten, Risikoprofil, ESG-Präferenzen.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:advisor_mate/domain/entities/client_entity.dart';
import 'package:advisor_mate/domain/entities/asset_entity.dart';
import 'package:advisor_mate/domain/entities/enums.dart';
import 'package:advisor_mate/presentation/providers/providers.dart';

/// Detail-Ansicht für einen einzelnen Kunden
class ClientDetailScreen extends ConsumerWidget {
  final String clientId;

  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientByIdProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundendetails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
        ],
      ),
      body: clientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler beim Laden: $error'),
            ],
          ),
        ),
        data: (client) {
          if (client == null) {
            return const Center(child: Text('Kunde nicht gefunden'));
          }
          return _ClientDetailView(client: client);
        },
      ),
    );
  }
}

class _ClientDetailView extends StatelessWidget {
  final Client client;
  final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
  final percentFormat = NumberFormat.percentPattern('de_DE');
  final dateFormat = DateFormat('dd.MM.yyyy');

  _ClientDetailView({required this.client});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Kundeninfo
          _buildClientHeader(context),
          const SizedBox(height: 24),

          // Harte Fakten - Vermögensbilanz
          _buildSection(
            context,
            title: 'Vermögensbilanz',
            icon: Icons.account_balance_wallet,
            child: _buildFinancialBalanceSection(),
          ),
          const SizedBox(height: 16),

          // Harte Fakten - Liquidität
          _buildSection(
            context,
            title: 'Liquidität',
            icon: Icons.trending_up,
            child: _buildLiquiditySection(),
          ),
          const SizedBox(height: 16),

          // Weiche Fakten - Risikoprofil
          _buildSection(
            context,
            title: 'Risikoprofil & Anlageziele',
            icon: Icons.psychology,
            child: _buildRiskProfileSection(context),
          ),
          const SizedBox(height: 16),

          // ESG-Präferenzen
          _buildSection(
            context,
            title: 'ESG-Präferenzen',
            icon: Icons.eco,
            child: _buildEsgSection(context),
          ),
          const SizedBox(height: 16),

          // Asset-Allokation
          _buildSection(
            context,
            title: 'Asset-Allokation',
            icon: Icons.pie_chart,
            child: _buildAssetAllocationSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildClientHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '${client.firstName[0]}${client.lastName[0]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip('${client.age} Jahre'),
                      const SizedBox(width: 8),
                      _buildInfoChip(client.taxStatus.displayName),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialBalanceSection() {
    final balance = client.financialBalance;
    return Column(
      children: [
        _buildKeyValueRow(
          'Gesamtvermögen',
          currencyFormat.format(balance.totalAssets),
          valueColor: Colors.green,
        ),
        _buildKeyValueRow(
          'Verbindlichkeiten',
          currencyFormat.format(balance.totalLiabilities),
          valueColor: Colors.red,
        ),
        const Divider(),
        _buildKeyValueRow(
          'Nettovermögen',
          currencyFormat.format(balance.netWorth),
          valueColor: balance.netWorth >= 0 ? Colors.green : Colors.red,
          isBold: true,
        ),
        const SizedBox(height: 8),
        _buildKeyValueRow(
          'Verschuldungsgrad',
          '${(balance.debtRatio * 100).toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _buildLiquiditySection() {
    final liquidity = client.liquidity;
    return Column(
      children: [
        _buildKeyValueRow(
          'Monatliches Einkommen',
          currencyFormat.format(liquidity.monthlyIncome),
          // ENCRYPTED: Diese Daten sind verschlüsselt gespeichert
        ),
        _buildKeyValueRow(
          'Monatliche Ausgaben',
          currencyFormat.format(liquidity.monthlyExpenses),
        ),
        const Divider(),
        _buildKeyValueRow(
          'Verfügbares Einkommen',
          currencyFormat.format(liquidity.disposableIncome),
          valueColor: liquidity.isLiquid ? Colors.green : Colors.red,
          isBold: true,
        ),
        _buildKeyValueRow(
          'Sparquote',
          '${liquidity.savingsRate.toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  Widget _buildRiskProfileSection(BuildContext context) {
    return Column(
      children: [
        // Risikoprofil Slider-Visualisierung
        Row(
          children: [
            const Text('Risikoprofil:'),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.yellow, Colors.red],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Positioned(
                    left: ((client.riskProfile - 1) / 9) *
                        (MediaQuery.of(context).size.width - 150),
                    child: Container(
                      width: 16,
                      height: 16,
                      transform: Matrix4.translationValues(0, -4, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${client.riskProfile}/10',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildKeyValueRow('Risikotyp', client.riskProfileText),
        const Divider(),
        _buildKeyValueRow(
            'Primäres Anlageziel', client.investmentGoal.displayName),
        _buildKeyValueRow(
          'Anlagehorizont',
          '${client.investmentHorizonYears} Jahre',
        ),
        _buildKeyValueRow(
          'Erfahrungsstufe',
          client.experienceLevel.displayName,
        ),
      ],
    );
  }

  Widget _buildEsgSection(BuildContext context) {
    final esg = client.esgPreferences;

    if (!esg.hasPreference) {
      return const Text(
        'Keine ESG-Präferenzen angegeben',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildEsgBadge(
              'Art. 8',
              esg.prefersArticle8,
              Colors.lightGreen,
            ),
            const SizedBox(width: 12),
            _buildEsgBadge(
              'Art. 9',
              esg.prefersArticle9,
              Colors.green[700]!,
            ),
          ],
        ),
        if (esg.minimumSustainablePercentage != null) ...[
          const SizedBox(height: 12),
          _buildKeyValueRow(
            'Min. nachhaltig',
            '${esg.minimumSustainablePercentage!.toStringAsFixed(0)}%',
          ),
        ],
        if (esg.exclusionCriteria.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Ausschlusskriterien:'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: esg.exclusionCriteria
                .map(
                  (c) => Chip(
                    label: Text(c, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.red[100],
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEsgBadge(String label, bool isActive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetAllocationSection(BuildContext context) {
    final allocation = client.financialBalance.assetAllocationPercent;

    if (allocation.isEmpty) {
      return const Text(
        'Keine Assets vorhanden',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Column(
      children: allocation.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(entry.key.displayName),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: entry.value / 100,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getAssetTypeColor(entry.key),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: Text(
                  '${entry.value.toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getAssetTypeColor(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return Colors.blue;
      case AssetType.stocks:
        return Colors.purple;
      case AssetType.bonds:
        return Colors.teal;
      case AssetType.funds:
        return Colors.orange;
      case AssetType.etf:
        return Colors.indigo;
      case AssetType.realEstate:
        return Colors.brown;
      case AssetType.preciousMetals:
        return Colors.amber;
      case AssetType.crypto:
        return Colors.deepOrange;
      case AssetType.insurance:
        return Colors.cyan;
      case AssetType.other:
        return Colors.grey;
    }
  }

  Widget _buildKeyValueRow(
    String key,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
