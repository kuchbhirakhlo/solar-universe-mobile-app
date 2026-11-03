class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static const String home = '/home';
  static const String solutions = '/solutions';
  static const String pricing = '/pricing';
  static const String projects = '/projects';
  static const String more = '/more';

  static const String about = '/about';
  static const String faq = '/faq';
  static const String contact = '/contact';

  // ─── Staff portal ─────────────────────────────────────────────────────────
  static const String staffLogin = '/staff/login';
  static const String staffDashboard = '/staff/dashboard';
  static const String staffEnquiries = '/staff/enquiries';
  static const String staffEnquiriesNew = '/staff/enquiries/new';
  static const String staffEnquiryDetail = '/staff/enquiries/detail';
  static const String staffQuickQuote = '/staff/quick-quote';
  static const String staffCustomers = '/staff/customers';
  static const String staffCustomersNew = '/staff/customers/new';
  // Engineer-only — top-level (not inside the Sales staffShell), see
  // app_router.dart's isEngineer redirect.
  static const String staffServiceRequests = '/staff/service-requests';
  static const String staffServiceRequestDetail = '/staff/service-requests/detail';

  // ─── Customer portal ────────────────────────────────────────────────────────
  static const String customerLogin = '/customer/login';
  static const String customerOtp = '/customer/otp';
  static const String customerProfileSetup = '/customer/profile-setup';
  static const String customerDashboard = '/customer/dashboard';
  static const String customerServiceRequestNew = '/customer/service-requests/new';
}
