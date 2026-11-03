import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../domain/entities/contact_message_entity.dart';
import '../bloc/enquiry_bloc.dart';
import '../bloc/enquiry_event.dart';
import '../bloc/enquiry_state.dart';

class ContactMessageForm extends StatelessWidget {
  const ContactMessageForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EnquiryBloc>(),
      child: const _ContactMessageFormBody(),
    );
  }
}

class _ContactMessageFormBody extends StatefulWidget {
  const _ContactMessageFormBody();

  @override
  State<_ContactMessageFormBody> createState() => _ContactMessageFormBodyState();
}

class _ContactMessageFormBodyState extends State<_ContactMessageFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<EnquiryBloc>().add(
          SubmitContactMessageEvent(
            ContactMessageEntity(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              message: _messageController.text.trim(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnquiryBloc, EnquiryState>(
      listener: (context, state) {
        if (state.contactStatus == SubmitStatus.success) {
          _formKey.currentState!.reset();
          _nameController.clear();
          _phoneController.clear();
          _emailController.clear();
          _messageController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.enquirySuccessMessage)),
          );
        } else if (state.contactStatus == SubmitStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.contactError ?? AppStrings.errorUnknown)),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.contactStatus == SubmitStatus.submitting;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Your Name',
                required: true,
                hint: 'Full name',
                controller: _nameController,
                validator: Validators.name,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Phone Number',
                required: true,
                hint: '10-digit mobile',
                controller: _phoneController,
                validator: Validators.mobile,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Email Address',
                hint: 'you@example.com (optional)',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'How can we help you?',
                required: true,
                hint: 'Tell us about your requirement...',
                controller: _messageController,
                maxLines: 4,
                validator: Validators.required,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: AppStrings.contactSubmitLabel,
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
