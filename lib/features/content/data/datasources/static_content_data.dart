import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/solution_entity.dart';

/// Company/about copy and the on-grid/off-grid/hybrid solution descriptions
/// have no backing Firestore collection — the admin's Firestore only holds
/// CRM + marketing-listing data (brands, pricing, projects, faq, enquiries).
/// This static copy mirrors the real reference site, https://thesolaruniverse.vercel.app/,
/// and can move to Firestore later without changing any UI code.
///
/// Everything below was scraped directly from that site's own homepage copy
/// and footer (company name, address, phone numbers, email, GSTIN, "15+
/// years" / "5000+ kW" stats, the 3 states served). The previous version of
/// this file held "Solar Win Technologies" content copied from a different
/// app in this workspace during an earlier clone — never actually matching
/// Solar Universe Enterprises' own branding. That mismatch is now fixed.
///
/// `teamProjectsCompleted`/`teamMembers`/`teamSatisfactionPercent`/`ceoQuote`/
/// `ceoBio` (used only by `about_screen.dart`, not the homepage) are still
/// generic placeholders — the live site publishes no team-size, project-count
/// or satisfaction figures, and it's a proprietorship with no published
/// founder name. Left as-is since About screen content is out of scope for
/// the homepage redesign this comment describes; revisit if that screen is
/// ever redesigned too.
class StaticContentData {
  StaticContentData._();

  static const CompanyInfoEntity companyInfo = CompanyInfoEntity(
    heroBadge: 'A Brighter Future Starts On Your Rooftop',
    heroHeadline: 'Powering Homes & Businesses with Smarter Solar Energy',
    aboutShort:
        'An experienced solar EPC company in Lucknow, Solar Universe Enterprises brings '
        'practical expertise and personal attention to every stage of your solar journey. We '
        'design and deliver end-to-end solutions for homes, businesses and industrial '
        'facilities. From your first site assessment to commissioning and ongoing support, our '
        'focus is a system that fits your property and energy needs.',
    missionText:
        'Our solar services cover your entire project lifecycle — consultation and site survey, '
        'system design, EPC installation, net metering assistance and after-sales '
        'maintenance — with professional support at every step, for residential, commercial and '
        'industrial rooftops alike.',
    visionText:
        'A brighter future starts on your rooftop. We want every home and business across Uttar '
        'Pradesh, Bihar and Jharkhand to generate its own clean, reliable solar energy — backed '
        'by a solar partner they can reach long after installation.',
    regOfficeAddress: '1/60, Vibhav Khand, Gomti Nagar, Lucknow, Uttar Pradesh – 226010',
    contactNumbers: ['7607237555', '9999158697'],
    email: 'asarvindshl1@gmail.com',
    website: 'https://thesolaruniverse.vercel.app',
    gstn: '09DZZPS4372G1ZD',
    vendorCode: '',
    businessHours: 'Mon–Sat: 9:00 AM – 6:00 PM',
    experienceYears: 15,
    statesServed: 3,
    capacityInstalledMw: 5.0,
    // No CEO/founder name is published on the live site (it's a
    // proprietorship) — these fields aren't rendered anywhere in the current
    // UI (verified in about_screen.dart), so generic non-personal copy is
    // used here rather than inventing a person's name.
    ceoName: 'Solar Universe Enterprises',
    ceoQuote: 'A brighter future starts on your rooftop.',
    ceoBio:
        'A solar EPC company serving Uttar Pradesh, Bihar and Jharkhand with 15+ years of '
        'professional solar experience and 5,000+ kW of solar project experience.',
    teamExperienceYears: 15,
    teamProjectsCompleted: 500,
    teamMembers: 15,
    teamSatisfactionPercent: 100,
    branchOffices: [
      BranchOfficeEntity(
        name: 'Head Office — Gomti Nagar, Lucknow',
        address: '1/60, Vibhav Khand, Gomti Nagar, Lucknow, Uttar Pradesh – 226010',
      ),
      BranchOfficeEntity(
        name: 'Branch Office — Mirzapur',
        address: 'Lohiya Talab, Vindhyachal Road, Mirzapur, Uttar Pradesh – 231001',
      ),
      BranchOfficeEntity(
        name: 'Branch Office — Jaunpur',
        address: 'Gaurabadsahpur, Suraila, Jaunpur, Uttar Pradesh – 222133',
      ),
    ],
  );

  static const List<SolutionEntity> solutions = [
    SolutionEntity(
      id: 'on_grid',
      type: 'on_grid',
      title: 'On Grid Solar System',
      description:
          'Connect directly with your state electricity grid to feed excess solar power back '
          'via net-metering. Ideal for maximum monthly bill reductions with minimal system cost.',
      benefits: [
        'Eliminate up to 90% of electricity bills',
        'Direct export of excess power (Net Metering)',
        'Eligible for maximum government subsidy support',
        'Extremely low maintenance & longest lifespan',
      ],
      order: 1,
    ),
    SolutionEntity(
      id: 'hybrid',
      type: 'hybrid',
      title: 'Hybrid Solar System',
      description:
          'The ultimate system: Solar + Battery + Grid. Delivers maximum tariff-savings by '
          'optimizing power usage, while maintaining a smart battery bank for full blackouts.',
      benefits: [
        'Utility saving + emergency backup simultaneously',
        'Smart load-shedding battery bank allocation',
        'Automatically switch between Solar, Battery, & Grid',
        'App-controlled remote configuration',
      ],
      order: 2,
    ),
    SolutionEntity(
      id: 'off_grid',
      type: 'off_grid',
      title: 'Off Grid Solar System',
      description:
          'Operate 100% independently from the utility grid. Charges dynamic battery banks '
          'during daytime to supply reliable power throughout nights and cloudy spells.',
      benefits: [
        'Complete energy independence (No utility dependency)',
        'Continuous battery backup for full blackouts',
        'Excellent for remote areas, farms, and off-grid resorts',
        'Protects expensive sensitive equipment from spikes',
      ],
      order: 3,
    ),
  ];
}
