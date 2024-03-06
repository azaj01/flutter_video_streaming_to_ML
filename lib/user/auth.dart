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
