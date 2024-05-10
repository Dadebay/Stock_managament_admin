class ProductModel {
  final String? brandName;
  final String? category;
  final String? cost;
  final String? gramm;
  final String? image;
  final String? location;
  final String? material;
  final String? name;

  final int? quantity;

  final String? date;
  final String? sellPrice;
  final String? note;
  final String? package;
  final String? documentID;

  ProductModel({
    this.documentID,
    this.brandName,
    this.date,
    this.category,
    this.cost,
    this.gramm,
    this.image,
    this.location,
    this.material,
    this.name,
    this.note,
    this.package,
    this.quantity,
    this.sellPrice,
  });
}
