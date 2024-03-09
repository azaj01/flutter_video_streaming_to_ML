import 'package:app/service/cartController.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/CustomTextStyle.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:shopping_cart/utils/CustomUtils.dart';

// import 'CheckOutPage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

String getFormattedCurrency(double amount) {
  String symbol = "฿";
  int groupFromRight = 3;

  // Convert the amount to a string
  String amountString = amount.toString();

  // Insert commas for thousands separator
  for (int i = amountString.length - groupFromRight;
      i > 0;
      i -= groupFromRight) {
    amountString =
        '${amountString.substring(0, i)},${amountString.substring(i)}';
  }

  // Append the currency symbol at the end
  String output = '$amountString $symbol';
  return output;
}

class _CartPageState extends State<CartPage> {
  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cart'),
            IconButton(
              onPressed: () {
                cartController.clearCart();
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
      ),
      body: Obx(() => ListView.builder(
            itemCount: cartController.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartController.cartItems[index];
              final product = item['product'];
              return ListTile(
                leading: Image.network(product['image_path']),
                title: Text(
                    'Product: ${product['product_name']}, Quantity: ${item['quantity']}'),
                subtitle: Text('${product['product_id']}'),
                trailing: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    cartController.removeFromCart(product['product_id']);
                  },
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          cartController.checkOutFromCart();
        },
        child: const Icon(Icons.shopping_cart_checkout),
      ),
    );
  }
}

footer(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 30),
              child: Text(
                "Total",
                style: CustomTextStyle.textFormFieldMedium
                    .copyWith(color: Colors.grey, fontSize: 12),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 30),
              child: Text(
                getFormattedCurrency(29999),
                style: CustomTextStyle.textFormFieldBlack
                    .copyWith(color: Colors.greenAccent.shade700, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Navigator.push(context,
            //     new MaterialPageRoute(builder: (context) => CheckOutPage()));
          },
          // color: Colors.green,
          // padding: EdgeInsets.only(top: 12, left: 60, right: 60, bottom: 12),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          child: Text(
            "Checkout",
            style: CustomTextStyle.textFormFieldSemiBold
                .copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}
