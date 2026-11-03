import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../../../../core/session/staff_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../injection.dart';
import '../../data/pdf/quotation_pdf_generator.dart';
import '../../domain/entities/quotation_entity.dart';
import '../../domain/entities/quotation_options.dart';
import '../../domain/repositories/staff_quotations_repository.dart';
import '../bloc/quick_quote_bloc.dart';
import '../bloc/quick_quote_event.dart';
import '../bloc/quick_quote_state.dart';

class QuickQuoteScreen extends StatelessWidget {
  const QuickQuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuickQuoteBloc>()..add(const LoadQuotationsEvent()),
      child: const _QuickQuoteView(),
    );
  }
}

class _QuickQuoteView extends StatefulWidget {
  const _QuickQuoteView();

  @override
  State<_QuickQuoteView> createState() => _QuickQuoteViewState();
}

class _QuickQuoteViewState extends State<_QuickQuoteView> {
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final _projectCostController = TextEditingController(
    text: QuotationOptions.estimatedBaseFor(_capacityKw).round().toString(),
  );
  final _discountController = TextEditingController(text: '0');
  final _panelQtyController = TextEditingController(text: '6');
  final _inverterQtyController = TextEditingController(text: '1');
  final _batteryQtyController = TextEditingController(text: '1');
  final _earthingQtyController = TextEditingController(text: '1');
  final _arrestorQtyController = TextEditingController(text: '1');

  String _systemType = QuotationOptions.systemTypes.first;
  int _capacityKw = 3;
  bool _priceEdited = false;

  String _panelBrand = QuotationOptions.panelCompanies.first;
  String _dcr = QuotationOptions.dcrOptions.first;
  String _panelType = QuotationOptions.panelTypes.first;
  String _inverterBrand = QuotationOptions.inverterBrands.first;
  String _inverterCapacity = QuotationOptions.inverterCapacities.first;
  String _phase = QuotationOptions.phases.first;
  String _structure = QuotationOptions.structures.first;
  String _wire = QuotationOptions.wireBrands.first;
  String _earthing = QuotationOptions.earthingOptions.first;
  String _arrestor = QuotationOptions.lightningArrestorOptions.first;
  String _installation = QuotationOptions.installationOptions.first;

  String _batteryType = QuotationOptions.batteryTypes.first;
  String _batteryBrand = QuotationOptions.batteryBrands.first;
  String _batteryCapacity = QuotationOptions.batteryCapacities.first;

