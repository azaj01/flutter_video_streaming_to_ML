import 'package:app/model/cart.dart';
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
        title: Text('Cart'),
      ),
      body: Obx(() => ListView.builder(
            itemCount: cartController.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartController.cartItems[index];
              final product = item['product'];
              return ListTile(
                leading: Image.network(product['image_path']),
                title: Text(
                    'Product: ${product['product_id']}, Quantity: ${item['quantity']}'),
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
          cartController.clearCart();
        },
        child: Icon(Icons.clear),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {

  //   return Scaffold(
  //     resizeToAvoidBottomInset: false,
  //     backgroundColor: Colors.grey.shade100,
  //     body: Builder(
  //       builder: (context) {
  //         return ListView(
  //           children: <Widget>[
  //             createHeader(),
  //             createSubTitle(),
  //             createCartList(),
  //             footer(context)
  //           ],
  //         );
  //       },
  //     ),
  //   );
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

createHeader() {
  return Container(
    alignment: Alignment.topLeft,
    margin: const EdgeInsets.only(left: 12, top: 12),
    child: Text(
      "SHOPPING CART",
      style: CustomTextStyle.textFormFieldBold
          .copyWith(fontSize: 16, color: Colors.black),
    ),
  );
}

createSubTitle() {
  return Container(
    alignment: Alignment.topLeft,
    margin: const EdgeInsets.only(left: 12, top: 4),
    child: Text(
      "Total(3) Items",
      style: CustomTextStyle.textFormFieldBold
          .copyWith(fontSize: 12, color: Colors.grey),
    ),
  );
}

createCartList() {
  return ListView.builder(
    shrinkWrap: true,
    primary: false,
    itemBuilder: (context, position) {
      return createCartListItem();
    },
    itemCount: 5,
  );
}

createCartListItem() {
  return Stack(
    children: <Widget>[
      Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Row(
          children: <Widget>[
            Container(
              margin:
                  const EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  color: Colors.blue.shade200,
                  image: const DecorationImage(
                      image: AssetImage("images/shoes_1.png"))),
            ),
            Expanded(
              flex: 100,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      child: Text(
                        "NIKE XTM Basketball Shoeas",
                        maxLines: 2,
                        softWrap: true,
                        style: CustomTextStyle.textFormFieldSemiBold
                            .copyWith(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Green M",
                      style: CustomTextStyle.textFormFieldRegular
                          .copyWith(color: Colors.grey, fontSize: 14),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          getFormattedCurrency(299),
                          style: CustomTextStyle.textFormFieldBlack
                              .copyWith(color: Colors.green),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Icon(
                                Icons.remove,
                                size: 24,
                                color: Colors.grey.shade700,
                              ),
                              Container(
                                color: Colors.grey.shade200,
                                padding: const EdgeInsets.only(
                                    bottom: 2, right: 12, left: 12),
                                child: Text(
                                  "1",
                                  style: CustomTextStyle.textFormFieldSemiBold,
                                ),
                              ),
                              Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.grey.shade700,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 10, top: 8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Colors.green),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 20,
          ),
        ),
      )
    ],
  );
}
