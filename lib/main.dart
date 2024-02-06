import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app/camera/camera.dart';
import 'package:app/store/stock.dart';
import 'package:app/style.dart' as style;
import 'package:app/user/profile.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // runApp(MyApp(cameras: cameras));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(MaterialApp(
        theme: ThemeData.dark(),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      )));
}

// class MyApp extends StatelessWidget {
//   const MyApp({required this.cameras, Key? key}) : super(key: key);
//   final List<CameraDescription> cameras;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CameraScreen(cameras: cameras),
//     );
//   }
// }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // (size themselves to avoid the onscreen keyboard)
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CapSnap',
              textScaleFactor: 1.2,
            ),

            //make it clikable to set location
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );

                      // final chosenLocation = await Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) =>
                      //           const Selectlocation(predefinedLocation: []),
                      //     ));
                      // print(chosenLocation);
                      // if (chosenLocation != null) {
                      //   setState(() {
                      //     print("data");
                      //     Userposition.setChosenLocation(
                      //         chosenLocation.lat.toString(),
                      //         chosenLocation.lon.toString(),
                      //         chosenLocation.name);
                      //     print(Userposition.display_place_Chosen);
                      //     _forecastUpdate();
                      //   });
                      // }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.person),
                        Flexible(
                            child: Text(
                          // Userposition.display_place_Chosen,
                          'User',
                          textScaleFactor: 0.7,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ))
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // CameraScreen(
          //   cameras: cameras,
          // ),
          const Stock(),
          const Stock()
          // Forecast(onRefresh: _forecastUpdate, data: _forecastData)
        ],
      ),
      bottomNavigationBar: Container(
        color: style.greyUI,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                label: 'Camera',
                backgroundColor: style.greyUI),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_drama),
                label: 'Stock',
                backgroundColor: style.greyUI)
          ],
          selectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
