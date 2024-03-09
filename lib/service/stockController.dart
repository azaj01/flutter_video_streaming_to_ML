import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockController extends GetxController {
  final _client = Supabase.instance.client;

  final _products = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get productStock => _products.toList();
  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await _client.from('product').select();
    _products.assignAll(response);
  }

  Future<void> refreshProduct() async {
    await fetchProducts();
  }
}
