import 'dart:math' as math;

/// Same formulas as the website's SolarHomepage.tsx (`estimateCommercialSolar`
/// / `estimateSolar`) — kept identical so the app and site never disagree.

class CommercialSolarEstimate {
  final int capacityKw;
  final int solarCost;
  final int emi;
  final int monthlySpend;
  final int lifetimeSavings;

  const CommercialSolarEstimate({
    required this.capacityKw,
    required this.solarCost,
    required this.emi,
    required this.monthlySpend,
    required this.lifetimeSavings,
  });
}

/// Returns null when both daily costs are empty/zero (nothing to estimate).
CommercialSolarEstimate? estimateCommercialSolar({
  required double dailyElectricity,
  required double dailyDiesel,
}) {
  final elec = math.max(0, dailyElectricity);
  final diesel = math.max(0, dailyDiesel);
  if (elec + diesel <= 0) return null;

  final capacity = math.max(1, (19 * (elec / 800 + diesel / 1200)).round());
  final solarCost = ((capacity * (520000 / 19)) / 1000).round() * 1000;
  final emi = ((solarCost * (18000 / 520000)) / 100).round() * 100;
  final monthlySpend = ((elec + diesel) * 30).round();
  final lifetime = math.max(0, (monthlySpend * 12 * 25 - emi * 12 * 3).round());
  return CommercialSolarEstimate(
    capacityKw: capacity,
    solarCost: solarCost,
    emi: emi,
    monthlySpend: monthlySpend,
    lifetimeSavings: lifetime,
  );
}

class ResidentialSolarEstimate {
  final int capacityKw;
  final int monthlyGenerationKwh;
  final int monthlySavings;
  final int centralSubsidy;
  final int upSubsidy;
  final int tariff;
  final bool isResidential;

  const ResidentialSolarEstimate({
    required this.capacityKw,
    required this.monthlyGenerationKwh,
    required this.monthlySavings,
    required this.centralSubsidy,
    required this.upSubsidy,
    required this.tariff,
    required this.isResidential,
  });
}

ResidentialSolarEstimate estimateResidentialSolar({
  required double monthlyBill,
  required String propertyType,
  required String state,
  double? roofAreaSqFt,
}) {
  final isResidential = propertyType == 'Residential';
  final tariff = isResidential ? 7 : 9;
  final desired = math.max(1, (monthlyBill / tariff / 120).ceil());
  final capacity = (roofAreaSqFt != null && roofAreaSqFt > 0)
      ? math.min(desired, (roofAreaSqFt / 100).floor())
      : desired;
  final generation = capacity * 120;
  final savings = math.min(monthlyBill, (generation * tariff).toDouble()).round();
  final central = isResidential
      ? math.min(capacity, 2) * 30000 + (capacity >= 3 ? 18000 : 0)
      : 0;
  final up = isResidential && state == 'Uttar Pradesh' ? math.min(capacity, 2) * 15000 : 0;
  return ResidentialSolarEstimate(
    capacityKw: capacity,
    monthlyGenerationKwh: generation,
    monthlySavings: savings,
    centralSubsidy: central,
    upSubsidy: up,
    tariff: tariff,
    isResidential: isResidential,
  );
}
