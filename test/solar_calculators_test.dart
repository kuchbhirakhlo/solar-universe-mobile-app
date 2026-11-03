import 'package:flutter_test/flutter_test.dart';
import 'package:solaruniverse/features/home/domain/solar_calculators.dart';

void main() {
  group('estimateCommercialSolar', () {
    test('website reference system: Rs400 electricity + Rs600 diesel per day = 19 kW, Rs5,20,000', () {
      final e = estimateCommercialSolar(dailyElectricity: 400, dailyDiesel: 600)!;
      expect(e.capacityKw, 19);
      expect(e.solarCost, 520000);
      expect(e.emi, 18000);
      expect(e.monthlySpend, 30000);
      expect(e.lifetimeSavings, 30000 * 12 * 25 - 18000 * 12 * 3);
    });

    test('returns null when there is nothing to estimate', () {
      expect(estimateCommercialSolar(dailyElectricity: 0, dailyDiesel: 0), isNull);
    });

    test('never recommends less than 1 kW', () {
      final e = estimateCommercialSolar(dailyElectricity: 10, dailyDiesel: 0)!;
      expect(e.capacityKw, 1);
    });
  });

  group('estimateResidentialSolar', () {
    test('Rs3500 bill, residential, UP: 5 kW with central + UP subsidy', () {
      final e = estimateResidentialSolar(
        monthlyBill: 3500,
        propertyType: 'Residential',
        state: 'Uttar Pradesh',
      );
      expect(e.capacityKw, 5);
      expect(e.monthlyGenerationKwh, 600);
      expect(e.monthlySavings, 3500);
      expect(e.centralSubsidy, 2 * 30000 + 18000);
      expect(e.upSubsidy, 30000);
    });

    test('roof area caps the capacity', () {
      final e = estimateResidentialSolar(
        monthlyBill: 3500,
        propertyType: 'Residential',
        state: 'Bihar',
        roofAreaSqFt: 250,
      );
      expect(e.capacityKw, 2);
      expect(e.centralSubsidy, 60000);
      expect(e.upSubsidy, 0);
    });

    test('commercial property gets no residential subsidy and uses the Rs9 tariff', () {
      final e = estimateResidentialSolar(
        monthlyBill: 9000,
        propertyType: 'Commercial',
        state: 'Uttar Pradesh',
      );
      expect(e.tariff, 9);
      expect(e.centralSubsidy, 0);
      expect(e.upSubsidy, 0);
    });
  });
}
