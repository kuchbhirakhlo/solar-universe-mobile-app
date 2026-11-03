import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/home_content.dart';
import '../../domain/solar_calculators.dart';
import 'home_common.dart';
import 'lead_form.dart';

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(color: AppColors.accent, fontSize: 19),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final List<Widget> stats;
  final List<Widget> body;

  const _ResultCard({required this.title, required this.stats, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: homeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge.copyWith(fontSize: 15)),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: stats),
          const SizedBox(height: 14),
          ...body,
        ],
      ),
    );
  }
}

/// Website `#commercial-calculator`: savings estimate for plants running on
/// electricity + diesel (atta chakki, dairy, ice cream, water plants…).
class CommercialCalculatorSection extends StatefulWidget {
  const CommercialCalculatorSection({super.key});

  @override
  State<CommercialCalculatorSection> createState() => _CommercialCalculatorSectionState();
}

class _CommercialCalculatorSectionState extends State<CommercialCalculatorSection> {
  final _formKey = GlobalKey<FormState>();
  final _electricity = TextEditingController();
  final _diesel = TextEditingController();
  CommercialSolarEstimate? _result;

  @override
  void dispose() {
    _electricity.dispose();
    _diesel.dispose();
    super.dispose();
  }

  void _calculate() {
    final e = double.tryParse(_electricity.text.trim()) ?? 0;
    final d = double.tryParse(_diesel.text.trim()) ?? 0;
    final result = estimateCommercialSolar(dailyElectricity: e, dailyDiesel: d);
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your daily electricity and/or diesel cost')),
      );
      return;
    }
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return HomeSection(
      background: AppColorConstants.sectionCalc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('For Commercial & Industrial Plants'),
          const SectionTitle(
            'Solar Savings Calculator for Atta Chakki, Dairy, Ice Cream, Water Plants & Other Plants',
          ),
          const SectionLead(
            'See how much a solar plant saves you compared to running on electricity and diesel.',
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Daily Electricity Cost (₹)',
                  hint: 'e.g. 800',
                  controller: _electricity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Daily Diesel Cost (₹)',
                  hint: 'e.g. 1200',
                  controller: _diesel,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _calculate(),
                ),
                const SizedBox(height: 16),
                HomeButton(
                  label: 'Calculate My Solar Savings',
                  fullWidth: true,
                  onPressed: _calculate,
                ),
              ],
            ),
          ),
          if (r != null) ...[
            const SizedBox(height: 20),
            _ResultCard(
              title: 'Your indicative solar plan',
              stats: [
                _StatTile(value: '${r.capacityKw} kW', label: 'Recommended solar capacity'),
                _StatTile(value: '₹${inr(r.solarCost)}', label: 'One-time solar cost'),
                _StatTile(value: '₹${inr(r.emi)}/mo', label: 'Approx. EMI for 3 years'),
              ],
              body: [
                Text(
                  'You\'re currently spending approximately ₹${inr(r.monthlySpend)}/month on electricity '
                  'and diesel. Once the 3-year financing is paid off, your energy cost drops to ₹0 for '
                  'the remaining 22 years of the system\'s 25-year life — an estimated lifetime saving '
                  'of ₹${inr(r.lifetimeSavings)}.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColorConstants.inkText,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Illustrative estimate based on approximately ₹27,400/kW solar cost and a 3-year '
                  'financing plan comparable to a 19 kW, ₹5,20,000 system with an approximately '
                  '₹18,000/month EMI. Actual system size, cost, financing terms and savings depend on '
                  'site survey, sanctioned load, financier and applicable interest rates. This is not '
                  'a loan offer.',
                  style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 16),
                LeadForm(
                  compact: true,
                  source: 'home_commercial_calc',
                  submitLabel: 'Get Detailed Solar Proposal',
                  contextBuilder: () =>
                      'Commercial Solar Calculator: ₹${inr(r.monthlySpend)}/month current spend; '
                      'recommended ${r.capacityKw} kW system',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Website `#calculator`: residential solar requirement + indicative subsidy.
class ResidentialCalculatorSection extends StatefulWidget {
  const ResidentialCalculatorSection({super.key});

  @override
  State<ResidentialCalculatorSection> createState() => _ResidentialCalculatorSectionState();
}

class _ResidentialCalculatorSectionState extends State<ResidentialCalculatorSection> {
  final _formKey = GlobalKey<FormState>();
  final _bill = TextEditingController();
  final _city = TextEditingController();
  final _roof = TextEditingController();
  String _propertyType = 'Residential';
  String _state = 'Uttar Pradesh';
  ResidentialSolarEstimate? _result;
  double _billValue = 0;

  @override
  void dispose() {
    _bill.dispose();
    _city.dispose();
    _roof.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final bill = double.parse(_bill.text.trim());
    final roof = double.tryParse(_roof.text.trim());
    setState(() {
      _billValue = bill;
      _result = estimateResidentialSolar(
        monthlyBill: bill,
        propertyType: _propertyType,
        state: _state,
        roofAreaSqFt: roof,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return HomeSection(
      background: AppColorConstants.sectionCalc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('A smarter start'),
          const SectionTitle('Calculate Your Solar Requirement'),
          const SectionLead(
            'A few details today. A clearer picture of your solar potential tomorrow.',
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Every roof is different. Our team will refine these estimates with a site survey '
                  'and your electricity bill.',
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Monthly electricity bill (₹)',
                  required: true,
                  controller: _bill,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim());
                    if (n == null || n < 1 || n > 10000000) return 'Enter a bill between ₹1 and ₹1,00,00,000';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppDropdownField<String>(
                  label: 'Property type',
                  value: _propertyType,
                  items: HomeContent.propertyTypes,
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() {
                    _propertyType = v ?? 'Residential';
                    _result = null;
                  }),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'City',
                  required: true,
                  controller: _city,
                  validator: Validators.city,
                ),
                const SizedBox(height: 14),
                AppDropdownField<String>(
                  label: 'State',
                  value: _state,
                  items: HomeContent.states,
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() {
                    _state = v ?? 'Uttar Pradesh';
                    _result = null;
                  }),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Available roof area (sq ft)',
                  controller: _roof,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = double.tryParse(v.trim());
                    if (n == null || n < 100) return 'Minimum 100 sq ft';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                HomeButton(label: 'Calculate Solar Requirement', fullWidth: true, onPressed: _calculate),
              ],
            ),
          ),
          if (r != null) ...[
            const SizedBox(height: 20),
            _ResultCard(
              title: 'Your indicative solar estimate',
              stats: [
                _StatTile(value: '${r.capacityKw} kW', label: 'Recommended capacity'),
                _StatTile(value: '${r.monthlyGenerationKwh} kWh', label: 'Monthly generation'),
                _StatTile(value: '₹${inr(r.monthlySavings)}', label: 'Potential monthly savings'),
              ],
              body: [
                Text(
                  r.isResidential
                      ? 'Potential central assistance: ₹${inr(r.centralSubsidy)}'
                          '${_state == 'Uttar Pradesh' ? ' + potential UP assistance: ₹${inr(r.upSubsidy)}' : ''}'
                          '. Subject to residential on-grid eligibility.'
                      : 'PM Surya Ghar residential subsidy does not apply to commercial or industrial properties.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColorConstants.inkText,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Estimates assume 120 kWh/kW/month, tariff ₹${r.tariff}/kWh and 100 sq ft/kW. Actual '
                  'output and savings depend on shading, orientation, usage, tariff and net metering. '
                  'No savings or subsidy is guaranteed.',
                  style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 16),
                LeadForm(
                  compact: true,
                  source: 'home_residential_calc',
                  submitLabel: 'Get Detailed Solar Proposal',
                  contextBuilder: () =>
                      'Solar Calculator ($_propertyType, $_state): bill ₹${inr(_billValue)}/month; '
                      'recommended ${r.capacityKw} kW system',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

