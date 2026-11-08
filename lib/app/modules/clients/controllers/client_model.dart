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
    final phone = json['phone']?.toString() ?? '';
    return ClientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: phone.startsWith('+993') ? phone.substring(4) : phone,
      sumPrice: json['sumprice']?.toString(),
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

class ClientsPage {
  final List<ClientModel> clients;
  final int page;
  final int totalPages;
  final int count;

  ClientsPage({
    required this.clients,
    required this.page,
    required this.totalPages,
    required this.count,
  });
}
