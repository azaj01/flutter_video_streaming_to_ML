import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  ProductService();

  Future<Map<String, dynamic>> getProductById(String productId) async {
    final response = await _supabaseClient
        .from('product')
        .select()
        .eq('product_id', productId)
        .single();
    // print(response);
    return response;
  }

  Future<Map<String, dynamic>> getProductByName(String productName) async {
    final response = await _supabaseClient
        .from('product')
        .select()
        .eq('product_name', productName)
        .single();
    // print(response);
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchCheckoutHistory() async {
    final response = await Supabase.instance.client.rpc('get_checkout_history');
    if (response is List) {
      // Assuming each item in the list is of type Map<String, dynamic>
      return response.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Invalid response type');
    }
  }
}
