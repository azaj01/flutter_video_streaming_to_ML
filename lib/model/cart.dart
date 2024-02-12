import 'package:get/get.dart';

class CartItem {
  final String productName;
  final String productId;
  final int quantity;

  CartItem(this.productName, {required this.productId, required this.quantity});
}

class CartController extends GetxController {
  final _cartItems = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get cartItems => _cartItems.toList();

  void addToCart(Map<String, dynamic> product, int quantity) {
    print(product['product_id']);
    print(product['product_id'].runtimeType);
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

  void clearCart() {
    _cartItems.clear();
  }
}
