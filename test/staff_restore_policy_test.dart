import 'package:flutter_test/flutter_test.dart';
import 'package:solaruniverse/features/staff_auth/domain/staff_restore_policy.dart';

void main() {
  const domain = 'staff.solaruniverse.app';

  test('a staff synthetic email is a staff session', () {
    expect(isStaffAuthUser('tsu-sm-0001@staff.solaruniverse.app', domain), isTrue);
    expect(isStaffAuthUser('TSU-EN-0001@Staff.SolarUniverse.app', domain), isTrue);
  });

  test('a phone-OTP customer (no email) is never treated as staff', () {
    expect(isStaffAuthUser(null, domain), isFalse);
    expect(isStaffAuthUser('', domain), isFalse);
  });

  test('other email addresses are not staff', () {
    expect(isStaffAuthUser('someone@gmail.com', domain), isFalse);
    expect(isStaffAuthUser('x@evil-staff.solaruniverse.app.example.com', domain), isFalse);
  });
}
