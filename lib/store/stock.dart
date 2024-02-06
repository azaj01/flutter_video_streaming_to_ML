import 'dart:io';

// import 'package:app/Camera.dart';
import 'package:flutter/material.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:app/style.dart' as style;
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:app/memory/displayphoto.dart';

// class Stock extends StatefulWidget {
//   const Stock({super.key});

//   @override
//   State<Stock> createState() => _StockState();
// }

// class _StockState extends State<Stock> {
// Widget memoryWidget = const SizedBox.shrink();

// List<Album>? _albums;

// @override
// void initState() {
// super.initState();
// initAsync();
// }

// Future<void> initAsync() async {
// if (await _promptPermissionSetting()) {
// List<Album> albums =
//     await PhotoGallery.listAlbums(mediumType: MediumType.image);
// setState(() {
// print("Album setState");
// _albums = albums;
// Album photo = _albums!.firstWhere((element) => element.name == "AirWareness");
// if (photo.count > 0) {
//   memoryWidget = AlbumPage(key: Key('$photo.count'), album: photo);
// }
// });
// }
// setState(() {});
// }

// Future<bool> _promptPermissionSetting() async {
//   if (Platform.isIOS) {
//     // Request storage and photo permissions on iOS
//     var storageStatus = await Permission.storage.request();
//     var photoStatus = await Permission.photos.request();
//     if (storageStatus.isGranted && photoStatus.isGranted) {
//       return true;
//     }
//   } else if (Platform.isAndroid) {
//     // Request storage permission on Android
//     var storageStatus = await Permission.storage.request();
//     if (storageStatus.isGranted) {
//       return true;
//     }
//   }
//   return false;
// }

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  final _future = Supabase.instance.client.from('category').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Map<String, dynamic>> products = snapshot.data!;

          // Sort the products by the 'index' field
          products.sort((a, b) => a['category_id'].compareTo(b['category_id']));
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // You can adjust the number of columns here
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio:
                  0.75, // You can adjust the aspect ratio as needed
            ),
            itemCount: products.length,
            itemBuilder: ((context, index) {
              final product = products[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.network(
                      product[
                          'image_path'], // Assuming 'image_path' contains the URL of the image
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        color: Colors.black.withOpacity(
                            0.6), // Adjust the opacity/color as needed
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['category_name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              'Remaining: ${product['stock']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
