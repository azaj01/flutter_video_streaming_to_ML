import 'dart:io';

// import 'package:app/Camera.dart';
import 'package:app/service/cart.dart';
import 'package:app/service/productService.dart';
import 'package:flutter/material.dart';
// import 'package:photo_gallery/photo_gallery.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:app/style.dart' as style;
import 'package:get/get.dart';
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
  final _future = Supabase.instance.client.from('product').select();
  final productService = ProductService();

  // final cartController = Get.put(CartController());
  final cartController = Get.find<CartController>();
  Future<dynamic> diaLog(BuildContext context, Map<String, dynamic> product) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['product_name']),
          content: ListTile(
            leading: product['image_path'] != null
                ? Image.network(product['image_path'])
                : Image.network(
                    'https://static.vecteezy.com/system/resources/previews/020/662/271/non_2x/store-icon-logo-illustration-vector.jpg'),
            title: Text(product['description']),
            subtitle: Text('${product['product_id']}'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Container productTitle(Map<String, dynamic> product) {
    final product_id = product['product_id'].toString();
    final product_name = product['product_name'].toString();
    return Container(
      padding: const EdgeInsets.all(8.0),
      color:
          Colors.black.withOpacity(0.6), // Adjust the opacity/color as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          TextButton(
            onPressed: () {
              productService.getProductByName(product_name);
            },
            child: Text(
              product_name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              maxLines: null, // Allow the text to wrap to new lines
              overflow:
                  TextOverflow.clip, // Handle overflowing text by clipping it
            ),
          ),
          //   ],
          // ),
          const SizedBox(height: 2.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: ${product['stock'] < 0 ? 0 : product['stock']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
              Text(
                '${product['price']} ฿',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 10)),
                onPressed: () {
                  cartController.addToCart(product, 1);
                },
                child: const Text('add to cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        List<Map<String, dynamic>> products = snapshot.data!;
        final filteredProducts = products
            .where((product) => product['product_name']
                .toString()
                .toLowerCase()
                .contains(searchText))
            .toList();
        filteredProducts
            .sort((a, b) => a['product_id'].compareTo(b['product_id']));

        return Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search by product name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: ((context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          diaLog(context, product);
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              product['image_path'] != null
                                  ? Image.network(
                                      product['image_path'],
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                    )
                                  : Image.network(
                                      'https://static.vecteezy.com/system/resources/previews/020/662/271/non_2x/store-icon-logo-illustration-vector.jpg'),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: productTitle(product),
                              ),
                            ],
                          ),
                        ),
                      );
                    })))
          ],
        );
      },
    );
  }
}
