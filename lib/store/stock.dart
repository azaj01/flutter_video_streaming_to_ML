import 'dart:io';

import 'package:app/service/cartController.dart';
import 'package:app/service/productService.dart';
import 'package:app/service/stockController.dart';
import 'package:flutter/material.dart';

import 'package:app/style.dart' as style;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Stock extends StatefulWidget {
  const Stock({super.key});

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  final productService = ProductService();

  final stockController = Get.find<StockController>();
  final cartController = Get.find<CartController>();
  Future<dynamic> diaLog(BuildContext context, Map<String, dynamic> product) {
    final remaining = product['stock'] < 0 ? 0 : product['stock'];
    int selectedValue = 1;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product['product_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: null,
                    overflow: TextOverflow.clip,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              ),
              content: ListTile(
                leading: product['image_path'] != null
                    ? Image.network(product['image_path'])
                    : Image.network(
                        'https://static.vecteezy.com/system/resources/previews/020/662/271/non_2x/store-icon-logo-illustration-vector.jpg'),
                title: Text(product['description']),
                subtitle: Text('${product['product_id']}'),
              ),
              actions: <Widget>[
                if (remaining > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton<int>(
                        value: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value!;
                          });
                        },
                        items: List.generate(
                          remaining,
                          (index) => DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text((index + 1).toString()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 10)),
                        onPressed: () {
                          cartController.addToCart(product, selectedValue);
                          Navigator.of(context).pop();
                        },
                        child: const Text('add to cart'),
                      ),
                    ],
                  ),
              ],
            );
          },
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
              product['stock'] > 0
                  ? Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: Colors.blue,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          'add to cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Out of Stock'),
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
    return Scaffold(body: Obx(
      () {
        final List<Map<String, dynamic>> filteredProducts = stockController
            .productStock
            .where((product) => product['product_name']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()))
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
    ));
  }
}
