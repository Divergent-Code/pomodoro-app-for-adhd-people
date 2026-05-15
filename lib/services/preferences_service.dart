
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String partnerPhoneNumberKey = 'partner_phone_number';
  static const String partnerCarrierKey = 'partner_carrier';
  static const String userEmailKey = 'user_email';
  static const String userPasswordKey = 'user_password';

  Future<void> setPartnerPhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(partnerPhoneNumberKey, phoneNumber);
  }

  Future<String?> getPartnerPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(partnerPhoneNumberKey);
  }

  Future<void> setPartnerCarrier(String carrier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(partnerCarrierKey, carrier);
  }

  Future<String?> getPartnerCarrier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(partnerCarrierKey);
  }

  Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<void> setUserPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userPasswordKey, password);
  }

  Future<String?> getUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPasswordKey);
  }
}
