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

  /// Get user's purchased items / orders history
  Future<Response> getMyOrders() async {
    return await apiClient.getData(ApiConstants.orders);
  }

  /// Get user's listed items (My Wardrobe)
  Future<Response> getMyWardrobe({
    required String sellerId,
    int page = 1,
    int limit = 20,
  }) async {
    return await apiClient.getData(
      ApiConstants.products,
      query: {'seller': sellerId, 'page': page, 'limit': limit},
    );
  }
}
