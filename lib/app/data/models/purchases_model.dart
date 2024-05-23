class PurchasesModel {
  final String? purchasesID;
  final String? title;
  final String? date;
  final String? productsCount;
  final String? source;
  final String? cost;
  final String? note;

  PurchasesModel({
    required this.purchasesID,
    required this.title,
    required this.date,
    required this.note,
    required this.cost,
    required this.productsCount,
    required this.source,
  });
}
