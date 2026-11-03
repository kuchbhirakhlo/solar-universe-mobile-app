/// Static option lists + pricing/subsidy logic for Quick Quotation — ported
/// directly from the web admin portal's QuickQuotation component so this
/// app's estimator behaves identically (same brand lists, same per-kW
/// pricing formula, same subsidy slabs per system type). There's no
/// Firestore collection backing any of this (the admin's `pricing`
/// collection only holds package-level pricing, not a full component
/// catalog) — it's a straight port of the web component's constants.
class QuotationOptions {
  QuotationOptions._();

  static const List<String> systemTypes = ['On Grid', 'Off Grid', 'Hybrid'];

  // Per-kW component pricing used for the auto-estimated base price.
  static const num panelPerKw = 24000;
  static const num inverterPerKw = 12000;
  static const num structurePerKw = 9000;
  static const num totalPerKw = panelPerKw + inverterPerKw + structurePerKw;

  static num estimatedBaseFor(num capacityKw) => capacityKw * totalPerKw;

  static const List<String> panelCompanies = [
    'Tata Power Solar',
    'Waaree Energies',
    'UTL solar',
    'Eastman',
    'IB solar',
    'Vikram Solar',
    'Adani Solar',
    'Luminous Solar',
    'RenewSys',
  ];
  static const List<String> panelTypes = ['Bifacial', 'TOPCon', 'Mono PERC'];
  static const List<String> dcrOptions = ['DCR', 'Non-DCR'];

  static const List<String> inverterBrands = [
    'Polycab',
    'Vsol',
    'Feston',
    'Growatt',
    'Luminous',
    'Havells',
    'Microtek',
    'Deye',
    'Sungrow',
    'UTL',
    'SuKam',
    'GOODWE',
    'SOLAX',
  ];
  static const List<String> inverterCapacities = [
    '1KW', '2KW', '3KW', '4KW', '5KW', '6KW', '7KW', '8KW', '9KW', '10KW',
  ];
  static const List<String> phases = ['1 Phase', '3 Phase'];

  static const List<String> structures = ['Hot-Dip Galvanized (GI)'];
  static const List<String> wireBrands = ['Polycab', 'Havells', 'Finolex', 'KEI', 'RR Kabel'];
  static const List<String> earthingOptions = [
    'Copper Bonded Earthing Rod with Chemical Bags',
  ];
  static const List<String> lightningArrestorOptions = ['Copper Bonded'];
  static const List<String> installationOptions = [
    'Standard Rooftop',
    'Elevated Tin-Shed',
    'High-Rise / Custom',
  ];

  // Battery — only shown for Off Grid & Hybrid systems.
  static const List<String> batteryTypes = ['Lithium Battery', 'Acid Battery'];
  static const List<String> batteryBrands = [
    'Luminous',
    'Exide',
    'Amaron',
    'Tata Green Batteries',
    'HBL Power',
    'Microtek',
    'Livguard',
    'UTL',
    'SuKam',
    'Voltra',
  ];
  static const List<String> batteryCapacities = [
    '24V/100 AH', '48V/100 AH', '12V/150 AH', '12V/220 AH',
  ];

  static bool showBatteryFor(String systemType) =>
      systemType == 'Off Grid' || systemType == 'Hybrid';

  /// Effective blended GST rate observed across the admin's real quotation
  /// data (gst / price is consistently ~13.8% across sample docs).
  static const double gstRate = 0.138;

  /// Government subsidy slabs, defined per system type — ported from the web
  /// portal's `subsidyFor(capacity, system)`. On Grid: 3-10KW gets the top
  /// slab. Hybrid: only 3-5KW gets the top slab. Off Grid is never eligible.
  static num subsidyFor(num capacityKw, String systemType) {
    if (systemType == 'On Grid') {
      if (capacityKw == 1) return 45000;
      if (capacityKw == 2) return 90000;
      if (capacityKw >= 3 && capacityKw <= 10) return 108000;
      return 0;
    }
    if (systemType == 'Hybrid') {
      if (capacityKw == 1) return 45000;
      if (capacityKw == 2) return 90000;
      if (capacityKw >= 3 && capacityKw <= 5) return 108000;
      return 0;
    }
    return 0; // Off Grid — not eligible
  }

  /// [solarSystem] is the full stored string (e.g. "On Grid Solar System")
  /// — used when reprinting a saved quotation, which only has that string
  /// and a capacity string ("3KW"), not the raw systemType/capacityKw.
  static num subsidyForStored(String solarSystem, String capacity) {
    final systemType = systemTypes.firstWhere(
      (t) => solarSystem.startsWith(t),
      orElse: () => '',
    );
    final capacityKw = num.tryParse(RegExp(r'\d+').stringMatch(capacity) ?? '') ?? 0;
    return subsidyFor(capacityKw, systemType);
  }

  /// Fixed values shown on every printed estimate, matching the reference
  /// "Estimate to Customer" PDF layout from the web portal.
  static const String subsidyScheme = 'PM Surya Ghar Muft Bijli Yojana';
  static const int validityDays = 15;
}
