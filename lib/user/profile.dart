// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/model/user.dart';
import 'package:app/user/edit_profile.dart';
import 'package:app/utils/user_preferences.dart';
// import 'package:user_profile_ii_example/widget/appbar_widget.dart';
// import 'package:user_profile_ii_example/widget/button_widget.dart';
// import 'package:user_profile_ii_example/widget/numbers_widget.dart';
import 'package:app/widget/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.myUser;

    return Container(
      child: Builder(
        builder: (context) => Scaffold(
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
              buildName(user),
              const SizedBox(height: 24),
              buildCredit(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            user.userId,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            user.firstName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            user.lastName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildCredit(User user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.credit.toString(),
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}
