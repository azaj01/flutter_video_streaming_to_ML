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
    print(response);
    return response;
  }

  Future<Map<String, dynamic>> getProductByName(String productName) async {
    final response = await _supabaseClient
        .from('product')
        .select()
        .eq('product_name', productName)
        .single();
    print(response);
    return response;
  }
}
