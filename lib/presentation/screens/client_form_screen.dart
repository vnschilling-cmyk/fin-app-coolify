/// AdvisorMate - KYC Form Screen
///
/// Multi-Step Formular zur Erfassung von KYC-Daten neuer Kunden.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:advisor_mate/domain/entities/client_entity.dart';
import 'package:advisor_mate/domain/entities/asset_entity.dart';
import 'package:advisor_mate/domain/entities/enums.dart';
import 'package:advisor_mate/presentation/providers/providers.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final Client? initialClient;

  const ClientFormScreen({super.key, this.initialClient});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers - Basisdaten
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime _dateOfBirth = DateTime(1980, 1, 1);

  // Hard Facts - Financials
  final _incomeController = TextEditingController(text: '0');
  final _expensesController = TextEditingController(text: '0');
  final _assetsController = TextEditingController(text: '0');
  final _liabilitiesController = TextEditingController(text: '0');

  // Soft Facts
  int _riskProfile = 5;
  InvestmentGoal _goal = InvestmentGoal.wealthBuilding;
  ExperienceLevel _experience = ExperienceLevel.basic;
  int _horizon = 10;

  // ESG
  bool _prefersArt8 = false;
  bool _prefersArt9 = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialClient != null) {
      final c = widget.initialClient!;
      _firstNameController.text = c.firstName;
      _lastNameController.text = c.lastName;
      _emailController.text = c.email;
      _dateOfBirth = c.dateOfBirth;
      _incomeController.text = c.liquidity.monthlyIncome.toString();
      _expensesController.text = c.liquidity.monthlyExpenses.toString();
      _assetsController.text = c.financialBalance.totalAssets.toString();
      _liabilitiesController.text =
          c.financialBalance.totalLiabilities.toString();
      _riskProfile = c.riskProfile;
      _goal = c.investmentGoal;
      _experience = c.experienceLevel;
      _horizon = c.investmentHorizonYears;
      _prefersArt8 = c.esgPreferences.prefersArticle8;
      _prefersArt9 = c.esgPreferences.prefersArticle9;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _incomeController.dispose();
    _expensesController.dispose();
    _assetsController.dispose();
    _liabilitiesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newClient = Client(
      id: widget.initialClient?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      dateOfBirth: _dateOfBirth,
      financialBalance: FinancialBalance(
        assets: [
          Asset(
              id: '1',
              name: 'Gesamtvermögen',
              type: AssetType.cash,
              value: double.parse(_assetsController.text))
        ],
        liabilities: [
          Liability(
              id: '1',
              name: 'Verbindlichkeiten',
              type: LiabilityType.other,
              amount: double.parse(_liabilitiesController.text),
              interestRate: 0)
        ],
      ),
      liquidity: Liquidity(
        monthlyIncome: double.parse(_incomeController.text),
        monthlyExpenses: double.parse(_expensesController.text),
      ),
      taxStatus: TaxStatus.residentTaxable,
      riskProfile: _riskProfile,
      investmentGoal: _goal,
      experienceLevel: _experience,
      investmentHorizonYears: _horizon,
      esgPreferences: EsgPreferences(
        prefersArticle8: _prefersArt8,
        prefersArticle9: _prefersArt9,
      ),
      createdAt: widget.initialClient?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save via Provider
    await ref.read(clientsNotifierProvider.notifier).addClient(newClient);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kunde erfolgreich gespeichert (verschlüsselt)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialClient == null
            ? 'Neuer Kunde (KYC)'
            : 'KYC bearbeiten'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            Step(
              title: const Text('Basis'),
              isActive: _currentStep >= 0,
              content: _buildBasisStep(),
            ),
            Step(
              title: const Text('Finanzen'),
              isActive: _currentStep >= 1,
              content: _buildFinanceStep(),
            ),
            Step(
              title: const Text('Risiko'),
              isActive: _currentStep >= 2,
              content: _buildRiskStep(),
            ),
            Step(
              title: const Text('ESG'),
              isActive: _currentStep >= 3,
              content: _buildEsgStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasisStep() {
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          decoration: const InputDecoration(labelText: 'Vorname'),
          validator: (v) => v!.isEmpty ? 'Erforderlich' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(labelText: 'Nachname'),
          validator: (v) => v!.isEmpty ? 'Erforderlich' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'E-Mail'),
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v!.isEmpty ? 'Erforderlich' : null,
        ),
      ],
    );
  }

  Widget _buildFinanceStep() {
    return Column(
      children: [
        _buildNumericField(_incomeController, 'Monatliches Einkommen (€)'),
        const SizedBox(height: 16),
        _buildNumericField(_expensesController, 'Monatliche Ausgaben (€)'),
        const SizedBox(height: 16),
        _buildNumericField(_assetsController, 'Gesamtvermögen (€)'),
        const SizedBox(height: 16),
        _buildNumericField(_liabilitiesController, 'Verbindlichkeiten (€)'),
      ],
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: '€'),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildRiskStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Risikoprofil (1-10)'),
        Slider(
          value: _riskProfile.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: _riskProfile.toString(),
          onChanged: (v) => setState(() => _riskProfile = v.round()),
        ),
        const SizedBox(height: 16),
        const Text('Anlageziel'),
        DropdownButtonFormField<InvestmentGoal>(
          initialValue: _goal,
          items: InvestmentGoal.values
              .map(
                  (g) => DropdownMenuItem(value: g, child: Text(g.displayName)))
              .toList(),
          onChanged: (v) => setState(() => _goal = v!),
        ),
        const SizedBox(height: 16),
        const Text('Erfahrungshorizont'),
        DropdownButtonFormField<ExperienceLevel>(
          initialValue: _experience,
          items: ExperienceLevel.values
              .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e.displayName)))
              .toList(),
          onChanged: (v) => setState(() => _experience = v!),
        ),
      ],
    );
  }

  Widget _buildEsgStep() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Präferenz für Art. 8 Produkte'),
          subtitle: const Text('Fördert ökologische/soziale Merkmale'),
          value: _prefersArt8,
          onChanged: (v) => setState(() => _prefersArt8 = v),
        ),
        SwitchListTile(
          title: const Text('Präferenz für Art. 9 Produkte'),
          subtitle: const Text('Nachhaltiges Investitionsziel (Impact)'),
          value: _prefersArt9,
          onChanged: (v) => setState(() => _prefersArt9 = v),
        ),
      ],
    );
  }
}
