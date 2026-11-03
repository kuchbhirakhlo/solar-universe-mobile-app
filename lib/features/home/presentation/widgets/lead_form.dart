import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../injection.dart';
import '../../../enquiry/domain/entities/enquiry_entity.dart';
import '../../../enquiry/presentation/bloc/enquiry_bloc.dart';
import '../../../enquiry/presentation/bloc/enquiry_event.dart';
import '../../../enquiry/presentation/bloc/enquiry_state.dart';
import '../../domain/home_content.dart';
import 'home_common.dart';

/// The website's lead form. [compact] (under the calculators) asks only for
/// name / mobile / city / WhatsApp; the full version (contact section) also
/// asks state, property type, monthly bill, capacity and a message.
/// Submits through the existing enquiry pipeline (`enquiries`, status 'New'),
/// with the extra fields folded into `message` like the website does.
class LeadForm extends StatelessWidget {
  final bool compact;
  final String source;
  final String Function()? contextBuilder;
  final String submitLabel;

  const LeadForm({
    super.key,
    this.compact = false,
    required this.source,
    this.contextBuilder,
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EnquiryBloc>(),
      child: _LeadFormBody(
        compact: compact,
        source: source,
        contextBuilder: contextBuilder,
        submitLabel: submitLabel,
      ),
    );
  }
}

class _LeadFormBody extends StatefulWidget {
  final bool compact;
  final String source;
  final String Function()? contextBuilder;
  final String submitLabel;

  const _LeadFormBody({
    required this.compact,
    required this.source,
    required this.contextBuilder,
    required this.submitLabel,
  });

  @override
  State<_LeadFormBody> createState() => _LeadFormBodyState();
}

class _LeadFormBodyState extends State<_LeadFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _city = TextEditingController();
  final _whatsapp = TextEditingController();
  final _bill = TextEditingController();
  final _capacity = TextEditingController();
  final _message = TextEditingController();
  String _state = '';
  String _propertyType = 'Residential';
  bool _sent = false;

  @override
  void dispose() {
    for (final c in [_name, _mobile, _city, _whatsapp, _bill, _capacity, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _optionalMobile(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return Validators.mobile(v);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final capacity = _capacity.text.trim();
    context.read<EnquiryBloc>().add(
          SubmitEnquiryEvent(
            EnquiryEntity(
              name: _name.text.trim(),
              mobile: _mobile.text.trim(),
              city: _city.text.trim(),
              systemType: widget.compact ? 'Residential' : _propertyType,
              capacity: capacity.isEmpty ? 'Site assessment requested' : '$capacity kW',
              message: _message.text.trim(),
              source: widget.source,
              whatsapp: _whatsapp.text.trim(),
              state: _state,
              monthlyBill: _bill.text.trim(),
              context: widget.contextBuilder?.call() ??
                  (widget.compact ? 'Homepage enquiry' : 'Homepage contact form'),
            ),
          ),
        );
  }

  void _clear() {
    for (final c in [_name, _mobile, _city, _whatsapp, _bill, _capacity, _message]) {
      c.clear();
    }
    _formKey.currentState?.reset();
    setState(() {
      _state = '';
      _propertyType = 'Residential';
      _sent = true;
    });
  }

  List<TextInputFormatter> get _digits10 =>
      [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnquiryBloc, EnquiryState>(
      listener: (context, state) {
        if (state.enquiryStatus == SubmitStatus.success) _clear();
        if (state.enquiryStatus == SubmitStatus.submitting && _sent) {
          setState(() => _sent = false);
        }
      },
      builder: (context, state) {
        final sending = state.enquiryStatus == SubmitStatus.submitting;
        final failed = state.enquiryStatus == SubmitStatus.failure;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Full name',
                required: true,
                controller: _name,
                maxLength: 100,
                validator: (v) => Validators.required(v, 'Full name'),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Mobile number',
                required: true,
                hint: '10-digit mobile number',
                controller: _mobile,
                keyboardType: TextInputType.phone,
                inputFormatters: _digits10,
                validator: Validators.mobile,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'City',
                required: true,
                controller: _city,
                validator: Validators.city,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'WhatsApp number',
                hint: 'If different from mobile',
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                inputFormatters: _digits10,
                validator: _optionalMobile,
                textInputAction: widget.compact ? TextInputAction.done : TextInputAction.next,
              ),
              if (!widget.compact) ...[
                const SizedBox(height: 14),
                AppDropdownField<String>(
                  label: 'State *',
                  value: _state,
                  items: ['', ...HomeContent.states],
                  labelBuilder: (v) => v.isEmpty ? 'Select state' : v,
                  onChanged: (v) => setState(() => _state = v ?? ''),
                ),
                const SizedBox(height: 14),
                AppDropdownField<String>(
                  label: 'Property type',
                  value: _propertyType,
                  items: HomeContent.propertyTypes,
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() => _propertyType = v ?? 'Residential'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Average monthly electricity bill (₹)',
                  controller: _bill,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Required solar capacity (kW)',
                  hint: 'If known',
                  controller: _capacity,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Message',
                  hint: 'Tell us about your property and solar needs',
                  controller: _message,
                  maxLines: 3,
                  maxLength: 2000,
                  textInputAction: TextInputAction.done,
                ),
              ],
              const SizedBox(height: 18),
              HomeButton(
                label: sending ? 'Sending enquiry…' : widget.submitLabel,
                loading: sending,
                fullWidth: true,
                onPressed: () {
                  if (!widget.compact && _state.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select your state')),
                    );
                    return;
                  }
                  _submit();
                },
              ),
              if (_sent && state.enquiryStatus == SubmitStatus.success) ...[
                const SizedBox(height: 12),
                Text(
                  'Thank you. Your enquiry has been received. Our solar team will contact you.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                ),
              ],
              if (failed) ...[
                const SizedBox(height: 12),
                Text(
                  'Your enquiry could not be sent. Please try again, call us or contact us on WhatsApp.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                ),
                HomeTextLink(
                  label: 'Send your enquiry on WhatsApp',
                  onTap: () => LauncherHelper.whatsapp(
                    HomeContent.whatsappNumber,
                    HomeContent.whatsappDefaultMessage,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'By submitting, you agree to be contacted about your enquiry.',
                style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
