import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:solaruniverse/core/routing/route_names.dart';
import 'package:solaruniverse/core/session/customer_session.dart';
import 'package:solaruniverse/core/session/staff_session.dart';
import 'package:solaruniverse/core/widgets/app_shell.dart';
import 'package:solaruniverse/core/widgets/staff_shell.dart';
import 'package:solaruniverse/features/about/presentation/screens/about_screen.dart';
import 'package:solaruniverse/features/contact/presentation/screens/contact_screen.dart';
import 'package:solaruniverse/features/customer_auth/presentation/screens/customer_login_screen.dart';
import 'package:solaruniverse/features/customer_auth/presentation/screens/customer_otp_screen.dart';
import 'package:solaruniverse/features/customer_auth/presentation/screens/customer_profile_setup_screen.dart';
import 'package:solaruniverse/features/customer_dashboard/presentation/screens/customer_dashboard_screen.dart';
import 'package:solaruniverse/features/customer_service_requests/presentation/screens/create_service_request_screen.dart';
import 'package:solaruniverse/features/faq/presentation/screens/faq_screen.dart';
import 'package:solaruniverse/features/home/presentation/screens/home_screen.dart';
import 'package:solaruniverse/features/more/presentation/screens/more_screen.dart';
import 'package:solaruniverse/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:solaruniverse/features/pricing/presentation/screens/pricing_screen.dart';
import 'package:solaruniverse/features/projects/presentation/screens/projects_screen.dart';
import 'package:solaruniverse/features/solutions/presentation/screens/solutions_screen.dart';
import 'package:solaruniverse/features/customer_service_requests/domain/entities/service_request_entity.dart';
import 'package:solaruniverse/features/splash/presentation/screens/splash_screen.dart';
import 'package:solaruniverse/features/staff_auth/presentation/screens/staff_login_screen.dart';
import 'package:solaruniverse/features/staff_customers/presentation/screens/create_customer_screen.dart';
import 'package:solaruniverse/features/staff_customers/presentation/screens/staff_customers_screen.dart';
import 'package:solaruniverse/features/staff_dashboard/presentation/screens/staff_dashboard_screen.dart';
import 'package:solaruniverse/features/staff_enquiries/domain/entities/staff_enquiry_entity.dart';
import 'package:solaruniverse/features/staff_enquiries/presentation/screens/create_enquiry_screen.dart';
import 'package:solaruniverse/features/staff_enquiries/presentation/screens/enquiry_detail_screen.dart';
import 'package:solaruniverse/features/staff_enquiries/presentation/screens/staff_enquiries_screen.dart';
import 'package:solaruniverse/features/staff_quotations/presentation/screens/quick_quote_screen.dart';
import 'package:solaruniverse/features/staff_service_requests/presentation/screens/service_request_detail_screen.dart';
import 'package:solaruniverse/features/staff_service_requests/presentation/screens/staff_service_requests_screen.dart';

