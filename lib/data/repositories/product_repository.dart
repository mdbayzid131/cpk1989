import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';

class ProductRepository {
  final ApiClient apiClient;

  ProductRepository({required this.apiClient});

  /// Get list of products (Public feed)
  Future<Response> getProducts({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final Map<String, dynamic> query = {'page': page, 'limit': limit};
    if (status != null) {
      query['status'] = status;
    }
    return await apiClient.getData(
      ApiConstants.products,
      query: query,
      requiresAuth: false,
    );
  }

  /// Get details of a single product by ID (Public details)
  Future<Response> getProductById(String id) async {
    return await apiClient.getData(
      '${ApiConstants.products}/$id',
      requiresAuth: false,
    );
  }

  /// Update product details by ID (PATCH /products/:id - JSON only)
  Future<Response> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await apiClient.patchData('${ApiConstants.products}/$id', data);
  }

  /// Delete a product listing by ID (DELETE /products/:id)
  Future<Response> deleteProduct(String id) async {
    return await apiClient.deleteData('${ApiConstants.products}/$id');
  }

  /// ===================== CREATE PRODUCT (SELL FLOW) =====================
  /// Create a new product listing with multiple images and optional purchase proof PDF.
  Future<Response> createProduct({
    required String name,
    required String brand,
    required double price,
    required String condition,
    required String description,
    required bool originalPackagingAvailable,
    required List<String> imagePaths, // camera or gallery local file paths
    String? proofOfPurchasePath, // proof of purchase PDF file path (optional)
  }) async {
    final formData = FormData();

    // 1. Serialize product metadata as a JSON string inside the 'data' form field
    final Map<String, dynamic> productMetadata = {
      "name": name,
      "brand": brand,
      "description": description,
      "price": price,
      "condition": condition,
      "originalPackagingAvailable": originalPackagingAvailable,
    };
    formData.fields.add(MapEntry('data', jsonEncode(productMetadata)));

    // 2. Add multiple images under the standard key name 'image'
    for (int i = 0; i < imagePaths.length; i++) {
      final path = imagePaths[i];
      if (path.isNotEmpty &&
          !path.startsWith('http') &&
          !path.startsWith('MOCK_')) {
        final file = File(path);
        if (await file.exists()) {
          formData.files.add(
            MapEntry(
              'image', // key name is 'image' for all items
              await MultipartFile.fromFile(
                path,
                filename: 'product_image_$i.jpg',
              ),
            ),
          );
        }
      }
    }

    // 3. Add proof of purchase PDF or image file under key name 'doc'
    if (proofOfPurchasePath != null && proofOfPurchasePath.isNotEmpty) {
      if (!proofOfPurchasePath.startsWith('http') &&
          !proofOfPurchasePath.startsWith('MOCK_')) {
        final file = File(proofOfPurchasePath);
        if (await file.exists()) {
          formData.files.add(
            MapEntry(
              'doc',
              await MultipartFile.fromFile(
                proofOfPurchasePath,
                filename: proofOfPurchasePath.split('/').last,
              ),
            ),
          );
        }
      }
    }

    // 4. Send POST request
    return await apiClient.postData(ApiConstants.products, formData);
  }
}
