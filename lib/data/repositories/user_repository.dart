import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository({required this.apiClient});

  /// Get logged-in user profile details (Name, email, phone, location, profilePicture)
  Future<Response> getProfile() async {
    return await apiClient.getData(ApiConstants.profile);
  }

  /// Update personal details (name, phone, address, location, etc., or image file)
  Future<Response> updateProfile(
    Map<String, dynamic> body, {
    File? imageFile,
  }) async {
    if (imageFile != null) {
      return await apiClient.patchMultipartData(
        ApiConstants.profile,
        body,
        multipartBody: [MultipartBody('image', imageFile)],
      );
    }
    return await apiClient.patchData(ApiConstants.profile, body);
  }

  /// Delete profile photo: DELETE /user/profile/photo
  Future<Response> deleteProfilePhoto() async {
    return await apiClient.deleteData(ApiConstants.profilePhoto);
  }

  /// Get user's purchased items / orders history with pagination
  Future<Response> getMyOrders({int page = 1, int limit = 10}) async {
    return await apiClient.getData(
      ApiConstants.orders,
      query: {'page': page, 'limit': limit},
    );
  }

  /// Get specific order full details (GET /orders/:id)
  Future<Response> getOrderDetails(String orderId) async {
    return await apiClient.getData('${ApiConstants.orders}/$orderId');
  }

  /// Get logged-in user's listed items (My Profile / Wardrobe: GET /products/my-products)
  Future<Response> getMyWardrobe({
    String? sellerId,
    dynamic status,
    int page = 1,
    int limit = 50,
  }) async {
    return await apiClient.getData(
      ApiConstants.myProducts,
      query: {'page': page, 'limit': limit},
      requiresAuth: true,
    );
  }

  /// Get another seller's listed items (Seller Profile screen: GET /products?seller=...)
  Future<Response> getSellerProducts({
    required String sellerId,
    dynamic status,
    int page = 1,
    int limit = 50,
  }) async {
    final Map<String, dynamic> queryParams = {
      'seller': sellerId,
      'page': page,
      'limit': limit,
    };
    if (status != null) {
      queryParams['status'] = status;
    }
    return await apiClient.getData(
      ApiConstants.products,
      query: queryParams,
      requiresAuth: true,
    );
  }

  /// Get profile statistics (GET /user/profile/stats or GET /user/profile/stats/:userId)
  Future<Response> getProfileStats({String? userId}) async {
    final endpoint = (userId != null && userId.isNotEmpty)
        ? '${ApiConstants.profileStats}/$userId'
        : ApiConstants.profileStats;
    return await apiClient.getData(endpoint);
  }
}