GoRouter buildAppRouter(StaffSession staffSession, CustomerSession customerSession) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: Listenable.merge([staffSession, customerSession]),
    redirect: (context, state) {
      final path = state.uri.path;

      // ─── Staff portal ─────────────────────────────────────────────────
      final isStaffArea = path.startsWith('/staff') && path != RouteNames.staffLogin;
      if (isStaffArea && !staffSession.isSignedIn) return RouteNames.staffLogin;

      // Engineers get a single self-contained screen (their assigned
      // service requests), not the Sales staff dashboard/enquiries/quick
      // quote/customers area — redirect away from all of those.
      final isEngineer = staffSession.current?.isEngineer ?? false;
      final isSalesOnlyArea = path == RouteNames.staffDashboard ||
          path.startsWith(RouteNames.staffEnquiries) ||
          path.startsWith(RouteNames.staffQuickQuote) ||
          path.startsWith(RouteNames.staffCustomers);
      if (isEngineer && isSalesOnlyArea) return RouteNames.staffServiceRequests;

      if (path == RouteNames.staffLogin && staffSession.isSignedIn) {
        return isEngineer ? RouteNames.staffServiceRequests : RouteNames.staffDashboard;
      }

      // ─── Customer portal ──────────────────────────────────────────────
      // Two independent gates, not one boolean like staff — phone
      // verification and profile creation are separate steps here (see
      // CustomerSession's doc comment).
      final isCustomerAuthRoute =
          path == RouteNames.customerLogin || path == RouteNames.customerOtp;
      final isCustomerProfileSetup = path == RouteNames.customerProfileSetup;
      final isCustomerArea = path.startsWith('/customer');

      if (isCustomerArea && !isCustomerAuthRoute) {
        if (!customerSession.isVerified) return RouteNames.customerLogin;
        if (!customerSession.hasProfile && !isCustomerProfileSetup) {
          return RouteNames.customerProfileSetup;
        }
      }
      if (isCustomerAuthRoute && customerSession.isVerified) {
        return customerSession.hasProfile
            ? RouteNames.customerDashboard
            : RouteNames.customerProfileSetup;
      }
      if (isCustomerProfileSetup && customerSession.hasProfile) {
        return RouteNames.customerDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.pricing,
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RouteNames.faq,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: RouteNames.contact,
        builder: (context, state) => const ContactScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.solutions,
            builder: (context, state) => const SolutionsScreen(),
          ),
          GoRoute(
            path: RouteNames.projects,
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: RouteNames.more,
            builder: (context, state) => const MoreScreen(),
          ),
        ],
      ),

      // ─── Customer portal ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.customerLogin,
        builder: (context, state) => const CustomerLoginScreen(),
      ),
      GoRoute(
        path: RouteNames.customerOtp,
        builder: (context, state) => const CustomerOtpScreen(),
      ),
      GoRoute(
        path: RouteNames.customerProfileSetup,
        builder: (context, state) => const CustomerProfileSetupScreen(),
      ),
      GoRoute(
        path: RouteNames.customerDashboard,
        builder: (context, state) => const CustomerDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.customerServiceRequestNew,
        builder: (context, state) => const CreateServiceRequestScreen(),
      ),

      // ─── Staff portal ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.staffLogin,
        builder: (context, state) => const StaffLoginScreen(),
      ),
      // Engineer-only, top-level (not inside the Sales staffShell below) —
      // see the isEngineer redirect above.
      GoRoute(
        path: RouteNames.staffServiceRequests,
        builder: (context, state) => const StaffServiceRequestsScreen(),
      ),
      GoRoute(
        path: RouteNames.staffServiceRequestDetail,
        builder: (context, state) =>
            ServiceRequestDetailScreen(request: state.extra as ServiceRequestEntity),
      ),
      GoRoute(
        path: RouteNames.staffEnquiriesNew,
        builder: (context, state) => const CreateEnquiryScreen(),
      ),
      GoRoute(
        path: RouteNames.staffEnquiryDetail,
        builder: (context, state) =>
            EnquiryDetailScreen(enquiry: state.extra as StaffEnquiryEntity),
      ),
      GoRoute(
        path: RouteNames.staffCustomersNew,
        builder: (context, state) => const CreateCustomerScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _staffShellFor(state.uri.path, child),
        routes: [
          GoRoute(
            path: RouteNames.staffDashboard,
            builder: (context, state) => const StaffDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.staffEnquiries,
            builder: (context, state) => const StaffEnquiriesScreen(),
          ),
          GoRoute(
            path: RouteNames.staffQuickQuote,
            builder: (context, state) => const QuickQuoteScreen(),
          ),
          GoRoute(
            path: RouteNames.staffCustomers,
            builder: (context, state) => const StaffCustomersScreen(),
          ),
        ],
      ),
    ],
  );
}

StaffShell _staffShellFor(String path, Widget child) {
  String title = 'Sales Overview';
  if (path.startsWith(RouteNames.staffEnquiries)) title = 'Enquiries';
  if (path.startsWith(RouteNames.staffQuickQuote)) title = 'Quick Quotation';
  if (path.startsWith(RouteNames.staffCustomers)) title = 'Solar Customers';
  return StaffShell(title: title, child: child);
}
