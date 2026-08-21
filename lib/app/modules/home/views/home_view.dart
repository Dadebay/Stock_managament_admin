// ignore_for_file: deprecated_member_use

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
  DataItem(
      {required this.x,
      required this.sales,
      required this.sumCost,
      required this.purchases,
      required this.expences,
      required this.profit});
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

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  List<double> expences = List.filled(12, 0.0);
  List<double> sales = List.filled(12, 0.0);
  List<double> purchases = List.filled(12, 0.0);
  List<double> profit = List.filled(12, 0.0);
  List<double> sumCost = List.filled(12, 0.0);

  /// Total sales per year, aggregated from the same API payload that feeds
  /// the monthly chart. Used to show a total under each year in the picker.
  Map<int, double> yearlySales = {};

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
      void populateCategoryFromApi(
          String categoryKey, List<double> targetList) {
        if (apiChartData.containsKey(categoryKey) &&
            apiChartData[categoryKey] is Map) {
          final Map<String, dynamic> categoryData =
              apiChartData[categoryKey] as Map<String, dynamic>;
          categoryData.forEach((yearMonthKey, value) {
            try {
              final parts = yearMonthKey.split('-');
              if (parts.length == 2) {
                final year = int.tryParse(parts[0]);
                final month = int.tryParse(parts[1]);

                if (year != null &&
                    month != null &&
                    year == dateForYear.year &&
                    month >= 1 &&
                    month <= 12) {
                  if (value is num) {
                    targetList[month - 1] = value.toDouble();
                  }
                }
              }
            } catch (e) {
              debugPrint(
                  "Error parsing API chart data for key: $yearMonthKey, value: $value. Error: $e");
            }
          });
        }
      }

      populateCategoryFromApi('sales', sales);
      populateCategoryFromApi('sum_cost', sumCost);
      populateCategoryFromApi('purchases', purchases);
      populateCategoryFromApi('expences', expences);

      final salesByYearMonth = apiChartData['sales'];
      if (salesByYearMonth is Map) {
        final Map<int, double> totals = {};
        salesByYearMonth.forEach((yearMonthKey, value) {
          final parts = yearMonthKey.toString().split('-');
          final year = parts.length == 2 ? int.tryParse(parts[0]) : null;
          if (year != null && value is num) {
            totals[year] = (totals[year] ?? 0) + value.toDouble();
          }
        });
        yearlySales = totals;
      }
    } else {
      CustomWidgets.showSnackBar(
          'Error'.tr, 'Failed to load chart data from API.'.tr, Colors.red);
    }

    await _calculateProfitAndGenerateExcel(forExcelExport, dateForYear);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateProfitAndGenerateExcel(
      bool generateExcel, DateTime dateForReport) async {
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
      CustomWidgets.showSnackBar('Success'.tr,
          'Excel report generated for ${dateForReport.year}'.tr, Colors.green);
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

    double positiveMax = [
      maxElement1,
      maxElement2,
      maxElement3,
      maxElement4,
      maxElement5,
      0.0
    ].reduce(max);
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

  static const Color _accent = Color(0xFF4F46E5);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _pageBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 24, 24, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: BarChart(
                  BarChartData(
                      maxY: maxElement == 0
                          ? 100
                          : maxElement + (maxElement * 0.1).abs(),
                      minY: minElement1 -
                          (minElement1 *
                                  (minElement1.abs() < 1
                                      ? 1
                                      : (minElement1 < 0 ? 0.2 : 0.1)))
                              .abs(),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: (maxElement == 0
                                ? 100
                                : maxElement + (maxElement * 0.1).abs()) /
                            8,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: _border,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(touchTooltipData:
                          BarTouchTooltipData(
                              getTooltipColor: (_) => _ink,
                              tooltipRoundedRadius: 10,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
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
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                          children: <TextSpan>[
                            TextSpan(
                              text: "$rodLabel".tr +
                                  ': ${rod.toY.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      })),
                      barGroups: List.generate(
                              12,
                              (index) => DataItem(
                                  x: index + 1,
                                  sales: valuesColor[0] ? 0.0 : sales[index],
                                  sumCost: valuesColor[3] ? 0.0 : sumCost[index],
                                  purchases:
                                      valuesColor[1] ? 0.0 : purchases[index],
                                  expences:
                                      valuesColor[2] ? 0.0 : expences[index],
                                  profit: valuesColor[4] ? 0.0 : profit[index]))
                          .map((dataItem) => BarChartGroupData(x: dataItem.x, barRods: [
                                BarChartRodData(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                    toY: dataItem.sales,
                                    width: 12,
                                    color: Colors.red),
                                BarChartRodData(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                    toY: dataItem.sumCost,
                                    width: 12,
                                    color: Colors.purple),
                                BarChartRodData(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                    toY: dataItem.purchases,
                                    width: 12,
                                    color: Colors.amber),
                                BarChartRodData(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                    toY: dataItem.expences,
                                    width: 12,
                                    color: Colors.blue),
                                BarChartRodData(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                    toY: dataItem.profit,
                                    width: 12,
                                    color: Colors.green),
                              ]))
                          .toList(),
                      titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false, interval: 100),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 52,
                              getTitlesWidget: (value, meta) => Text(
                                value.abs() >= 1000
                                    ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K'
                                    : value.toStringAsFixed(0),
                                style: TextStyle(color: _muted, fontSize: 11.sp),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final int monthIndex = value.toInt() - 1;
                                if (monthIndex >= 0 && monthIndex < 12) {
                                  String monthName = months[monthIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      monthName.length >= 3
                                          ? monthName.substring(0, 3)
                                          : monthName,
                                      style: TextStyle(
                                          color: _muted,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600),
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
          ),
        ],
      ),
    );
  }

  Widget _pageBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                names(name: "salesChart", color: Colors.red, index: 0),
                const SizedBox(width: 4),
                names(name: "sumCostChart", color: Colors.purple, index: 3),
                const SizedBox(width: 4),
                names(
                    name: "purchases", color: Colors.amber.shade700, index: 1),
                const SizedBox(width: 4),
                names(name: "expences", color: Colors.blue, index: 2),
                const SizedBox(width: 4),
                names(name: "netProfit", color: Colors.green, index: 4),
              ]),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              yearPicker(context),
              if (widget.isAdmin) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async => exportToExcel(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 9, horizontal: 14),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(IconlyLight.download,
                            color: Colors.white, size: 15),
                        const SizedBox(width: 7),
                        Text(
                          "Export Excel".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  static const int _firstPickerYear = 2024;

  String _formatCompact(double value) {
    final abs = value.abs();
    if (abs >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return value.toStringAsFixed(0);
  }

  GestureDetector yearPicker(BuildContext context) {
    return GestureDetector(
        onTap: () {
          final int lastYear = max(DateTime.now().year + 3, _firstPickerYear);
          final years = [
            for (int y = _firstPickerYear; y <= lastYear; y++) y
          ];
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return Dialog(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                child: SizedBox(
                  width: 340,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Select Year'.tr,
                                  style: TextStyle(
                                      color: _ink,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700)),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.close_rounded,
                                  color: _muted, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: _border),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: years.map((year) {
                                final selected = selectedDateTime.year == year;
                                final total = yearlySales[year];
                                return GestureDetector(
                                  onTap: () {
                                    final newDate = DateTime(year, 1);
                                    if (mounted) {
                                      setState(() {
                                        selectedDateTime = newDate;
                                      });
                                    }
                                    getData(newDate, false);
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Container(
                                    width: 92,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? _accent
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: selected ? _accent : _border),
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(year.toString(),
                                            style: TextStyle(
                                                color: selected
                                                    ? Colors.white
                                                    : _ink,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700)),
                                        if (total != null && total > 0) ...[
                                          const SizedBox(height: 2),
                                          Text(_formatCompact(total),
                                              style: TextStyle(
                                                  color: selected
                                                      ? Colors.white
                                                          .withOpacity(.85)
                                                      : Colors.red,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(IconlyLight.calendar, color: _accent, size: 16),
              const SizedBox(width: 8),
              Text(
                selectedDateTime.year.toString(),
                style: TextStyle(
                    color: _ink, fontSize: 13.5.sp, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more_rounded, color: _muted, size: 15),
            ],
          ),
        ));
  }

  Widget names(
      {required String name, required Color color, required int index}) {
    final bool hidden = valuesColor[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: hidden ? const Color(0xFFF8FAFC) : color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hidden ? _border : color.withOpacity(.3)),
      ),
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
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: hidden ? Colors.transparent : color,
                border: Border.all(color: hidden ? _muted : color, width: 1.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: hidden
                  ? Icon(Icons.visibility_off_outlined,
                      size: 6, color: _muted)
                  : null,
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
                  color: hidden ? _muted : _ink,
                  decoration: valuesText[index]
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
