import 'dart:io';

import 'package:app/service/cartController.dart';
import 'package:app/service/productService.dart';
import 'package:flutter/material.dart';

import 'package:app/style.dart' as style;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final productService = ProductService();
  late final Future<List<Map<String, dynamic>>> _future =
      productService.fetchCheckoutHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height, // Set a finite height
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                String productId = product['product_id'].toString();

                return FutureBuilder(
                  future: productService.getProductById(productId),
                  builder: (context,
                      AsyncSnapshot<Map<String, dynamic>> productSnapshot) {
                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (productSnapshot.hasError) {
                      return Text('Error: ${productSnapshot.error}');
                    } else {
                      final productData = productSnapshot.data!;
                      return Center(
                        child: ListTile(
                            leading: Image.network(productData['image_path']),
                            title: Text('${productData['product_name']}'),
                            subtitle: Text(
                                '${productData['price']} ฿ x Qty: ${product['unit']}'),
                            trailing: Text(
                              'Total: ${product['unit'] * productData['price']}฿',
                            )),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
