class FourInOneModel {
  final int? id;
  final String name;
  final String notes;
  final String? address;
  final String quantity;

  FourInOneModel({this.id, required this.quantity, required this.name, required this.notes, this.address});

  factory FourInOneModel.fromJson(Map<String, dynamic> json) {
    return FourInOneModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      notes: json['notes'] ?? 0,
      quantity: json['quantity'].toString(),
      address: json['address'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'notes': notes,
      'address': address,
    };
  }
}
