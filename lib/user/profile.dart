// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:app/main.dart';
import 'package:app/user/auth.dart';
import 'package:app/user/cart.dart';
import 'package:app/utils/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/model/appUser.dart';
import 'package:app/user/edit_profile.dart';
import 'package:app/utils/user_preferences.dart';
// import 'package:user_profile_ii_example/widget/appbar_widget.dart';
// import 'package:user_profile_ii_example/widget/button_widget.dart';
// import 'package:user_profile_ii_example/widget/numbers_widget.dart';
import 'package:app/widget/profile_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // checkLoginStatus();
  }

  // Future<void> checkLoginStatus() async {
  //   await LoginUtils.checkLoginStatus(context);
  // }

  Future<void> signOut() async {
    final response = await Supabase.instance.client.auth.signOut();
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const MainScreen()),
    // );
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    const user = UserPreferences.myUser;

    return Container(
      child: Builder(
        builder: (context) => Scaffold(
            appBar: CustomAppBar(
              onTap: () async {
                final currentContext = context;
                final isLoggedIn =
                    await LoginUtils.checkLoginStatus(currentContext);
                if (isLoggedIn) {
                  Navigator.push(
                    currentContext,
                    MaterialPageRoute(builder: (currentContext) => CartPage()),
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
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                buildName(user),
                const SizedBox(height: 24),
                buildCredit(user),
                IconButton(
                  onPressed: signOut,
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
            floatingActionButton: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                    onPressed: () {
                      final Session? session =
                          Supabase.instance.client.auth.currentSession;
                      print(session);
                    },
                    child: Icon(Icons.deblur),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget buildName(AppUser user) => Column(
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

  Widget buildCredit(AppUser user) => Container(
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
