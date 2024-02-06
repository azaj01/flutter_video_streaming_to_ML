import 'dart:io';

// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/user_preferences.dart';
// import 'package:app/widget/appbar_widget.dart';
// import 'package:app/widget/button_widget.dart';
import 'package:app/widget/profile_widget.dart';
import 'package:app/widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User user = UserPreferences.myUser;

  @override
  Widget build(BuildContext context) => Container(
        child: Builder(
          builder: (context) => Scaffold(
            body: ListView(
              padding: EdgeInsets.symmetric(horizontal: 32),
              physics: BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  // imagePath: user.imagePath,
                  isEdit: true,
                  onClicked: () async {},
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'first Name',
                  text: user.firstName,
                  onChanged: (name) {},
                ),
                TextFieldWidget(
                  label: 'last Name',
                  text: user.lastName,
                  onChanged: (name) {},
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Email',
                  text: user.email,
                  onChanged: (email) {},
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
}
