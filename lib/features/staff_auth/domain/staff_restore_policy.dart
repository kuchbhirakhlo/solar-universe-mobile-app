/// FirebaseAuth.instance is shared between staff (email + password on a
/// synthetic `<employeeId>@<domain>` address) and customers (phone OTP), so a
/// restored `currentUser` is only a staff session if it carries that address.
/// Anything else (e.g. a phone-auth customer) must be left completely alone —
/// in particular never signed out.
bool isStaffAuthUser(String? email, String staffEmailDomain) {
  if (email == null) return false;
  return email.trim().toLowerCase().endsWith('@${staffEmailDomain.toLowerCase()}');
}
