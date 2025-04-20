class ClientModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final int orderCount;
  final String sumPrice;

  ClientModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.orderCount,
    required this.sumPrice,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      sumPrice: json['order_count'] ?? '0',
      orderCount: json['sum_price'] ?? 0,
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'order_count': orderCount,
      'sum_price': sumPrice,
    };
  }
}
