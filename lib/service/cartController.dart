import 'dart:convert';

import 'package:app/service/stockController.dart';
import 'package:app/user/auth.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  final _cartItems = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get cartItems => _cartItems.toList();

  double get sumTotal {
    double total = 0;
    for (var item in cartItems) {
      total += item['product']['price'] * item['quantity'];
    }
    return total;
  }

  void addToCart(Map<String, dynamic> product, int quantity) {
    // print(product['product_id']);
    // print(product['product_id'].runtimeType);
    int index = _cartItems.indexWhere(
        (item) => item['product']['product_id'] == product['product_id']);

    if (index != -1) {
      _cartItems[index]['quantity'] += quantity;
      _cartItems.refresh();
    } else {
      _cartItems.add({'product': product, 'quantity': quantity});
    }
  }

  void removeFromCart(int productId) {
    // print(productId);
    int index = _cartItems
        .indexWhere((item) => item['product']['product_id'] == productId);
    // print(index);
    // print(_cartItems);
    if (index != -1 && _cartItems[index]['quantity'] > 1) {
      _cartItems[index]['quantity'] -= 1;
      _cartItems.refresh();
    } else {
      _cartItems
          .removeWhere((item) => item['product']['product_id'] == productId);
    }
  }

  // void checkOutFromCart() {
  //   // Prepare data for Supabase API
  //   Map<String, dynamic> requestData = {
  //     "customer_id": 121354365363,
  //     "products": _cartItems.map((item) => item['product']).toList(),
  //   };

  //   // Convert data to JSON
  //   String jsonData = jsonEncode(requestData);

  //   // Send data to Supabase API
  //   // Replace this with your actual code to send data to the Supabase API
  //   print(jsonData); // Just printing for demonstration
  // }
  void checkOutFromCart() async {
    // Prepare data
    List<Map<String, dynamic>> products = _cartItems.map((item) {
      return {
        'product_id': item['product']['product_id'],
        'unit': item['quantity'],
        'total_amount': item['product']['price'] * item['quantity'],
      };
    }).toList();
    // print(products);
    // Call the RPC function on Supabase backend
    final response = await Supabase.instance.client.rpc('checkout', params: {
      // 'payment_id': '94f9ddc7-5a6c-4b48-adf2-86a33bb138a3',
      'products_jsonb': products
    });
    // print(response.);
    if (response != null) {
      print('Error: $response');
    } else {
      print('Checkout successful!');
      Get.find<StockController>().refreshProduct();
      clearCart();
      fetchAndSetupProfile();
    }
  }

  void clearCart() {
    _cartItems.clear();
  }
}
