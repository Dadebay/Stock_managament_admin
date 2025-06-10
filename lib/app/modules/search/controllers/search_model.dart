class SearchModel {
  final int id;
  final String name;
  final String price;
  final String gramm;
  final int count;

  final String description;
  final String gaplama;
  final String createdAT;
  final String? img;
  final String cost;
  final CategoryModel? category;
  final BrendModel? brend;
  final LocationModel? location;
  final MaterialModel? material;

  SearchModel({
    required this.id,
    required this.name,
    required this.price,
    required this.gramm,
    required this.count,
    required this.description,
    required this.gaplama,
    required this.createdAT,
    required this.img,
    required this.cost,
    required this.category,
    required this.brend,
    required this.location,
    required this.material,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category_detail'] != null ? CategoryModel.fromJson(json['category_detail']) : CategoryModel(id: 0, name: ""),
      brend: json['brends_detail'] != null ? BrendModel.fromJson(json['brends_detail']) : BrendModel(id: 0, name: ""),
      material: json['materials_detail'] != null ? MaterialModel.fromJson(json['materials_detail']) : MaterialModel(id: 0, name: ""),
      location: json['location_detail'] != null ? LocationModel.fromJson(json['location_detail']) : LocationModel(id: 0, name: ""),
      price: json['price'] ?? '',
      gramm: json['gram'] ?? '',
      count: json['count'] ?? 0,
      description: json['description'] ?? '',
      gaplama: json['gaplama'] ?? '',
      createdAT: json['created_at'] ?? '',
      img: json['img'] ?? '',
      cost: json['cost'] ?? '',
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'gram': gramm,
      'count': count,
      'description': description,
      'gaplama': gaplama,
      'created_at': createdAT,
      'img': img,
      'cost': cost,
      'category_detail': category,
      'brends_detail': brend,
      'location_detail': location,
      'materials_detail': material,
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? notes;

  CategoryModel({
    required this.id,
    required this.name,
    this.notes,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      notes: json['notes'],
    );
  }
}

class BrendModel {
  final int id;
  final String name;
  final String? notes;

  BrendModel({
    required this.id,
    required this.name,
    this.notes,
  });

  factory BrendModel.fromJson(Map<String, dynamic> json) {
    return BrendModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      notes: json['notes'],
    );
  }
}

class MaterialModel {
  final int id;
  final String name;
  final String? notes;

  MaterialModel({
    required this.id,
    required this.name,
    this.notes,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      notes: json['notes'],
    );
  }
}

class LocationModel {
  final int id;
  final String name;
  final String? notes;
  final String? address;

  LocationModel({
    required this.id,
    required this.name,
    this.notes,
    this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      notes: json['notes'],
      address: json['address'],
    );
  }
}

class ProductModel {
  final int id;
  final int count;
  final SearchModel? product;

  ProductModel({
    required this.id,
    required this.count,
    required this.product,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      count: json['count'] ?? 0,
      product: SearchModel.fromJson(json['product']),
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
      'product': product,
    };
  }
}
