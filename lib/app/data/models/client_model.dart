class Client {
  String name;
  final String number;
  final String address;
  final String date;
  int orderCount;
  double sumPrice;

  Client({
    required this.address,
    required this.date,
    required this.orderCount,
    required this.name,
    required this.number,
    required this.sumPrice,
  });
}
