import 'dart:io';

// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:app/user/auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:app/model/appUser.dart';
// import 'package:app/widget/appbar_widget.dart';
// import 'package:app/widget/button_widget.dart';
import 'package:app/widget/profile_widget.dart';
import 'package:app/widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String newFirstName = '';
  String newLastName = '';
  double newCredit = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendChangesToSupabase(BuildContext context) async {
    final firstName =
        newFirstName.isNotEmpty ? newFirstName : AppUser.first_name.value;
    final lastName =
        newLastName.isNotEmpty ? newLastName : AppUser.last_name.value;
    final credit = newCredit != 0 ? newCredit : AppUser.credit.value;

    if (firstName != AppUser.first_name.value ||
        lastName != AppUser.last_name.value ||
        credit != AppUser.credit.value) {
      await updateCustomer(firstName, lastName, credit);
      await fetchAndSetupProfile();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'First Name',
              text: AppUser.first_name.value,
              onChanged: (name) {
                newFirstName = name;
              },
            ),
            TextFieldWidget(
              label: 'Last Name',
              text: AppUser.last_name.value,
              onChanged: (name) {
                newLastName = name;
              },
            ),
            const SizedBox(height: 40),
            TextFieldWidget(
              label: 'Topup Credit',
              text: AppUser.credit.toString(),
              onChanged: (credit) {
                newCredit = double.parse(credit);
              },
            ),
            ElevatedButton(
              onPressed: () {
                sendChangesToSupabase(context);
              },
              child: const Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
