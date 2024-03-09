// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:app/main.dart';
import 'package:app/user/auth.dart';
import 'package:app/user/cart.dart';
import 'package:app/user/history.dart';
import 'package:app/utils/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/model/appUser.dart';
import 'package:app/user/edit_profile.dart';
// import 'package:user_profile_ii_example/widget/appbar_widget.dart';
// import 'package:user_profile_ii_example/widget/button_widget.dart';
// import 'package:user_profile_ii_example/widget/numbers_widget.dart';
import 'package:app/widget/profile_widget.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  Future<void> signOut(BuildContext context) async {
    final response = await Supabase.instance.client.auth.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onTap: () async {
          final currentContext = context;
          final isLoggedIn = await LoginUtils.checkLoginStatus(currentContext);
          if (isLoggedIn) {
            Navigator.push(
              currentContext,
              MaterialPageRoute(builder: (currentContext) => const CartPage()),
            );
          }
        },
        showIcon: Icon(Icons.shopping_bag_rounded),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            onClicked: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
          const SizedBox(height: 24),
          buildName(),
          const Expanded(
            child: History(),
          ),
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }

  Widget buildName() => Column(
        children: [
          Obx(() => Text(
                AppUser.email.value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                    AppUser.first_name.value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  )),
              const SizedBox(width: 10),
              Obx(() => Text(
                    AppUser.last_name.value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
                AppUser.customer_id.value,
                style: TextStyle(color: Colors.grey),
              )),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Credit',
                style: TextStyle(fontSize: 20, height: 1.4),
              ),
              const SizedBox(width: 10),
              Obx(() => Text(
                    AppUser.credit.toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ],
      );
}
