import 'package:app/model/appUser.dart';
import 'package:app/user/auth.dart';
import 'package:app/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:app/supabase.dart';
// import 'package:supabase_authentication/core/toast.dart';

const String supabaseUrl = "your supabase url goes here ";
const String token = "your supabase token goes here";

class SupabaseManager {
  final client = Supabase.instance.client;

  Future<void> signUpUser(context, {String? email, String? password}) async {
    debugPrint("email:$email password:$password");
    final response =
        await client.auth.signUp(email: email ?? '', password: password ?? '');
    await fetchAndSetupProfile();
    Navigator.pushReplacementNamed(
      context,
      '/profile',
    );
  }

  Future<void> signInUser(context, {String? email, String? password}) async {
    debugPrint("email:$email password:$password");
    final response = await client.auth
        .signInWithPassword(email: email, password: password ?? '');
    await fetchAndSetupProfile();
    Navigator.pushReplacementNamed(
      context,
      '/profile',
    );
  }
}
