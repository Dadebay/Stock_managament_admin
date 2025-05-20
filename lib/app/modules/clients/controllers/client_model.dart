class ClientModel {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final int? orderCount;
  final String? sumPrice;

  ClientModel({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.orderCount,
    this.sumPrice,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'].toString().contains("+993") ? json['phone'].toString().replaceFirst("+993", "") : json['phone'].toString() ?? '',
      sumPrice: json['sumprice'] ?? 0,
      orderCount: json['ordercount'] ?? 0,
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'ordercount': orderCount,
      'sumprice': sumPrice,
    };
  }
}
