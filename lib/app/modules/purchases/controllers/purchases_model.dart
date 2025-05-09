import 'package:stock_managament_admin/app/product/init/packages.dart';

class PurchasesModel {
  final int id;
  final String title;
  final String date;
  final String source;
  final String cost;
  final int productCount;
  final String description;
  final List<SearchModel> products;

  PurchasesModel({
    required this.id,
    required this.description,
    required this.cost,
    required this.title,
    required this.date,
    required this.source,
    required this.productCount,
    required this.products,
  });

  factory PurchasesModel.fromJson(Map<String, dynamic> json) {
    return PurchasesModel(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      cost: json['cost'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      source: json['source'] ?? '',
      productCount: json['product_count'] ?? 0,
      products: json['products'] != null ? (json['product'] as List).map((i) => SearchModel.fromJson(i)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': productCount,
      'description': description,
      'cost': cost,
      'title': title,
      'date': date,
      'source': source,
      'productCount': productCount,
      'product': products.map((product) => product.toJson()).toList(),
    };
  }
}
