import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/product/constants/api_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SearchService {
  final SearchViewController searchViewController = Get.find();

  Future<List<SearchModel>> getProducts() async {
    final data = await ApiService().getRequest(ApiConstants.products, requiresToken: true);
    if (data is Map && data['results'] != null) {
      return (data['results'] as List).map((item) => SearchModel.fromJson(item)).toList().reversed.toList();
    } else if (data is List) {
      return (data).map((item) => SearchModel.fromJson(item)).toList().reversed.toList();
    } else {
      return [];
    }
  }

  Future<SearchModel?> getProductByID(String id) async {
    final data = await ApiService().getRequest('${ApiConstants.products}/$id/', requiresToken: true);
    if (data != null && data['results'] != null) {
      return SearchModel.fromJson(data['results']);
    } else {
      return null;
    }
  }

  Future<void> updateProductWithImage({
    required int id,
    required Map<String, String> fields,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final uri = Uri.parse(ApiConstants.products + '$id/');
    final request = http.MultipartRequest('PUT', uri);
    final token = await AuthStorage().getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    print("Mana geldi-----------------------------------------------------------------------------");
    request.fields.forEach((key, value) {
      print('$key: $value');
    });

    if (imageBytes != null && imageFileName != null && imageFileName.isNotEmpty) {
      String extension = imageFileName.split('.').last.toLowerCase();
      if (extension.isEmpty) {
        extension = 'png'; // Varsayılan bir uzantı, eğer dosya adında yoksa
      }
      extension = (extension == 'jpg') ? 'jpeg' : extension;

      request.files.add(http.MultipartFile.fromBytes(
        'img',
        imageBytes,
        filename: imageFileName,
        contentType: MediaType('image', extension), // Dinamik içerik tipi
      ));
    }

    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final statusCode = streamedResponse.statusCode;

      print('Update Status Code: $statusCode');
      print('Update Response Body: $responseBody');

      if (statusCode == 200) {
        final jsonData = jsonDecode(responseBody);
        final updatedModel = SearchModel.fromJson(jsonData);
        searchViewController.updateProductLocally(updatedModel);
        // SnackBar zaten ProductProfilView içinde gösteriliyor.
      } else {
        // Hata durumunu daha iyi ele almak için
        String errorMessage = "Failed to update product. Status code: $statusCode";
        try {
          final errorJson = jsonDecode(responseBody);
          if (errorJson is Map && errorJson.containsKey('detail')) {
            errorMessage = errorJson['detail'];
          } else if (errorJson is Map) {
            errorMessage = errorJson.toString();
          }
        } catch (e) {
          // JSON parse edilemezse, ham body'yi kullan
          errorMessage += "\nResponse: $responseBody";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Error during product update: $e');
    }
  }

  Future<SearchModel> createProductWithImage({
    required Map<String, String> fields,
    Uint8List? imageBytes, // optional
    String? imageFileName, // optional
  }) async {
    final uri = Uri.parse(ApiConstants.products);
    final request = http.MultipartRequest('POST', uri);
    final token = await AuthStorage().getToken();
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    if (imageBytes != null && imageFileName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'img',
        imageBytes,
        filename: imageFileName,
        contentType: MediaType('image', 'png'),
      ));
    }
    final streamedResponse = await request.send();
    final statusCode = streamedResponse.statusCode;
    print(statusCode);
    print(streamedResponse.stream.bytesToString());
    if (statusCode == 200 || statusCode == 201) {
      final responseBody = await streamedResponse.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);
      final updatedModel = SearchModel.fromJson(jsonData);
      searchViewController.updateProductLocally(updatedModel);
      return updatedModel;
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future deleteProduct({required int id}) async {
    return ApiService().handleApiRequest(
      endpoint: ApiConstants.products + "$id/",
      method: 'DELETE',
      requiresToken: true,
      handleSuccess: (responseJson) async {
        if (responseJson.isNotEmpty) {
          searchViewController.deleteProduct(id);

          CustomWidgets.showSnackBar('success'.tr, 'Product Deleted'.tr, Colors.green);
        } else {
          CustomWidgets.showSnackBar('error'.tr, 'Product Not Deleted'.tr, Colors.red);
        }
      },
    );
  }
}
