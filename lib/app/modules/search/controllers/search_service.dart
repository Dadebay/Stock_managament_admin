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
    Uint8List? imageBytes, // optional
    String? imageFileName, // optional
  }) async {
    final uri = Uri.parse(ApiConstants.products + '$id/');
    print(uri);

    final request = http.MultipartRequest('PUT', uri);

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
    print(fields);
    final streamedResponse = await request.send();
    final statusCode = streamedResponse.statusCode;
    print(streamedResponse.statusCode);

    if (statusCode == 200) {
      final responseBody = await streamedResponse.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);
      final updatedModel = SearchModel.fromJson(jsonData);
      searchViewController.updateProductLocally(updatedModel);
      print("✔️ Başarılı: $responseBody");
    } else {
      print("❌ Hata: $statusCode");
    }
  }

  Future<SearchModel> createProductWithImage({
    required Map<String, String> fields,
    Uint8List? imageBytes, // optional
    String? imageFileName, // optional
  }) async {
    final uri = Uri.parse(ApiConstants.products);
    print(uri);

    final request = http.MultipartRequest('POST', uri);

    final token = await AuthStorage().getToken();
    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll(fields);
    print(imageBytes);
    if (imageBytes != null && imageFileName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'img',
        imageBytes,
        filename: imageFileName,
        contentType: MediaType('image', 'png'),
      ));
    }
    print(fields);
    final streamedResponse = await request.send();
    final statusCode = streamedResponse.statusCode;
    print(streamedResponse.statusCode);

    if (statusCode == 200 || statusCode == 201) {
      final responseBody = await streamedResponse.stream.bytesToString();
      final jsonData = jsonDecode(responseBody);
      final updatedModel = SearchModel.fromJson(jsonData);
      searchViewController.updateProductLocally(updatedModel);
      print("✔️ Başarılı: $responseBody");
      return updatedModel;
    } else {
      print("❌ Hata: $statusCode");
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
