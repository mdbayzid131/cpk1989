import 'package:cpk1989/config/constants/api_constants.dart';
import 'package:cpk1989/core/services/api_client.dart';
import 'package:cpk1989/data/models/create_event_request_model.dart';
import 'package:get/get.dart' hide Response;
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class UserDataRepository {
  final ApiClient _apiClient = Get.find();
  final Dio dio = Dio();

  // Get user profile
  Future<Response<dynamic>> getProfile() async {
    return await _apiClient.getData(ApiConstants.profile);
  }

  // Complete onboarding
  Future<Response<dynamic>> completeOnboarding() async {
    return await _apiClient.patchData(ApiConstants.completeOnboarding, {});
  }

  // Get all preference card count
  Future<Response<dynamic>> getCardCount() async {
    return await _apiClient.getData(ApiConstants.getCardCount);
  }

  // Get all preference card
  Future<Response<dynamic>> getAllCard({int page = 1}) async {
    return await _apiClient.getData(
      ApiConstants.getAllCard,
      query: {'page': page, 'limit': 10},
    );
  }

  // Get library cards (unified list)
  Future<Response<dynamic>> getLibraryCards({
    int page = 1,
    String search = '',
    String specialty = '',
    String verificationStatus = '',
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': 10};
    if (search.isNotEmpty) {
      query['searchTerm'] = search;
    }
    if (specialty.isNotEmpty) {
      query['specialty'] = specialty;
    }
    if (verificationStatus.isNotEmpty) {
      query['verificationStatus'] = verificationStatus;
    }
    return await _apiClient.getData(ApiConstants.getAllCardsList, query: query);
  }

  // Get my preference cards
  Future<Response<dynamic>> getMyCards({
    int page = 1,
    String search = '',
    String visibility = 'public',
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': 10,
      'visibility': visibility,
    };
    if (search.isNotEmpty) {
      query['searchTerm'] = search;
    }
    return await _apiClient.getData(ApiConstants.getMyCards, query: query);
  }

  // Get all favorite preference card
  Future<Response<dynamic>> getFavoriteCard({
    int page = 1,
    // String search = '',
    // String specialty = '',
    // String verificationStatus = '',
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': 10,
      // 'searchTerm': search,
    };
    // if (specialty.isNotEmpty) {
    //   query['specialty'] = specialty;
    // }
    // if (verificationStatus.isNotEmpty) {
    //   query['verificationStatus'] = verificationStatus;
    // }
    return await _apiClient.getData(ApiConstants.getFavoriteCard, query: query);
  }

  Future<Response<dynamic>> getCardDetails({required String cardId}) async {
    return await _apiClient.getData(
      ApiConstants.getCardDetails.replaceAll('{id}', cardId),
    );
  }

  Future<Response<dynamic>> downloadCard({required String cardId}) async {
    return await _apiClient.postData(
      ApiConstants.downloadCard.replaceAll('{id}', cardId),
      {},
    );
  }

  Future<File> downloadCardPdf({
    required String cardId,
    required String savePath,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.downloadCard.replaceAll('{id}', cardId),
      data: {},
      options: Options(responseType: ResponseType.bytes),
    );

    File file = File(savePath);
    await file.writeAsBytes(response.data);
    return file;
  }

  Future<Response<dynamic>> getSupplies({
    String search = '',
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.getData(
      ApiConstants.getSuppliesList,
      query: {'searchTerm': search, 'page': page, 'limit': limit},
    );
  }

  Future<Response<dynamic>> getSpecialties() async {
    return await _apiClient.getData(
      ApiConstants.getSpecialties,
      query: {
        'limit': 100,
      }, // Assuming we want to fetch all specialties, giving a high limit
    );
  }

  Future<Response<dynamic>> getSutures({
    String search = '',
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.getData(
      ApiConstants.getSuturesList,
      query: {'searchTerm': search, 'page': page, 'limit': limit},
    );
  }

  Future<Response<dynamic>> addToFavoriteList({required String cardId}) async {
    return await _apiClient.putData(
      ApiConstants.addToFavoriteList.replaceAll('{id}', cardId),
      {},
    );
  }

  Future<Response<dynamic>> removeFromFavoriteList({
    required String cardId,
  }) async {
    return await _apiClient.deleteData(
      ApiConstants.removeFromFavoriteList.replaceAll('{id}', cardId),
    );
  }

  Future<Response> createPreferenceCard({
    required String cardTitle,
    required Map<String, dynamic> surgeon,
    required String medication,
    required List<Map<String, dynamic>> supplies,
    required List<Map<String, dynamic>> sutures,
    required String instruments,
    required String positioningEquipment,
    required String prepping,
    required String workflow,
    required String keyNotes,
    required String visibility, // Changed from bool published
    required List<File> photos,
  }) async {
    // 1. Build the data map (text fields)
    final Map<String, dynamic> body = {
      'cardTitle': cardTitle,
      'medication': medication,
      'instruments': instruments,
      'positioningEquipment': positioningEquipment,
      'prepping': prepping,
      'workflow': workflow,
      'keyNotes': keyNotes,
      'visibility': visibility,
      'surgeon': jsonEncode(surgeon),
      'supplies': jsonEncode(supplies),
      'sutures': jsonEncode(sutures),
    };

    // 2. Prepare files for multipartBody
    List<MultipartBody> multipartConfig = photos.map((file) {
      return MultipartBody("photoLibrary", file);
    }).toList();

    // 3. Send using postMultipartData
    return await _apiClient.postMultipartData(
      ApiConstants
          .getAllCardsList, // Updated from getAllCard (/preference-card) to getAllCardsList (/preference-cards)
      body,
      multipartBody: multipartConfig,
    );
  }

  // Delete preference card
  Future<Response<dynamic>> deletePreferenceCard({
    required String cardId,
  }) async {
    return await _apiClient.deleteData(
      ApiConstants.getCardDetails.replaceAll('{id}', cardId),
    );
  }

  // Event Endpoints
  Future<Response<dynamic>> getCalendarHighlights({
    required String from,
    required String to,
  }) async {
    return await _apiClient.getData(
      ApiConstants.getCalendarHighlights,
      query: {'from': from, 'to': to},
    );
  }

  Future<Response<dynamic>> getEventsList({String? date}) async {
    return await _apiClient.getData(
      ApiConstants.getEventsList,
      query: date != null ? {'date': date} : null,
    );
  }

  // Get event detail by id
  Future<Response<dynamic>> getEventDetailById({required String id}) async {
    return await _apiClient.getData(
      ApiConstants.getEventDetailById.replaceAll('{id}', id),
    );
  }

  // Create event
  Future<Response> createEvent(CreateEventRequestModel model) async {
    return await _apiClient.postData(ApiConstants.postEvent, model.toJson());
  }

  // Update event
  Future<Response<dynamic>> patchEvent({
    required String id,
    required CreateEventRequestModel model,
  }) async {
    return await _apiClient.patchData(
      ApiConstants.patchEvent.replaceAll('{id}', id),
      model.toJson(),
    );
  }

  // Delete event
  Future<Response<dynamic>> deleteEvent({required String id}) async {
    return await _apiClient.deleteData(
      ApiConstants.deleteEvent.replaceAll('{id}', id),
    );
  }

  // Update profile
  Future<Response> updateProfile({
    required String name,
    required String phone,
    required String specialty,
    required String hospital,
    required String email,
  }) async {
    return await _apiClient.patchData(ApiConstants.profile, {
      "name": name,
      "phone": phone,
      "specialty": specialty,
      "hospital": hospital,
      "email": email,
    });
  }

  // Update profile image (multipart)
  Future<Response> updateProfileImage({required File imageFile}) async {
    return await _apiClient.patchMultipartData(
      ApiConstants.profile,
      {},
      multipartBody: [MultipartBody('profilePicture', imageFile)],
    );
  }

  // Get legal pages
  Future<Response<dynamic>> getLegalPages() async {
    return await _apiClient.getData(ApiConstants.getLegalPages);
  }

  // Get legal page details by slug
  Future<Response<dynamic>> getLegalPageDetails({required String slug}) async {
    return await _apiClient.getData(
      ApiConstants.getLegalPageDetails.replaceAll('{slug}', slug),
    );
  }
}
