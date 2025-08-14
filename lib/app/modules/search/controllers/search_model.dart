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
  // DEĞİŞİKLİK 1: 'purch' alanı artık bir liste.
  final List<PurchaseModelInsideProduct> purch;

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
    // DEĞİŞİKLİK 2: Constructor'daki 'purch' alanı da liste olarak güncellendi.
    required this.purch,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    // DEĞİŞİKLİK 3: 'purch' listesini doğru şekilde ayrıştırma
    List<PurchaseModelInsideProduct> purchList = [];
    if (json['purch'] != null && json['purch'] is List) {
      // JSON'daki listeyi alıp her bir elemanını PurchaseModelInsideProduct'a dönüştürüyoruz.
      purchList = (json['purch'] as List).map((item) => PurchaseModelInsideProduct.fromJson(item)).toList();
    }

    return SearchModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category_detail'] != null ? CategoryModel.fromJson(json['category_detail']) : null,
      brend: json['brends_detail'] != null ? BrendModel.fromJson(json['brends_detail']) : null,
      material: json['materials_detail'] != null ? MaterialModel.fromJson(json['materials_detail']) : null,
      location: json['location_detail'] != null ? LocationModel.fromJson(json['location_detail']) : null,
      // Ayrıştırılan listeyi burada kullanıyoruz. Eğer 'purch' boş veya null ise boş bir liste atanır.
      purch: purchList,
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
      'category_detail': category?.toJson(),
      'brends_detail': brend?.toJson(),
      'location_detail': location?.toJson(),
      'materials_detail': material?.toJson(),
      // DEĞİŞİKLİK 4: 'purch' listesini JSON'a dönüştürme
      'purch': purch.map((p) => p.toJson()).toList(),
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
    };
  }
}

class PurchaseModelInsideProduct {
  final int id;
  final String? purchaseName;
  final String? datePurhcase;
  final String? priceOfSale;
  final String? count;

  PurchaseModelInsideProduct({
    required this.id,
    required this.count,
    required this.purchaseName,
    required this.datePurhcase,
    required this.priceOfSale,
  });

  factory PurchaseModelInsideProduct.fromJson(Map<String, dynamic> json) {
    return PurchaseModelInsideProduct(
      id: json['id'] ?? 0,
      count: json['count'].toString() ?? '',
      priceOfSale: json['priceofsale'].toString() ?? '',
      datePurhcase: json['date_purchase'].toString() ?? '',
      purchaseName: json['purchase_name'].toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
      'priceofsale': priceOfSale,
      'date_purchase': datePurhcase,
      'purchase_name': purchaseName,
    };
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
    };
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
    };
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
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'address': address,
    };
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
