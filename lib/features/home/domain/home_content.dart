import 'package:flutter/material.dart';

/// Static homepage copy, taken verbatim from the website's SolarHomepage.tsx.
/// Kept in one place so the app and site can be diffed easily.
class HomeContent {
  HomeContent._();

  static const String whatsappNumber = '917607237555';
  static const String whatsappDefaultMessage =
      'Hello Solar Universe Enterprises, I am interested in installing a solar system. '
      'Please share details regarding system cost, subsidy and site survey.';

  static const List<String> phones = ['7607237555', '9999158697'];

  static const List<ServiceItem> services = [
    ServiceItem(Icons.home_rounded, 'Residential Rooftop Solar',
        'Complete rooftop solar solutions for homes.'),
    ServiceItem(Icons.wb_sunny_rounded, 'PM Surya Ghar Solar Installation',
        'Assistance with eligible residential rooftop solar projects under the government scheme.'),
    ServiceItem(Icons.apartment_rounded, 'Commercial Solar',
        'Reduce electricity costs for offices, shops, hospitals, schools and hotels.'),
    ServiceItem(Icons.factory_rounded, 'Industrial Solar',
        'High-capacity solutions for factories, warehouses and industrial facilities.'),
    ServiceItem(Icons.cable_rounded, 'On-Grid Solar Systems',
        'Grid-connected solar with applicable net-metering arrangements.'),
    ServiceItem(Icons.battery_charging_full_rounded, 'Off-Grid Solar Systems',
        'Solar with battery backup for greater energy independence.'),
    ServiceItem(Icons.bolt_rounded, 'Hybrid Solar Systems', 'Solar + grid + battery, working together.'),
    ServiceItem(Icons.solar_power_rounded, 'Solar EPC Projects',
        'Engineering, procurement, installation, testing and commissioning.'),
    ServiceItem(Icons.build_rounded, 'Solar Plant Maintenance',
        'Inspection, preventive maintenance and performance support.'),
    ServiceItem(Icons.eco_rounded, 'Solar Panel Cleaning & AMC',
        'Scheduled cleaning and maintenance solutions.'),
    ServiceItem(Icons.trending_up_rounded, 'Solar System Upgrade',
        'Expand and modernize your existing installation.'),
    ServiceItem(Icons.fact_check_rounded, 'Net Metering Assistance',
        'Documentation support and coordination.'),
    ServiceItem(Icons.payments_rounded, 'Solar Financing Assistance',
        'Guidance on available options through applicable financing partners.'),
    ServiceItem(Icons.location_on_rounded, 'Solar Consultation & Site Survey',
        'Site assessment, consumption analysis and capacity recommendations.'),
  ];

  static const List<ScaleItem> scales = [
    ScaleItem(Icons.home_rounded, 'Home Solar',
        'For residential customers looking to reduce electricity bills and explore government rooftop solar benefits.',
        'Explore Home Solar', Color(0xFFF8FAF4)),
    ScaleItem(Icons.apartment_rounded, 'Commercial Solar',
        'For shops, offices, hospitals, educational institutions, hotels and other businesses.',
        'Explore Commercial Solar', Color(0xFFFFF8F0)),
    ScaleItem(Icons.factory_rounded, 'Industrial Solar',
        'For factories, warehouses, manufacturing units and high-consumption facilities.',
        'Explore Industrial Solar', Color(0xFFF1F5F1)),
  ];

  static const List<String> whyUs = [
    '15+ Years Experience',
    '5000+ kW Project Experience',
    'End-to-End Project Execution',
    'Residential to Large Commercial Projects',
    'Professional Installation Team',
    'Quality-Focused Components',
    'Transparent Consultation',
    'After-Sales Support',
    'Multi-State Service Coverage',
  ];

  static const List<String> aboutChecks = [
    '15+ Years Professional Experience',
    '5000+ kW Solar Project Experience',
    'Residential + Commercial + Industrial Expertise',
    'End-to-End Project Support',
    'Multi-State Service Network',
  ];

  static const List<String> cities = [
    'Lucknow',
    'Mirzapur',
    'Jaunpur',
    'Varanasi',
    'Prayagraj',
    'Ayodhya',
    'Kanpur',
    'Gorakhpur',
    'Sultanpur',
    'Pratapgarh',
    'Azamgarh',
    'Ghazipur',
    'Other cities across UP',
  ];

  static const List<OfficeItem> offices = [
    OfficeItem('Head Office', 'Solar Universe Enterprises',
        '1/60, Vibhav Khand, Gomti Nagar, Lucknow, Uttar Pradesh – 226010'),
    OfficeItem('Branch Office — Mirzapur', null,
        'Lohiya Talab, Vindhyachal Road, Mirzapur, Uttar Pradesh – 231001'),
    OfficeItem('Branch Office — Jaunpur', null,
        'Gaurabadsahpur, Suraila, Jaunpur, Uttar Pradesh – 222133'),
  ];

  static const List<String> projectCategories = ['Residential', 'Commercial', 'Industrial'];

  static const List<String> states = ['Uttar Pradesh', 'Bihar', 'Jharkhand', 'Other'];
  static const List<String> propertyTypes = ['Residential', 'Commercial', 'Industrial'];

  static const String subsidyDisclaimer =
      'For eligible residential grid-connected rooftop solar consumers, subject to applicable '
      'Central/State scheme rules, technical eligibility and current government guidelines. '
      'Subsidy amounts and eligibility may change.';

  static const String pmSuryaGharUrl = 'https://pmsuryaghar.gov.in/';
  static const String centralSourceUrl = 'https://latur.gov.in/en/scheme/pm-surya-ghar-muft-bijli/';
  static const String upPolicyUrl =
      'https://www.upneda.org.in/MediaGallery/Policies/UP_Solar_Energy_Policy2022_English.pdf';
}

class ServiceItem {
  final IconData icon;
  final String title;
  final String text;
  const ServiceItem(this.icon, this.title, this.text);
}

class ScaleItem {
  final IconData icon;
  final String title;
  final String text;
  final String cta;
  final Color background;
  const ScaleItem(this.icon, this.title, this.text, this.cta, this.background);
}

class OfficeItem {
  final String title;
  final String? subtitle;
  final String address;
  const OfficeItem(this.title, this.subtitle, this.address);
}
