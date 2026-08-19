import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class WishlistRepository {
  final ApiClient apiClient;

  WishlistRepository({required this.apiClient});

  /// Get Wishlist Items: GET /wishlist
  Future<Response> getWishlist() async {
    return await apiClient.getData(ApiConstants.wishlist);
  }

  /// Add Item to Wishlist: POST /wishlist/:productId
  Future<Response> addToWishlist(String productId) async {
    return await apiClient.postData('${ApiConstants.wishlist}/$productId', {});
  }

  /// Remove Item from Wishlist: DELETE /wishlist/:productId
  Future<Response> removeFromWishlist(String productId) async {
    return await apiClient.deleteData('${ApiConstants.wishlist}/$productId');
  }
}
