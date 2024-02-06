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

    // debugPrint(result.toJson().toString());
    if (response.user != null) {
      await client.from('customer').insert({
        'customer_id': response.user!.id,
        'first_name': 'user',
        'email': response.user!.email,
        'birth_date': null,
        'last_name': 'test',
        'join_at': response.user!.createdAt,
        'credit_user': 0
      });
    }
    // if (result != null) {
    // showToastMessage('Registration Success', isError: false);
    // Navigator.pushReplacementNamed(context, 'login');
    // showToastMessage('Success', isError: false);
    // } else if (result.error?.message != null) {
    // showToastMessage('Error:${result.error!.message.toString()}',
    //       // isError: true);
    // }
  }

  Future<void> signInUser(context, {String? email, String? password}) async {
    debugPrint("email:$email password:$password");
    final response = await client.auth
        .signInWithPassword(email: email, password: password ?? '');
    // debugPrint(result.data!.toJson().toString());
    // print(response);

    // client.auth.onAuthStateChange.listen((event) => {
    //       print(event.)

    // if (event.event.name == 'signedIn')
    //   {
    //     print('a')
    //     // Perform actions after user signs in
    //   }
    // else if (event.event.name == 'SIGNED_OUT')
    //   {
    //     print('b')
    //     // Perform actions after user signs out
    //   }
    // });
    // if (result.data != null) {
    //   showToastMessage('Login Success', isError: false);
    //   Navigator.pushReplacementNamed(context, '/home');
    //   showToastMessage('Success', isError: false);
    // } else if (result.error?.message != null) {
    //   showToastMessage('Error:${result.error!.message.toString()}',
    //       isError: true);
    // }
  }

  Future<void> logout(context) async {
    await client.auth.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }
}
