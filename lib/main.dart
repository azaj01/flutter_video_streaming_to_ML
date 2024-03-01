import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app/camera/camera.dart';
import 'package:app/store/stock.dart';
import 'package:app/style.dart' as style;
import 'package:app/user/auth.dart';
import 'package:app/user/cart.dart';
import 'package:app/user/login.dart';
import 'package:app/user/profile.dart';
import 'package:app/user/sign_up.dart';
import 'package:app/utils/appbar.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'model/cart.dart';
import 'package:badges/badges.dart' as badges;

List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final List<CameraDescription> cameras = await availableCameras();
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
  // Initialize Supabase client
  final supabaseClient = SupabaseClient(
    'YOUR_SUPABASE_URL',
    'YOUR_SUPABASE_KEY',
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Login Demo',
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
  // late Timer _everyHour;
  // ForecastData _forecastData = ForecastData();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _forecastUpdate() async {
    setState(() {
      // _forecastData = ForecastData(created: _forecastData.created);
    });

    // var newForecastData = await ForecastData.init(
    //     Userposition.latitudeChosen, Userposition.longitudeChosen);
    setState(() {
      // _forecastData = newForecastData;
    });
  }

  Future<void> _initData() async {
    try {
      // await fetchAndSetUserLocation();

      _forecastUpdate();
      // _everyHour = Timer.periodic(const Duration(hours: 1), (Timer t) {
      // _forecastUpdate();
      // });
    } catch (_) {
      // TODO: do something if can't fetch gps location
    }
  }

  @override
  void initState() {
    super.initState();
    _initData().whenComplete(() => null);
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      // print(event.event);
      if (event.event == AuthChangeEvent.signedIn) {
        print('are login');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ProfilePage()),
        // );
      } else if (event.event == AuthChangeEvent.signedOut) {
        print('signedOut redirect');

        // Navigator.pushNamedAndRemoveUntil(
        //     context, '/home', (Route<dynamic> route) => false);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginPage()),
        // );
      } else {
        print(event.event);
      }
    });
  }

  final cartController = Get.put(CartController());
  // final cartController = Get.put<CartController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // (size themselves to avoid the onscreen keyboard)
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        onTap:
            // Handle onTap event here
            () async {
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
          // ProfilePage()
          // Forecast(onRefresh: _forecastUpdate, data: _forecastData)
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
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.shopping_bag_rounded),
            //     label: 'Cart',
            //     backgroundColor: style.greyUI)
            BottomNavigationBarItem(
              // Use the Badge widget to display a badge on the shopping bag icon
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
