class ExpencesModel {
  final String name;
  final String? date;
  final String cost;
  final String note;
  final int? id;

  ExpencesModel({
    required this.date,
    required this.id,
    required this.name,
    required this.note,
    required this.cost,
  });
  factory ExpencesModel.fromJson(Map<String, dynamic> json) {
    return ExpencesModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Name',
      date: json['date'] ?? '',
      note: json['notes'] ?? '',
      cost: json['cost'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'notes': note,
      'cost': cost,
    };
  }
}
