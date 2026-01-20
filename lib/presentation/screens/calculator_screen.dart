/// AdvisorMate - Calculator Screen
/// 
/// Finanzrechner für Zinseszins und Rentenlücke.

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:advisor_mate/data/services/financial_calculator.dart';
import 'package:advisor_mate/presentation/providers/providers.dart';

/// Finanzrechner-Bildschirm
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzrechner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Zinseszins', icon: Icon(Icons.trending_up)),
            Tab(text: 'Rentenlücke', icon: Icon(Icons.elderly)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CompoundInterestCalculator(),
          _RetirementGapCalculator(),
        ],
      ),
    );
  }
}

/// Zinseszins-Rechner
class _CompoundInterestCalculator extends ConsumerStatefulWidget {
  const _CompoundInterestCalculator();

  @override
  ConsumerState<_CompoundInterestCalculator> createState() =>
      _CompoundInterestCalculatorState();
}

class _CompoundInterestCalculatorState
    extends ConsumerState<_CompoundInterestCalculator> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController(text: '5');
  final _yearsController = TextEditingController(text: '10');
  final _monthlyController = TextEditingController(text: '0');

  final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
  double? _result;

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _calculate() {
    final calculator = ref.read(financialCalculatorProvider);
    
    final principal = double.tryParse(_principalController.text.replaceAll(',', '.')) ?? 0;
    final rate = (double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0) / 100;
    final years = int.tryParse(_yearsController.text) ?? 0;
    final monthly = double.tryParse(_monthlyController.text.replaceAll(',', '.')) ?? 0;

    if (principal <= 0 && monthly <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Anfangskapital oder Sparrate eingeben')),
      );
      return;
    }

    setState(() {
      _result = calculator.calculateCompoundInterestWithContributions(
        principal: principal,
        monthlyContribution: monthly,
        annualRate: rate,
        years: years,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _principalController,
                    label: 'Anfangskapital (€)',
                    icon: Icons.account_balance_wallet,
                    suffix: '€',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _monthlyController,
                    label: 'Monatliche Sparrate (€)',
                    icon: Icons.savings,
                    suffix: '€',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _rateController,
                    label: 'Jährliche Rendite (%)',
                    icon: Icons.percent,
                    suffix: '%',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _yearsController,
                    label: 'Anlagedauer (Jahre)',
                    icon: Icons.calendar_today,
                    suffix: 'Jahre',
                    isInteger: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Berechnen'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final principal = double.tryParse(_principalController.text.replaceAll(',', '.')) ?? 0;
    final monthly = double.tryParse(_monthlyController.text.replaceAll(',', '.')) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;
    
    final totalContributions = principal + (monthly * years * 12);
    final interest = _result! - totalContributions;

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.celebration, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              'Endkapital nach Anlagedauer:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(_result),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResultItem(
                  'Einzahlungen',
                  currencyFormat.format(totalContributions),
                  Colors.blue,
                ),
                _buildResultItem(
                  'Zinserträge',
                  currencyFormat.format(interest),
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
    bool isInteger = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          isInteger ? RegExp(r'[0-9]') : RegExp(r'[0-9,.]'),
        ),
      ],
    );
  }
}

/// Rentenlücken-Rechner
class _RetirementGapCalculator extends ConsumerStatefulWidget {
  const _RetirementGapCalculator();

  @override
  ConsumerState<_RetirementGapCalculator> createState() =>
      _RetirementGapCalculatorState();
}

class _RetirementGapCalculatorState
    extends ConsumerState<_RetirementGapCalculator> {
  final _desiredIncomeController = TextEditingController(text: '3000');
  final _expectedPensionController = TextEditingController(text: '1500');
  final _yearsUntilRetirementController = TextEditingController(text: '20');
  final _retirementDurationController = TextEditingController(text: '25');
  final _inflationController = TextEditingController(text: '2');

  final currencyFormat = NumberFormat.currency(locale: 'de_DE', symbol: '€');
  double? _neededCapital;
  double? _monthlyGap;

  @override
  void dispose() {
    _desiredIncomeController.dispose();
    _expectedPensionController.dispose();
    _yearsUntilRetirementController.dispose();
    _retirementDurationController.dispose();
    _inflationController.dispose();
    super.dispose();
  }

  void _calculate() {
    final calculator = ref.read(financialCalculatorProvider);

    final desiredIncome = double.tryParse(
            _desiredIncomeController.text.replaceAll(',', '.')) ?? 0;
    final expectedPension = double.tryParse(
            _expectedPensionController.text.replaceAll(',', '.')) ?? 0;
    final yearsUntilRetirement =
        int.tryParse(_yearsUntilRetirementController.text) ?? 0;
    final retirementDuration =
        int.tryParse(_retirementDurationController.text) ?? 0;
    final inflation = (double.tryParse(
                _inflationController.text.replaceAll(',', '.')) ?? 2) / 100;

    setState(() {
      _neededCapital = calculator.calculateRetirementGap(
        desiredMonthlyIncome: desiredIncome,
        expectedPension: expectedPension,
        yearsUntilRetirement: yearsUntilRetirement,
        retirementDurationYears: retirementDuration,
        inflationRate: inflation,
      );
      
      // Berechne die monatliche Lücke (heute)
      _monthlyGap = desiredIncome - expectedPension;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _desiredIncomeController,
                    decoration: const InputDecoration(
                      labelText: 'Gewünschtes Ruhestandseinkommen (€/Monat)',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _expectedPensionController,
                    decoration: const InputDecoration(
                      labelText: 'Erwartete Rente (€/Monat)',
                      prefixIcon: Icon(Icons.elderly),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _yearsUntilRetirementController,
                    decoration: const InputDecoration(
                      labelText: 'Jahre bis zur Rente',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _retirementDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Geplante Rentendauer (Jahre)',
                      prefixIcon: Icon(Icons.hourglass_bottom),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _inflationController,
                    decoration: const InputDecoration(
                      labelText: 'Angenommene Inflation (%)',
                      prefixIcon: Icon(Icons.trending_up),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Rentenlücke berechnen'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          if (_neededCapital != null) ...[
            const SizedBox(height: 24),
            _buildRetirementResultCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildRetirementResultCard() {
    return Card(
      color: _monthlyGap! > 0 ? Colors.orange[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _monthlyGap! > 0 ? Icons.warning_amber : Icons.check_circle,
              size: 48,
              color: _monthlyGap! > 0 ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 12),
            Text(
              _monthlyGap! > 0
                  ? 'Monatliche Lücke (heute):'
                  : 'Keine Rentenlücke!',
              style: const TextStyle(fontSize: 16),
            ),
            if (_monthlyGap! > 0) ...[
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(_monthlyGap),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const Divider(height: 32),
              const Text(
                'Benötigtes Kapital bei Renteneintritt:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(_neededCapital),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '(inflationsbereinigt)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
