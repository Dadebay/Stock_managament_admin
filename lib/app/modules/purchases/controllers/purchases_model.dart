import 'package:stock_managament_admin/app/product/init/packages.dart';

class PurchasesModel {
  final int id;
  final String title;
  final String date;
  final String source;
  final String cost;
  int count;
  final String description;
  final List<SearchModel> products;

  PurchasesModel({
    required this.id,
    required this.description,
    required this.cost,
    required this.title,
    required this.date,
    required this.source,
    required this.count,
    required this.products,
  });

  factory PurchasesModel.fromJson(Map<String, dynamic> json) {
    return PurchasesModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      source: json['source'] ?? '',
      cost: json['cost'] ?? '',
      description: json['description'] ?? '',
      count: json['count'] ?? 0,
      products: json['product_detail'] != null ? (json['product_detail'] as List).map((i) => SearchModel.fromJson(i)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
      'description': description,
      'cost': cost,
      'title': title,
      'date': date,
      'source': source,
      'product_detail': products.map((product) => product.toJson()).toList(),
    };
  }
}

class ProductModelPurchases {
  final int id;
  final int count;
  final SearchModel? product;

  ProductModelPurchases({
    required this.id,
    required this.count,
    required this.product,
  });

  factory ProductModelPurchases.fromJson(Map<String, dynamic> json) {
    return ProductModelPurchases(
      id: json['id'] ?? 0,
      count: json['count'] ?? 0,
      product: SearchModel.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
      'product': product,
    };
  }
}
