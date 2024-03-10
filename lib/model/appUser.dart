import 'package:get/get.dart';

class AppUser extends GetxController {
  static var customer_id = 'H'.obs;
  static var first_name = 'Login'.obs;
  static var last_name = 'H'.obs;
  static var email = 'H'.obs;
  static var credit = 0.0.obs;

  static void setProfileData(
      String id, String fname, String lname, String mail, double cdit) {
    customer_id.value = id;
    first_name.value = fname;
    last_name.value = lname;
    email.value = mail;
    credit.value = cdit;
  }
}
