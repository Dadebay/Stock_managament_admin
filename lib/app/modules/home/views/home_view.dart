import 'dart:math';

import 'package:excel/excel.dart' as ex;
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_service.dart';
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
  const HomeView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeService _homeService = HomeService();
  bool _isLoading = false;

  List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  List<double> expences = List.filled(12, 0.0);
  List<double> sales = List.filled(12, 0.0);
  List<double> purchases = List.filled(12, 0.0);
  List<double> profit = List.filled(12, 0.0);
  List<double> sumCost = List.filled(12, 0.0);

  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    getData(selectedDateTime, false);
  }

  Future<void> getData(DateTime dateForYear, bool forExcelExport) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    expences = List.filled(12, 0.0);
    sales = List.filled(12, 0.0);
    purchases = List.filled(12, 0.0);
    sumCost = List.filled(12, 0.0);
    profit = List.filled(12, 0.0);

    final apiChartData = await _homeService.getChartPageData();

    if (apiChartData != null) {
      void populateCategoryFromApi(String categoryKey, List<double> targetList) {
        if (apiChartData.containsKey(categoryKey) && apiChartData[categoryKey] is Map) {
          final Map<String, dynamic> categoryData = apiChartData[categoryKey] as Map<String, dynamic>;
          categoryData.forEach((yearMonthKey, value) {
            try {
              final parts = yearMonthKey.split('-');
              if (parts.length == 2) {
                final year = int.tryParse(parts[0]);
                final month = int.tryParse(parts[1]);

                if (year != null && month != null && year == dateForYear.year && month >= 1 && month <= 12) {
                  if (value is num) {
                    targetList[month - 1] = value.toDouble();
                  }
                }
              }
            } catch (e) {
              debugPrint("Error parsing API chart data for key: $yearMonthKey, value: $value. Error: $e");
            }
          });
        }
      }

      populateCategoryFromApi('sales', sales);
      populateCategoryFromApi('sum_cost', sumCost);
      populateCategoryFromApi('purchases', purchases);
      populateCategoryFromApi('expences', expences);
    } else {
      CustomWidgets.showSnackBar('Error'.tr, 'Failed to load chart data from API.'.tr, Colors.red);
    }

    await _calculateProfitAndGenerateExcel(forExcelExport, dateForYear);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateProfitAndGenerateExcel(bool generateExcel, DateTime dateForReport) async {
    profit = List.filled(12, 0.0);
    for (int i = 0; i < 12; i++) {
      // profit[i] = sales[i] - (purchases[i] + expences[i] + sumCost[i]);
      profit[i] = sales[i] - (purchases[i] + expences[i]);
    }
    findMinimumelement();

    if (generateExcel) {
      var excel = ex.Excel.createExcel();
      for (int i = 0; i < 12; i++) {
        ex.Sheet sheetObject = excel[months[i]];
        sheetObject.appendRow(["Item", "Amount"]);
        sheetObject.appendRow(["Sales", sales[i]]);
        sheetObject.appendRow(["Purchases", purchases[i]]);
        sheetObject.appendRow(["Expenses", expences[i]]);
        sheetObject.appendRow(["Sum Cost (COGS)", sumCost[i]]);
        sheetObject.appendRow(["Net Profit", profit[i]]);
      }

      excel.save(fileName: "${dateForReport.year}_financial_report.xlsx");
      CustomWidgets.showSnackBar('Success'.tr, 'Excel report generated for ${dateForReport.year}'.tr, Colors.green);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void findMinimumelement() {
    minElement1 = profit.isNotEmpty ? profit.reduce(min) : 0.0;
    maxElement1 = sales.isNotEmpty ? sales.reduce(max) : 0.0;
    maxElement2 = profit.isNotEmpty ? profit.reduce(max) : 0.0;
    maxElement3 = expences.isNotEmpty ? expences.reduce(max) : 0.0;
    maxElement4 = purchases.isNotEmpty ? purchases.reduce(max) : 0.0;

    double maxElement5 = sumCost.isNotEmpty ? sumCost.reduce(max) : 0.0;

    double positiveMax = [maxElement1, maxElement2, maxElement3, maxElement4, maxElement5, 0.0].reduce(max);
    maxElement = positiveMax;
  }

  Future<void> exportToExcel(BuildContext context) async {
    await getData(selectedDateTime, true);
  }

  double maxElement1 = 0.0;
  double maxElement3 = 0.0;
  double maxElement4 = 0.0;
  double minElement1 = 0.0;
  double maxElement2 = 0.0;
  double maxElement = 0.0;

  List<bool> valuesColor = [false, false, false, false, false];
  List<bool> valuesText = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: names(name: "salesChart", color: Colors.red, index: 0)),
                Expanded(child: names(name: "sumCostChart", color: Colors.purple, index: 3)),
                Expanded(child: names(name: "purchases", color: Colors.amber, index: 1)),
                Expanded(child: names(name: "expences", color: Colors.blue, index: 2)),
                Expanded(child: names(name: "netProfit", color: Colors.green, index: 4)),
                const SizedBox(width: 20),
                yearPicker(context),
                const SizedBox(width: 10),
                widget.isAdmin
                    ? GestureDetector(
                        onTap: () async {
                          await exportToExcel(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            "Export Excel".tr,
                            style: TextStyle(color: Colors.amber, fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: BarChart(
                BarChartData(
                    maxY: maxElement == 0 ? 100 : maxElement + (maxElement * 0.1).abs(),
                    minY: minElement1 - (minElement1 * (minElement1.abs() < 1 ? 1 : (minElement1 < 0 ? 0.2 : 0.1))).abs(),
                    barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String month = months[group.x.toInt() - 1];
                      String rodLabel = '';
                      switch (rodIndex) {
                        case 0:
                          rodLabel = 'salesChart';
                          break;
                        case 1:
                          rodLabel = 'sumCostChart';
                          break;
                        case 2:
                          rodLabel = 'purchases';
                          break;
                        case 3:
                          rodLabel = 'expences';
                          break;
                        case 4:
                          rodLabel = 'netProfit';
                          break;
                      }
                      return BarTooltipItem(
                        '$month\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                            text: "$rodLabel".tr + ': ${rod.toY.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    })),
                    barGroups: List.generate(
                            12,
                            (index) =>
                                DataItem(x: index + 1, sales: valuesColor[0] ? 0.0 : sales[index], sumCost: valuesColor[3] ? 0.0 : sumCost[index], purchases: valuesColor[1] ? 0.0 : purchases[index], expences: valuesColor[2] ? 0.0 : expences[index], profit: valuesColor[4] ? 0.0 : profit[index]))
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
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final int monthIndex = value.toInt() - 1;
                              if (monthIndex >= 0 && monthIndex < 12) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[monthIndex].substring(0, 3),
                                    style: TextStyle(color: Colors.black, fontSize: 14.sp),
                                  ),
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
                title: Text("Select Year".tr),
                content: SizedBox(
                  width: 300,
                  height: 300,
                  child: YearPicker(
                    firstDate: DateTime(DateTime.now().year - 10, 1),
                    lastDate: DateTime(DateTime.now().year + 10, 1),
                    initialDate: selectedDateTime,
                    selectedDate: selectedDateTime,
                    onChanged: (DateTime dateTime) {
                      if (mounted) {
                        setState(() {
                          selectedDateTime = dateTime;
                        });
                      }
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${"Year".tr}: ",
                style: TextStyle(color: Colors.amber, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                selectedDateTime.year.toString(),
                style: TextStyle(color: Colors.amber, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));
  }

  Widget names({required String name, required Color color, required int index}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() {
                  valuesColor[index] = !valuesColor[index];
                });
              }
            },
            child: Container(
              width: 20.w,
              height: 20.h,
              margin: EdgeInsets.only(right: 6.w),
              decoration: BoxDecoration(
                color: valuesColor[index] ? Colors.grey.shade300 : color,
                border: valuesColor[index] ? Border.all(color: color, width: 2) : Border.all(color: color.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: valuesColor[index] ? Icon(Icons.visibility_off_outlined, size: 14.sp, color: color) : null,
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    valuesText[index] = !valuesText[index];

                    profit = List.filled(12, 0.0);

                    if (!valuesText[0]) {
                      for (int i = 0; i < 12; i++) profit[i] += sales[i];
                    }

                    if (!valuesText[1]) {
                      for (int i = 0; i < 12; i++) profit[i] -= purchases[i];
                    }
                    if (!valuesText[2]) {
                      for (int i = 0; i < 12; i++) profit[i] -= expences[i];
                    }

                    if (!valuesText[3]) {
                      for (int i = 0; i < 12; i++) profit[i] -= sumCost[i];
                    }

                    findMinimumelement();
                  });
                }
              },
              child: Text(
                name.tr,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  decoration: valuesText[index] ? TextDecoration.lineThrough : TextDecoration.none,
                  fontSize: 16.sp,
                  fontWeight: valuesColor[index] ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