  bool get _showBattery => QuotationOptions.showBatteryFor(_systemType);

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _projectCostController.dispose();
    _discountController.dispose();
    _panelQtyController.dispose();
    _inverterQtyController.dispose();
    _batteryQtyController.dispose();
    _earthingQtyController.dispose();
    _arrestorQtyController.dispose();
    super.dispose();
  }

  num get _price => num.tryParse(_projectCostController.text) ?? 0;
  num get _discount => num.tryParse(_discountController.text) ?? 0;
  num get _gst => (_price * QuotationOptions.gstRate).round();
  num get _finalAmount => _price - _discount;
  num get _subsidy => QuotationOptions.subsidyFor(_capacityKw, _systemType);

  void _applyCapacity(int kw) {
    final capped = kw.clamp(1, 50);
    setState(() {
      _capacityKw = capped;
      if (!_priceEdited) {
        _projectCostController.text = QuotationOptions.estimatedBaseFor(capped).round().toString();
      }
    });
  }

  void _resetPriceToEstimate() {
    setState(() {
      _priceEdited = false;
      _projectCostController.text = QuotationOptions.estimatedBaseFor(_capacityKw).round().toString();
    });
  }

  List<QuotationItemEntity> _buildItems() {
    return [
      QuotationItemEntity(
        item: 'Solar Panels',
        spec: '$_panelBrand · $_panelType · $_dcr',
        qty: _panelQtyController.text.trim().isEmpty ? 'As Per Design' : _panelQtyController.text,
      ),
      QuotationItemEntity(
        item: 'Inverter',
        spec: '$_inverterBrand · $_inverterCapacity · $_phase',
        qty: _inverterQtyController.text,
      ),
      if (_showBattery)
        QuotationItemEntity(
          item: 'Battery',
          spec: '$_batteryBrand · $_batteryType · $_batteryCapacity',
          qty: _batteryQtyController.text,
        ),
      QuotationItemEntity(item: 'Mounting Structure', spec: _structure, qty: 'As Per Design'),
      QuotationItemEntity(item: 'DC / AC Wire', spec: _wire, qty: 'As Per Design'),
      QuotationItemEntity(item: 'Earthing', spec: _earthing, qty: _earthingQtyController.text),
      QuotationItemEntity(
        item: 'Lightning Arrestor',
        spec: _arrestor,
        qty: _arrestorQtyController.text,
      ),
      const QuotationItemEntity(item: 'ACDB / DCDB', spec: 'Havells', qty: 'Pair'),
      QuotationItemEntity(item: 'Installation', spec: _installation, qty: '1 Lot'),
    ];
  }

  String _buildProductsSummary() {
    return 'Solar Panels — $_panelBrand ($_panelQtyController.text nos.), '
        '$_inverterBrand $_inverterCapacity $_phase Inverter, '
        '${_showBattery ? '$_batteryBrand $_batteryType — $_batteryCapacity, ' : ''}'
        '$_structure mounting structure, $_wire DC/AC wire, '
        '$_earthing, $_installation installation';
  }

  NewQuotation _buildQuotation() {
    return NewQuotation(
      customerName: _customerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      solarSystem: '$_systemType Solar System',
      capacity: '${_capacityKw}KW',
      products: _buildProductsSummary(),
      items: _buildItems(),
      price: _price,
      gst: _gst,
      discount: _discount,
      finalAmount: _finalAmount,
    );
  }

  void _save() {
    if (_customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a customer name before saving.')),
      );
      return;
    }
    context.read<QuickQuoteBloc>().add(SaveQuotationEvent(_buildQuotation()));
  }

  Future<void> _printPdf() async {
    if (_customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a customer name before printing.')),
      );
      return;
    }
    final staffName = sl<StaffSession>().current?.name ?? 'Sales Team';
    final quotation = QuotationEntity(
      id: '',
      customerName: _customerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      solarSystem: '$_systemType Solar System',
      capacity: '${_capacityKw}KW',
      products: _buildProductsSummary(),
      items: _buildItems(),
      price: _price,
      gst: _gst,
      discount: _discount,
      finalAmount: _finalAmount,
      quotationNumber: 'DRAFT',
      preparedBy: staffName,
      createdAt: DateTime.now().toIso8601String(),
    );
    final doc = await QuotationPdfGenerator.generate(quotation);
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    final staffName = sl<StaffSession>().current?.name ?? '';
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: BlocConsumer<QuickQuoteBloc, QuickQuoteState>(
        listener: (context, state) {
          if (state.saveStatus == SaveStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Quotation ${state.lastSaved?.quotationNumber} saved.')),
            );
            context.read<QuickQuoteBloc>().add(const ResetQuotationSaveStatusEvent());
          } else if (state.saveStatus == SaveStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.saveError ?? 'Failed to save quotation.')),
            );
          }
        },
        builder: (context, state) {
          final isSaving = state.saveStatus == SaveStatus.saving;
          return ListView(
            children: [
              Text('Quick Quotation', style: AppTypography.headlineLarge),
              Text(
                'Build a solar price proposal in seconds — pick a capacity, review the live '
                'estimate, then save or print the PDF.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Customer Name',
                hint: 'e.g. Ramesh Deshmukh',
                controller: _customerNameController,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Phone (optional)',
                hint: '10-digit mobile',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('SYSTEM TYPE', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: QuotationOptions.systemTypes.map((type) {
                  final selected = _systemType == type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) => setState(() => _systemType = type),
                        selectedColor: AppColors.primary,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: selected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CAPACITY', style: AppTypography.labelMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      '$_capacityKw KW',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (i) => i + 1).map((kw) {
                  final selected = _capacityKw == kw;
                  return ChoiceChip(
                    label: Text('$kw KW'),
                    selected: selected,
                    onSelected: (_) => _applyCapacity(kw),
                    selectedColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              Slider(
                value: _capacityKw.clamp(1, 20).toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                label: '$_capacityKw KW',
                activeColor: AppColors.primary,
                onChanged: (v) => _applyCapacity(v.round()),
              ),
              // Additional capacity dropdown for Hybrid & Off Grid systems —
              // mirrors the web portal, which shows this alongside the quick
              // picks/slider for these two system types specifically.
              if (_systemType == 'Hybrid' || _systemType == 'Off Grid') ...[
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<int>(
                  label: 'Select Capacity (Dropdown)',
                  value: _capacityKw.clamp(1, 10),
                  items: List.generate(10, (i) => i + 1),
                  labelBuilder: (v) => '$v KW',
                  onChanged: (v) => _applyCapacity(v!),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: _priceEdited ? 'Project Cost (₹) · edited' : 'Project Cost (₹)',
                      controller: _projectCostController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _priceEdited = true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Discount (₹)',
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (_priceEdited)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _resetPriceToEstimate,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      child: const Text('reset to estimate', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              Text('COMPONENTS', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'Solar Panel — Company',
                      value: _panelBrand,
                      items: QuotationOptions.panelCompanies,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _panelBrand = v!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'DCR / Non-DCR',
                      value: _dcr,
                      items: QuotationOptions.dcrOptions,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _dcr = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'Panel Type',
                      value: _panelType,
                      items: QuotationOptions.panelTypes,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _panelType = v!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Panel Quantity',
                      hint: 'e.g. 6',
                      controller: _panelQtyController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'Inverter',
                      value: _inverterBrand,
                      items: QuotationOptions.inverterBrands,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _inverterBrand = v!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'Capacity',
                      value: _inverterCapacity,
                      items: QuotationOptions.inverterCapacities,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _inverterCapacity = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'Phase',
                      value: _phase,
                      items: QuotationOptions.phases,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _phase = v!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Qty',
                      controller: _inverterQtyController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppDropdownField<String>(
                label: 'Structure',
                value: _structure,
                items: QuotationOptions.structures,
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() => _structure = v!),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppDropdownField<String>(
                label: 'Wire',
                value: _wire,
                items: QuotationOptions.wireBrands,
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() => _wire = v!),
              ),
              if (_showBattery) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text('BATTERY', style: AppTypography.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdownField<String>(
                        label: 'Battery Type',
                        value: _batteryType,
                        items: QuotationOptions.batteryTypes,
                        labelBuilder: (v) => v,
                        onChanged: (v) => setState(() => _batteryType = v!),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppDropdownField<String>(
                        label: 'Brand',
                        value: _batteryBrand,
                        items: QuotationOptions.batteryBrands,
                        labelBuilder: (v) => v,
                        onChanged: (v) => setState(() => _batteryBrand = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdownField<String>(
                        label: 'Capacity',
                        value: _batteryCapacity,
                        items: QuotationOptions.batteryCapacities,
                        labelBuilder: (v) => v,
                        onChanged: (v) => setState(() => _batteryCapacity = v!),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: 'Qty',
                        controller: _batteryQtyController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'Earthing',
                      value: _earthing,
                      items: QuotationOptions.earthingOptions,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _earthing = v!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Qty',
                      controller: _earthingQtyController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppDropdownField<String>(
                      label: 'Lightning Arrestor',
                      value: _arrestor,
                      items: QuotationOptions.lightningArrestorOptions,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _arrestor = v!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Qty',
                      controller: _arrestorQtyController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppDropdownField<String>(
                label: 'Installation',
                value: _installation,
                items: QuotationOptions.installationOptions,
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() => _installation = v!),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                color: AppColors.secondaryNavy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calculate_rounded, color: AppColors.brandYellow, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Live Estimate',
                          style: AppTypography.titleLarge.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _estimateRow('Project Cost Including GST', _price.currencyFormatted),
                    if (_discount > 0)
                      _estimateRow(
                        'Discount',
                        '- ${_discount.currencyFormatted}',
                        color: Colors.redAccent.shade100,
                      ),
                    _estimateRow('Final Cost (Gross)', _finalAmount.currencyFormatted, bold: true),
                    if (_subsidy > 0)
                      _estimateRow(
                        'Est. Govt. Subsidy',
                        '- ${_subsidy.currencyFormatted}',
                        color: AppColors.brandYellow,
                      ),
                    if (_systemType == 'Off Grid')
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '* Govt. subsidy applies to On Grid & Hybrid systems only.',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white54),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: 'SAVE QUOTATION',
                      icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                      isLoading: isSaving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryButton(
                      label: 'PRINT PDF PROPOSAL',
                      color: Colors.white,
                      icon: const Icon(Icons.print_rounded, size: 18, color: Colors.white),
                      onPressed: _printPdf,
                    ),
                    if (staffName.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Text(
                          'Prepared by $staffName',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white60),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Saved Quotations (${state.quotations.length})', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (state.listStatus == ListStatus.success && state.quotations.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'You haven\'t created any quotations yet. Build one above and hit "Save '
                    'Quotation".',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final q in state.quotations) _SavedQuotationTile(quotation: q),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  Widget _estimateRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: color ?? Colors.white,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedQuotationTile extends StatelessWidget {
  final QuotationEntity quotation;

  const _SavedQuotationTile({required this.quotation});

  Future<void> _print(BuildContext context) async {
    final doc = await QuotationPdfGenerator.generate(quotation);
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quotation.customerName, style: AppTypography.titleMedium),
                Text(
                  '${quotation.solarSystem} · ${quotation.capacity} · '
                  '${quotation.quotationNumber}',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  'Final: ${quotation.finalAmount.currencyFormatted}',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _print(context),
            icon: const Icon(Icons.print_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
