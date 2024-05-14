class OrderModel {
  final String? clientAddress;
  final String? clientName;
  final String? clientNumber;
  final String? coupon;
  final String? date;
  final String? discount;
  final String? note;
  final String? package;
  final String? status;
  final String? sumCost;
  final String? sumPrice;
  final String? orderID;
  final String? products;

  OrderModel({
    required this.orderID,
    required this.products,
    required this.clientAddress,
    required this.clientName,
    required this.clientNumber,
    required this.coupon,
    required this.date,
    required this.discount,
    required this.note,
    required this.package,
    required this.status,
    required this.sumCost,
    required this.sumPrice,
  });

  // factory ProductModel.fromJson(Map<dynamic, dynamic> json) {
  //   return ProductModel(
  //     brandName: json['brand'] ?? '',
  //     category: json['category'] ?? '',
  //     cost: json['cost'] ?? -1,
  //     gramm: json['gramm'] ?? -1,
  //     image: json['image'] ?? '',
  //     material: json['material'] ?? '',
  //     location: json['location'] ?? '',
  //     name: json['name'] ?? '',
  //     note: json['note'] ?? '',
  //     package: json['package'] ?? '',
  //     quantity: json['quantity'] ?? -1,
  //     sellPrice: json['sell_price'] ?? '',
  //   );
  // }
}
