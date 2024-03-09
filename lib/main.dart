import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app/camera/camera.dart';
import 'package:app/model/appUser.dart';
import 'package:app/service/stockController.dart';
import 'package:app/store/stock.dart';
import 'package:app/style.dart' as style;
import 'package:app/user/auth.dart';
import 'package:app/user/cart.dart';
import 'package:app/user/login.dart';
import 'package:app/user/profile.dart';
import 'package:app/user/sign_up.dart';
import 'package:app/utils/appbar.dart';
import 'package:app/user/auth.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'service/cartController.dart';
import 'package:badges/badges.dart' as badges;

List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wwqspguoizevnbocschg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3cXNwZ3VvaXpldm5ib2NzY2hnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDE2NzI4MDEsImV4cCI6MjAxNzI0ODgwMX0.rwr6AyxkfyaE_7dgUbdYWrTiTob1K0aQvMubNX7-k08',
  );
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(MaterialApp(
        theme: ThemeData.light(),
        home: MyApp(),
        debugShowCheckedModeBanner: true,
      )));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cap_Snap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/profile': (context) => ProfilePage(),
        '/home': (context) => MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        print('are login');
      } else if (event.event == AuthChangeEvent.signedOut) {
        print('signedOut redirect');
        AppUser.setProfileData('', '', '', '', 0.0);
      } else {
        print(event.event);
      }
    });
    _initData();
  }

  Future<void> _initData() async {
    try {
      await fetchAndSetupProfile();
    } catch (_) {}
  }

  final cartController = Get.put(CartController());
  final stockController = Get.put(StockController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        onTap: () async {
          if (await LoginUtils.checkLoginStatus(context)) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
        },
        showIcon: Icon(Icons.person),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CameraScreen(
            cameras: cameras,
          ),
          // const Stock(),
          const Stock(),
          const CartPage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: style.greyUI,
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                label: 'Camera',
                backgroundColor: style.greyUI),
            const BottomNavigationBarItem(
                icon: Icon(Icons.filter_drama),
                label: 'Stock',
                backgroundColor: style.greyUI),
            BottomNavigationBarItem(
              icon: badges.Badge(
                badgeContent: Obx(
                  () => // Obx to reactively update the badge
                      Text(
                    '${cartController.cartItems.length}', // Display the number of items in the cart
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                child: Icon(Icons.shopping_bag_rounded),
              ),
              label: 'Cart',
            ),
          ],
          selectedItemColor: Colors.black,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
