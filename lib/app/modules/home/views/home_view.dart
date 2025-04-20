import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as ex;
import 'package:fl_chart/fl_chart.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class DataItem {
  int x;
  double sales;
  double purchases;
  double sumCost;
  double expences;
  double profit;
  DataItem({required this.x, required this.sales, required this.sumCost, required this.purchases, required this.expences, required this.profit});
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  List<double> expences = List.filled(12, 0.0);
  List<double> sales = List.filled(12, 0.0);
  List<double> purchases = List.filled(12, 0.0);
  List<double> profit = List.filled(12, 0.0);
  List<double> sumCost = List.filled(12, 0.0);
  List<double> zeroArray = List.filled(12, 0.0);

  DateTime? selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    getData(DateTime.now(), false);
  }

  Future<void> findProfit(bool runExcel, DateTime date) async {
    profit = List.filled(12, 0.0);
    for (int i = 0; i < 12; i++) {
      profit[i] = sales[i] - (expences[i] + purchases[i]);
    }
    findMinimumelement();
    if (runExcel == true) {
      var excel = ex.Excel.createExcel();
      ////
      List<Map<String, String>> oldExpences = [];
      DateTime dateeee = DateTime.now();
      await FirebaseFirestore.instance.collection('expences').get().then((value) {
        for (var element in value.docs) {
          DateTime dateTime = DateTime.parse(element['date'].toString().substring(0, 10));
          if (dateTime.year == dateeee.year) {
            oldExpences.add({'name': element['name'].toString(), 'date': element['date'].toString(), 'cost': element['cost'].toString()});
          }
        }
      });
      print(oldExpences);
      /////
      for (int i = 0; i < 12; i++) {
        ex.Sheet sheetObject = excel[months[i]];

        sheetObject.appendRow(["Sales", "Purchases", "Expenses", "Sum Cost", "Net Profit"]);
        sheetObject.appendRow([sales[i], purchases[i], expences[i], sumCost[i], profit[i]]);
        sheetObject.appendRow(['']);
        sheetObject.appendRow(['']);
        sheetObject.appendRow(['----Expences----']);
        for (var expence in oldExpences) {
          String cleanDateStr = expence['date']!.replaceAll(' , ', ' ');
          DateTime dateTime = DateTime.parse(cleanDateStr);
          if (dateTime.year == DateTime.now().year && dateTime.month == i + 1) {
            sheetObject.appendRow([
              // "kerimmm"
              expence['name'],
              expence['date'],
              expence['cost'],
            ]);
          }
        }
      }
      excel.save(fileName: "${selectedDateTime.toString().substring(0, 19)}_net_profit.xlsx");
    }
    setState(() {});
  }

  void findMinimumelement() {
    minElement1 = profit.reduce((value, element) => value < element ? value : element);
    maxElement1 = sales.reduce((value, element) => value > element ? value : element);
    maxElement2 = profit.reduce((value, element) => value > element ? value : element);
    maxElement3 = expences.reduce((value, element) => value > element ? value : element);
    maxElement4 = purchases.reduce((value, element) => value > element ? value : element);
    double a = max(maxElement1, maxElement2);
    double b = max(maxElement3, maxElement4);
    maxElement = max(a, b);
  }

  Future<void> getExpences(DateTime date) async {
    await FirebaseFirestore.instance.collection('expences').get().then((value) {
      for (var element in value.docs) {
        DateTime dateTime = DateTime.parse(element['date'].toString().substring(0, 10));
        if (dateTime.year == date.year) {
          expences[dateTime.month - 1] += double.parse(element['cost'].toString());
        }
      }
    });
  }

  Future<void> getSales(DateTime date) async {
    await FirebaseFirestore.instance.collection('sales').orderBy("date", descending: true).get().then((value) {
      for (var element in value.docs) {
        if (element['status'].toString().toLowerCase() == 'shipped') {
          DateTime dateTime = DateTime.parse(element['date'].toString().substring(0, 10));
          if (dateTime.year == date.year) {
            sales[dateTime.month - 1] += double.parse(element['sum_price'].toString());
            sumCost[dateTime.month - 1] += double.parse(element['sum_cost'].toString());
          }
        }
      }
    });
  }

  Future<void> getPurchases(DateTime date, bool runExcel) async {
    await FirebaseFirestore.instance.collection('purchases').orderBy("date", descending: true).get().then((value) {
      for (var element in value.docs) {
        DateTime dateTime = DateTime.parse(element['date'].toString().substring(0, 10));
        if (dateTime.year == date.year) {
          purchases[dateTime.month - 1] += double.parse(element['cost'].toString());
        }
      }
      findProfit(runExcel, date);
    });
  }

  double maxElement1 = 0.0;
  double maxElement3 = 0.0;
  double maxElement4 = 0.0;
  double minElement1 = 0.0;
  double maxElement2 = 0.0;
  double maxElement = 0.0;

  List<bool> valuesColor = [false, false, false, false, false];
  List<bool> valuesText = [false, false, false, false, false];
  Future<void> getData(DateTime date, bool runExcel) async {
    expences = List.filled(12, 0.0);
    sales = List.filled(12, 0.0);
    purchases = List.filled(12, 0.0);
    sumCost = List.filled(12, 0.0);
    getExpences(date);
    getSales(date);
    getPurchases(date, runExcel);
  }

  dynamic exportToExcel(BuildContext context, bool runExcel) async {
    await getData(selectedDateTime ?? DateTime.now(), runExcel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                names(name: "Sales", color: Colors.red, index: 0),
                names(name: "Purchase", color: Colors.amber, index: 1),
                names(name: "Expences", color: Colors.blue, index: 2),
                names(name: "Sum Cost", color: Colors.purple, index: 3),
                names(name: "Net Profit", color: Colors.green, index: 4),
                yearPicker(context),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: ElevatedButton(
                      onPressed: () async {
                        exportToExcel(context, true);
                      },
                      style: ElevatedButton.styleFrom(elevation: 0.0, backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: context.border.normalBorderRadius), padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16)),
                      child: const Text(
                        "Export Excel",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BarChart(
                BarChartData(
                    maxY: maxElement + 50,
                    minY: minElement1 - 20,
                    barGroups: List.generate(
                            12,
                            (index) => DataItem(
                                x: index + 1,
                                sumCost: valuesColor[3] ? zeroArray[index] : double.parse(sumCost[index].toStringAsFixed(2)),
                                sales: valuesColor[0] ? zeroArray[index] : sales[index],
                                purchases: valuesColor[1] ? zeroArray[index] : purchases[index],
                                expences: valuesColor[2] ? zeroArray[index] : expences[index],
                                profit: valuesColor[4] ? zeroArray[index] : profit[index]))
                        .map((dataItem) => BarChartGroupData(x: dataItem.x, barRods: [
                              BarChartRodData(borderRadius: BorderRadius.zero, toY: dataItem.sales, width: 15, color: Colors.red),
                              BarChartRodData(borderRadius: BorderRadius.zero, toY: dataItem.sumCost, width: 15, color: Colors.purple),
                              BarChartRodData(borderRadius: BorderRadius.zero, toY: dataItem.purchases, width: 15, color: Colors.amber),
                              BarChartRodData(borderRadius: BorderRadius.zero, toY: dataItem.expences, width: 15, color: Colors.blue),
                              BarChartRodData(borderRadius: BorderRadius.zero, toY: dataItem.profit, width: 15, color: Colors.green),
                            ]))
                        .toList(),
                    titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false, interval: 100),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (a, value) {
                              final int monthIndex = a.toInt();
                              if (monthIndex >= 1 && monthIndex <= 12) {
                                return Text(
                                  months[monthIndex - 1],
                                  style: const TextStyle(color: Colors.black, fontSize: 20),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector yearPicker(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Select Year"),
                content: SizedBox(
                  width: 300,
                  height: 300,
                  child: YearPicker(
                    firstDate: DateTime(DateTime.now().year - 10, 1),
                    lastDate: DateTime(DateTime.now().year + 100, 1),
                    initialDate: DateTime.now(),
                    selectedDate: selectedDateTime,
                    onChanged: (DateTime dateTime) {
                      setState(() {});
                      selectedDateTime = dateTime;
                      getData(dateTime, false);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: context.border.normalBorderRadius),
          child: Row(
            children: [
              const Text(
                "Select Year : ",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              Text(
                selectedDateTime!.year.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
            ],
          ),
        ));
  }

  Widget names({required String name, required Color color, required int index}) {
    return Expanded(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              valuesColor[index] = !valuesColor[index];
              setState(() {});
            },
            child: Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.only(right: 10.w),
              decoration: BoxDecoration(
                color: color,
                border: valuesColor[index] ? Border.all(color: Colors.grey, width: 4) : const Border(),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              valuesText[index] = !valuesText[index];
              profit = List.filled(12, 0.0);
              if (!valuesText[0]) {
                for (int i = 0; i <= 11; i++) {
                  profit[i] += sales[i];
                }
              }
              if (!valuesText[1]) {
                for (int i = 0; i <= 11; i++) {
                  profit[i] -= purchases[i];
                }
              }
              if (!valuesText[2]) {
                for (int i = 0; i <= 11; i++) {
                  profit[i] -= expences[i];
                }
              }
              findMinimumelement();
              setState(() {});
            },
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, decoration: valuesText[index] ? TextDecoration.lineThrough : TextDecoration.none, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
