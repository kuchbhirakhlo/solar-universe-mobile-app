import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../injection.dart';
import '../../../content/presentation/bloc/content_bloc.dart';
import '../../../content/presentation/bloc/content_event.dart';
import '../../../content/presentation/bloc/content_state.dart';
import '../../../enquiry/presentation/widgets/enquiry_form_sheet.dart';
import '../widgets/brands_strip.dart';
import '../widgets/calculator_sections.dart';
import '../widgets/info_sections.dart';
import '../widgets/location_contact_sections.dart';
import '../widgets/projects_section.dart';
import '../widgets/services_sections.dart';
import '../widgets/subsidy_sections.dart';
import '../widgets/top_and_hero.dart';

/// Mobile version of the website homepage (thesolaruniverse.vercel.app):
/// same section order, copy, calculators and lead forms.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _subsidyKey = GlobalKey();
  final _calculatorKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _quote(String source) => showEnquiryFormSheet(context, source: source);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>()
        ..add(const LoadCompanyInfoEvent())
        ..add(const LoadBrandsEvent())
        ..add(const LoadProjectsEvent()),
      child: Scaffold(
        appBar: const AppTopBar(),
        backgroundColor: AppColors.background,
        floatingActionButton: const FloatingWhatsApp(),
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state.companyStatus == LoadStatus.loading ||
                state.companyStatus == LoadStatus.initial) {
              return const Loader();
            }
            if (state.companyStatus == LoadStatus.failure || state.companyInfo == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Text(
                    state.companyError ?? 'Unable to load content. Please check your connection.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final info = state.companyInfo!;
            final capacityKw = (info.capacityInstalledMw * 1000).round();
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ContactTopBar(),
                  HeroSection(
                    badge: info.heroBadge,
                    headline: info.heroHeadline,
                    experienceYears: info.experienceYears,
                    onQuote: () => _quote('home_hero'),
                    onSubsidy: () => _scrollTo(_subsidyKey),
                  ),
                  const CommercialCalculatorSection(),
                  TrustStrip(experienceYears: info.experienceYears, capacityKw: capacityKw),
                  KeyedSubtree(
                    key: _subsidyKey,
                    child: SubsidySection(
                      onFindPotential: () => _scrollTo(_calculatorKey),
                      onEligibility: () => _scrollTo(_contactKey),
                    ),
                  ),
                  AboutSection(
                    experienceYears: info.experienceYears,
                    onTalk: () => _scrollTo(_contactKey),
                  ),
                  BrandsStrip(brands: state.brands),
                  const AwardBand(),
                  ServicesSection(
                    onService: (title) => _quote('home_service: $title'),
                    onDiscuss: () => _scrollTo(_contactKey),
                  ),
                  ScaleSection(onExplore: (title) => _quote('home_scale: $title')),
                  AttaChakkiSection(onDiscuss: () => _quote('home_atta_chakki')),
                  const WhyUsSection(),
                  HomeProjectsSection(
                    projects: state.projects,
                    onDiscuss: () => _scrollTo(_contactKey),
                  ),
                  KeyedSubtree(key: _calculatorKey, child: const ResidentialCalculatorSection()),
                  StateSubsidySection(onAsk: () => _scrollTo(_contactKey)),
                  ServiceAreaSection(onCheck: () => _scrollTo(_contactKey)),
                  const OfficesSection(),
                  KeyedSubtree(key: _contactKey, child: ContactSection(gstin: info.gstn)),
                  HomeFooter(gstin: info.gstn),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
