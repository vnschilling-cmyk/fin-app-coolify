/// AdvisorMate - Portfolio Card Widget
/// 
/// Karte für die Darstellung eines Kundenportfolios im Dashboard.

library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_mate/domain/entities/client_entity.dart';
import 'package:advisor_mate/domain/entities/enums.dart';

/// Kompakte Portfolio-Übersichtskarte
class PortfolioCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;
  final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');

  PortfolioCard({
    super.key,
    required this.client,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final balance = client.financialBalance;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header mit Name und ESG-Badge
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${client.firstName[0]}${client.lastName[0]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          client.investmentGoal.displayName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (client.hasEsgPreferences)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'ESG',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),
              
              // Nettovermögen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nettovermögen'),
                  Text(
                    currencyFormat.format(balance.netWorth),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: balance.netWorth >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Asset Allocation Mini-Bar
              _buildAssetAllocationBar(balance.assetAllocationPercent),
              const SizedBox(height: 12),

              // Risk & Experience
              Row(
                children: [
                  _buildTag(
                    'Risiko ${client.riskProfile}/10',
                    _getRiskColor(client.riskProfile),
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    client.experienceLevel.displayName,
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetAllocationBar(Map<AssetType, double> allocation) {
    if (allocation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: allocation.entries.map((entry) {
          return Expanded(
            flex: (entry.value * 10).round(),
            child: Container(
              color: _getAssetTypeColor(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getRiskColor(int riskProfile) {
    if (riskProfile <= 3) return Colors.green;
    if (riskProfile <= 6) return Colors.orange;
    return Colors.red;
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
}
