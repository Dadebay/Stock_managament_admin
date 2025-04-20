class FourInOneModel {
  final int id;
  final String name;
  final String notes;
  final String? address;

  FourInOneModel({required this.id, required this.name, required this.notes, this.address});

  factory FourInOneModel.fromJson(Map<String, dynamic> json) {
    return FourInOneModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      notes: json['notes'] ?? 0,
      address: json['address'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'address': address,
    };
  }
}
