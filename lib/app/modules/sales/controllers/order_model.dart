import 'package:stock_managament_admin/app/modules/search/controllers/search_model.dart';

class ClientDetailModel {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final String? ordercount;
  final String? sumprice;

  ClientDetailModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.ordercount,
    this.sumprice,
  });

  factory ClientDetailModel.fromJson(Map<String, dynamic> json) {
    return ClientDetailModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] != null ? (json['phone'].toString().startsWith("+993") ? json['phone'].toString() : "+993${json['phone'].toString()}") : null,
      description: json['description'] ?? '',
      ordercount: json['ordercount']?.toString() ?? '',
      sumprice: json['sumprice']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'ordercount': ordercount,
      'sumprice': sumprice,
    };
  }

  ClientDetailModel copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? description,
    String? ordercount,
    String? sumprice,
  }) {
    return ClientDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      ordercount: ordercount ?? this.ordercount,
      sumprice: sumprice ?? this.sumprice,
    );
  }
}

class OrderModel {
  final int id;
  final String status;
  final String gaplama;
  final String date;
  final String name;
  final int clientID;
  final ClientDetailModel? clientDetailModel;
  final String discount;
  final String coupon;
  final String description;
  final String totalsum;
  final String totalchykdajy;
  final int? count;
  final List<SearchModel> products;

  OrderModel({
    required this.id,
    required this.status,
    required this.gaplama,
    required this.date,
    required this.name,
    required this.clientID,
    this.clientDetailModel,
    required this.discount,
    required this.coupon,
    required this.description,
    this.count,
    required this.totalsum,
    required this.totalchykdajy,
    required this.products,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int? ?? 0,
      status: json['status'].toString() ?? '1',
      gaplama: json['gaplama'] as String? ?? '',
      date: json['datetime'] as String? ?? (json['date'] as String? ?? ''),
      name: json['name'] as String? ?? '',
      clientID: json['client'] as int? ?? (json['client_detail'] != null ? json['client_detail']['id'] : 0),
      clientDetailModel: json['client_detail'] != null && json['client_detail'] is Map<String, dynamic> ? ClientDetailModel.fromJson(json['client_detail'] as Map<String, dynamic>) : null,
      discount: json['discount']?.toString() ?? '0',
      coupon: json['coupon'] as String? ?? '',
      description: json['description'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      totalsum: json['totalsum']?.toString() ?? '0',
      totalchykdajy: json['totalchykdajy']?.toString() ?? '0',
      products: (json['product_detail'] != null && json['product_detail'] is List) ? (json['product_detail'] as List).map((i) => SearchModel.fromJson(i as Map<String, dynamic>)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'id': id,
      'status': status,
      'gaplama': gaplama,
      'datetime': date,
      'name': name,
      'client': clientID,
      'discount': discount,
      'coupon': coupon,
      'description': description,
      'count': count,
      'totalsum': totalsum,
      'totalchykdajy': totalchykdajy,
      'product_detail': products.map((p) => p.toJson()).toList(),
    };

    if (clientDetailModel != null) {
      data['clientName'] = clientDetailModel!.name;
      data['clientAddress'] = clientDetailModel!.address;
      data['clientPhone'] = clientDetailModel!.phone;
    }

    return data;
  }

  OrderModel copyWith({
    int? id,
    String? status,
    String? gaplama,
    String? date,
    String? name,
    int? clientID,
    ClientDetailModel? clientDetailModel,
    String? discount,
    String? coupon,
    String? description,
    int? count,
    String? totalsum,
    String? totalchykdajy,
    List<SearchModel>? products,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      gaplama: gaplama ?? this.gaplama,
      date: date ?? this.date,
      name: name ?? this.name,
      clientID: clientID ?? this.clientID,
      clientDetailModel: clientDetailModel ?? this.clientDetailModel,
      discount: discount ?? this.discount,
      coupon: coupon ?? this.coupon,
      description: description ?? this.description,
      count: count ?? this.count,
      totalsum: totalsum ?? this.totalsum,
      totalchykdajy: totalchykdajy ?? this.totalchykdajy,
      products: products ?? this.products,
    );
  }
}
