/// AdvisorMate - Market Data Widget
/// 
/// Widget für die Anzeige von Marktdaten und Indizes.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:advisor_mate/data/services/market_data_service.dart';
import 'package:advisor_mate/presentation/providers/providers.dart';

/// Widget für Market Index Anzeige
class MarketDataWidget extends ConsumerWidget {
  const MarketDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(marketIndicesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Marktübersicht',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => ref.invalidate(marketIndicesProvider),
                  tooltip: 'Aktualisieren',
                ),
              ],
            ),
            const Divider(),
            indicesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        'Marktdaten nicht verfügbar',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              data: (indices) => Column(
                children: indices
                    .map((index) => _MarketIndexRow(index: index))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketIndexRow extends StatelessWidget {
  final MarketIndex index;
  final numberFormat = NumberFormat('#,##0.00', 'de_DE');

  _MarketIndexRow({required this.index});

  @override
  Widget build(BuildContext context) {
    final isPositive = index.isPositive;
    final color = isPositive ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  index.symbol,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              numberFormat.format(index.value),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 2),
                Text(
                  '${isPositive ? '+' : ''}${index.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakte Inline-Anzeige für einen einzelnen Index
class MarketIndexTicker extends ConsumerWidget {
  final String symbol;

  const MarketIndexTicker({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(marketIndicesProvider);

    return indicesAsync.when(
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error_outline, size: 16),
      data: (indices) {
        final index = indices.where((i) => i.symbol == symbol).firstOrNull;
        if (index == null) return const Text('-');

        final color = index.isPositive ? Colors.green : Colors.red;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              index.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(
              index.isPositive ? Icons.trending_up : Icons.trending_down,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${index.changePercent.toStringAsFixed(2)}%',
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        );
      },
    );
  }
}
