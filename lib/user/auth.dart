import 'package:app/model/appUser.dart';
import 'package:app/user/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:user_profile_ii_example/widget/appbar_widget.dart';
// import 'package:user_profile_ii_example/widget/button_widget.dart';
// import 'package:user_profile_ii_example/widget/numbers_widget.dart';

class LoginUtils {
  static Future<bool> checkLoginStatus(BuildContext context) async {
    final Session? session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      // Navigator.pushReplacementNamed(context, '/login');
    }
    return session != null;
  }
}

Future<void> fetchAndSetupProfile() async {
  final Session? session = Supabase.instance.client.auth.currentSession;

  if (session != null) {
    final response =
        await Supabase.instance.client.rpc('get_customer_by_id').single();
    // Assuming response is a list containing a single map
    final customerData = response;
    print(customerData);

    AppUser.setProfileData(
      customerData['customer_id'] as String,
      customerData['first_name'] as String,
      customerData['last_name'] as String,
      customerData['email'] as String,
      customerData['credit'] as double,
    );
  }
}

Future<void> updateCustomer(
    String firstName, String lastName, double credit) async {
  final response =
      await Supabase.instance.client.rpc('update_customer_data', params: {
    'new_first_name': firstName,
    'new_last_name': lastName,
    'new_credit': credit,
  });
  print('edit send ok');
  if (response != null) {
    throw Exception('Error updating customer data: ${response.error!.message}');
  }
}
