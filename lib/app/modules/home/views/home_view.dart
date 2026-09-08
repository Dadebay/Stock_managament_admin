// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:excel/excel.dart' as ex;
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_service.dart';
import 'package:stock_managament_admin/app/product/excel_export.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

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

    try {
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
        throw StateError('Failed to load chart data from API.');
      }

      await _calculateProfitAndGenerateExcel(forExcelExport, dateForYear);
    } catch (error) {
      debugPrint('Failed to load or export financial report: $error');
      CustomWidgets.showSnackBar(
          'Error'.tr, 'Failed to generate Excel report.'.tr, Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      final now = DateTime.now();
      final lastAvailableMonth = dateForReport.year < now.year
          ? 12
          : dateForReport.year == now.year
              ? now.month
              : 0;
      final includedMonths = <int>[
        for (int i = 0; i < lastAvailableMonth; i++)
          if (sales[i] != 0 ||
              purchases[i] != 0 ||
              expences[i] != 0 ||
              sumCost[i] != 0)
            i,
      ];

      final summarySheet = excel['Sheet1'];
      summarySheet.appendRow([
        'Month',
        'Sales',
        'Purchases',
        'Expenses',
        'Sum Cost (COGS)',
        'Net Profit',
      ]);
      for (final i in includedMonths) {
        summarySheet.appendRow([
          months[i],
          sales[i],
          purchases[i],
          expences[i],
          sumCost[i],
          profit[i],
        ]);
      }
      summarySheet.appendRow([
        'Total',
        includedMonths.fold<double>(0, (sum, i) => sum + sales[i]),
        includedMonths.fold<double>(0, (sum, i) => sum + purchases[i]),
        includedMonths.fold<double>(0, (sum, i) => sum + expences[i]),
        includedMonths.fold<double>(0, (sum, i) => sum + sumCost[i]),
        includedMonths.fold<double>(0, (sum, i) => sum + profit[i]),
      ]);

      for (final i in includedMonths) {
        ex.Sheet sheetObject = excel[months[i]];
        sheetObject.appendRow(["Item", "Amount"]);
        sheetObject.appendRow(["Sales", sales[i]]);
        sheetObject.appendRow(["Purchases", purchases[i]]);
        sheetObject.appendRow(["Expenses", expences[i]]);
        sheetObject.appendRow(["Sum Cost (COGS)", sumCost[i]]);
        sheetObject.appendRow(["Net Profit", profit[i]]);
      }

      await downloadExcel(
        excel,
        '${dateForReport.year}_financial_report.xlsx',
        chart: includedMonths.isEmpty
            ? null
            : ExcelChartSpec(
                sheetName: 'Sheet1',
                title: 'Monthly Financial Summary',
                categoryColumn: 'A',
                categories: [for (final i in includedMonths) months[i]],
                firstDataRow: 2,
                // The Total row is styled like the data but stays out of the
                // chart's range.
                totalRow: 2 + includedMonths.length,
                series: [
                  ExcelChartSeries(
                      column: 'B',
                      name: 'Sales',
                      colorHex: 'EF4444',
                      values: [for (final i in includedMonths) sales[i]]),
                  ExcelChartSeries(
                      column: 'C',
                      name: 'Purchases',
                      colorHex: 'F59E0B',
                      values: [for (final i in includedMonths) purchases[i]]),
                  ExcelChartSeries(
                      column: 'D',
                      name: 'Expenses',
                      colorHex: '3B82F6',
                      values: [for (final i in includedMonths) expences[i]]),
                  ExcelChartSeries(
                      column: 'E',
                      name: 'Sum Cost (COGS)',
                      colorHex: '8B5CF6',
                      values: [for (final i in includedMonths) sumCost[i]]),
                  // Net profit is plotted as a column like the other series,
                  // on the same axis.
                  ExcelChartSeries(
                      column: 'F',
                      name: 'Net Profit',
                      colorHex: '22C55E',
                      values: [for (final i in includedMonths) profit[i]]),
                ],
              ),
      );
      CustomWidgets.showSnackBar('Success'.tr,
          'Excel report generated for ${dateForReport.year}'.tr, Colors.green);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Recomputes the axis bounds for the currently visible series.
  void findMinimumelement() {
    double maxV = 0;
    double minV = 0;
    for (int i = 0; i < 12; i++) {
      for (int s = 0; s < 5; s++) {
        if (valuesColor[s]) continue;
        final v = _seriesValue(s, i);
        if (v > maxV) maxV = v;
        if (v < minV) minV = v;
      }
    }

    final step = _niceStep(maxV - minV);
    _axisStep = step;
    _axisMax = maxV <= 0 ? step * 4 : (maxV / step).ceil() * step;
    _axisMin = minV >= 0 ? 0 : (minV / step).floor() * step;
  }

  Future<void> exportToExcel(BuildContext context) async {
    await getData(selectedDateTime, true);
  }

  /// Axis bounds, recomputed by [findMinimumelement] whenever data or the
  /// visible series change.
  double _axisMax = 100;
  double _axisMin = 0;
  double _axisStep = 20;

  /// Index of the month group under the pointer, `-1` when nothing is touched.
  int _touchedGroup = -1;

  List<bool> valuesColor = [false, false, false, false, false];
  List<bool> valuesText = [false, false, false, false, false];

  static const Color _accent = Color(0xFF4F46E5);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _negative = Color(0xFFE11D48);

  /// Series are indexed the same way as [valuesColor] / [valuesText]:
  /// 0 sales, 1 purchases, 2 expenses, 3 sum cost, 4 net profit.
  static const List<Color> _seriesColors = [
    Color(0xFF4F46E5), // sales      - indigo
    Color(0xFFF59E0B), // purchases  - amber
    Color(0xFF0EA5E9), // expenses   - sky
    Color(0xFF8B5CF6), // sum cost   - violet
    Color(0xFF10B981), // net profit - emerald
  ];

  static const List<String> _seriesKeys = [
    'salesChart',
    'purchases',
    'expences',
    'sumCostChart',
    'netProfit',
  ];

  /// Left-to-right order of the rods inside a month group.
  static const List<int> _rodOrder = [0, 3, 1, 2, 4];

  double _seriesValue(int series, int month) {
    switch (series) {
      case 0:
        return sales[month];
      case 1:
        return purchases[month];
      case 2:
        return expences[month];
      case 3:
        return sumCost[month];
      default:
        return profit[month];
    }
  }

  double _seriesTotal(int series) {
    double total = 0;
    for (int i = 0; i < 12; i++) {
      total += _seriesValue(series, i);
    }
    return total;
  }

  Color _colorOf(int series, double value) =>
      series == 4 && value < 0 ? _negative : _seriesColors[series];

  /// A "nice" grid step (1, 2, 2.5 or 5 × a power of ten) aiming for roughly
  /// [_targetTickCount] labels, so the axis never jumps straight from 0 to -2K.
  static const int _targetTickCount = 9;

  double _niceStep(double range) {
    if (range <= 0) return 20;
    final raw = range / _targetTickCount;
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    final normalized = raw / magnitude;
    final double factor = normalized <= 1
        ? 1
        : normalized <= 2
            ? 2
            : normalized <= 2.5
                ? 2.5
                : normalized <= 5
                    ? 5
                    : 10;
    return factor * magnitude;
  }

  /// Axis labels share one unit so the scale reads consistently
  /// (`-1.5K / -1K / -0.5K / 0 / 0.5K`), instead of mixing K and plain numbers.
  String _formatAxis(double value) {
    if (value == 0) return '0';
    final bool useK = _axisMax >= 1000 || _axisMin <= -1000;
    if (!useK) {
      return value.abs() < 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
    }
    final scaled = value / 1000;
    final decimals = _axisStep >= 1000 ? 0 : (_axisStep >= 100 ? 1 : 2);
    return '${scaled.toStringAsFixed(decimals)}K';
  }

  String _formatMoney(double value) {
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(value.abs() < 100 ? 2 : 0);
    final parts = fixed.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
    return negative ? '-$text' : text;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    findMinimumelement();
    final double outerPad = MediaQuery.of(context).size.width < 480 ? 12 : 20;
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _pageBar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(outerPad, 16, outerPad, outerPad),
              child: Container(
                width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _summaryStrip(),
                    const Divider(height: 1, color: _border),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool compact = constraints.maxWidth < 560;
                          // 12 groups × 5 rods need room; below that the chart
                          // scrolls horizontally instead of squashing the bars.
                          const double minChartWidth = 640;
                          final double chartWidth =
                              constraints.maxWidth < minChartWidth
                                  ? minChartWidth
                                  : constraints.maxWidth;
                          final chart = Padding(
                            padding: EdgeInsets.fromLTRB(
                                compact ? 4 : 8, 24, compact ? 12 : 24, 8),
                            child: _chart(chartWidth),
                          );
                          if (constraints.maxWidth >= minChartWidth) {
                            return chart;
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                                width: minChartWidth,
                                height: constraints.maxHeight,
                                child: chart),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Year-to-date totals per series, so negative results stay readable even
  /// when the bar itself is tiny.
  Widget _summaryStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = [
            for (final series in _rodOrder) _summaryTile(series),
          ];
          final width = constraints.maxWidth;
          if (width >= 900) {
            return Row(
              children: [
                for (int i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: tiles[i]),
                ],
              ],
            );
          }
          // Fixed column counts keep the tiles aligned in a grid rather than
          // leaving a ragged last row.
          final int columns = width >= 620 ? 3 : (width >= 380 ? 2 : 1);
          const double gap = 10;
          final double tileWidth =
              (width - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final tile in tiles)
                SizedBox(width: tileWidth, child: tile),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryTile(int series) {
    final total = _seriesTotal(series);
    final color = _colorOf(series, total);
    final hidden = valuesColor[series];
    return Opacity(
      opacity: hidden ? .45 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _seriesKeys[series].tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _muted,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _formatMoney(total),
                style: TextStyle(
                    color: total < 0 ? _negative : _ink,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chart(double availableWidth) {
    // Leave room for the value axis, then split what is left across the
    // 12 month groups so bars stay legible on any window size.
    final double perGroup = ((availableWidth - 72) / 12).clamp(24.0, 90.0);
    final double barWidth = ((perGroup - 14) / 5).clamp(5.0, 14.0);
    return BarChart(
      BarChartData(
        maxY: _axisMax,
        minY: _axisMin,
        groupsSpace: 10,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: _axisStep,
          getDrawingHorizontalLine: (value) => FlLine(
            color: _border,
            strokeWidth: 1,
            dashArray: value == 0 ? null : [4, 4],
          ),
        ),
        // Solid baseline so bars that drop below zero read clearly.
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: _ink.withOpacity(.35),
              strokeWidth: 1.2,
            ),
          ],
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchExtraThreshold: const EdgeInsets.symmetric(vertical: 24),
          touchCallback: (event, response) {
            final index = response?.spot?.touchedBarGroupIndex ?? -1;
            final touching = event.isInterestedForInteractions && index >= 0;
            final next = touching ? index : -1;
            if (next != _touchedGroup && mounted) {
              setState(() => _touchedGroup = next);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => _ink,
            tooltipRoundedRadius: 12,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            tooltipMargin: 12,
            maxContentWidth: 280,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                _tooltipFor(group.x.toInt() - 1),
          ),
        ),
        barGroups: List.generate(12, (month) {
          final touched = _touchedGroup == month;
          return BarChartGroupData(
            x: month + 1,
            barsSpace: 3,
            barRods: [
              for (final series in _rodOrder)
                _rod(series, month, touched: touched, width: barWidth),
            ],
          );
        }),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _axisStep,
              reservedSize: 56,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _formatAxis(value),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: value < 0 ? _negative : _muted,
                    fontSize: 10.5.sp,
                    fontWeight: value == 0 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                final int monthIndex = value.toInt() - 1;
                if (monthIndex < 0 || monthIndex > 11) return const Text('');
                final bool active = _touchedGroup == monthIndex;
                final String name = months[monthIndex];
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: active ? _ink : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      name.length >= 3 ? name.substring(0, 3) : name,
                      style: TextStyle(
                          color: active ? Colors.white : _muted,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 320),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  BarChartRodData _rod(int series, int month,
      {required bool touched, required double width}) {
    final hidden = valuesColor[series];
    final value = hidden ? 0.0 : _seriesValue(series, month);
    final color = _colorOf(series, value);
    const radius = Radius.circular(4);
    return BarChartRodData(
      toY: value,
      width: width,
      // Round the end that points away from the baseline, so negative bars
      // are not drawn upside down.
      borderRadius: value < 0
          ? const BorderRadius.vertical(bottom: radius)
          : const BorderRadius.vertical(top: radius),
      color: touched ? color : color.withOpacity(.88),
      backDrawRodData: BackgroundBarChartRodData(
        show: touched,
        fromY: _axisMin,
        toY: _axisMax,
        color: _surface,
      ),
    );
  }

  /// One tooltip per month listing every series, so values that fall below
  /// zero are always readable even when their bar is clipped by the axis.
  BarTooltipItem _tooltipFor(int month) {
    final visible = _rodOrder.where((s) => !valuesColor[s]).toList();
    return BarTooltipItem(
      '${months[month]} ${selectedDateTime.year}\n',
      TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12.5.sp,
      ),
      textAlign: TextAlign.left,
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          TextSpan(
            text: '\n●  ',
            style: TextStyle(
              color: _colorOf(visible[i], _seriesValue(visible[i], month)),
              fontSize: 11.sp,
            ),
          ),
          TextSpan(
            text: '${_seriesKeys[visible[i]].tr}  ',
            style: TextStyle(
              color: Colors.white.withOpacity(.72),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: _formatMoney(_seriesValue(visible[i], month)),
            style: TextStyle(
              color: _seriesValue(visible[i], month) < 0
                  ? const Color(0xFFFF8FA3)
                  : Colors.white,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _pageBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Below this width the legend and the controls no longer fit on a
          // single line, so they stack instead of being clipped.
          final bool stacked = constraints.maxWidth < 760;
          final legend = _legend();
          final controls = _controls();
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerRight, child: controls),
                const SizedBox(height: 10),
                legend,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: legend),
              const SizedBox(width: 16),
              controls,
            ],
          );
        },
      ),
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final series in _rodOrder)
          names(
              name: _seriesKeys[series],
              color: _seriesColors[series],
              index: series),
      ],
    );
  }

  Widget _controls() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        yearPicker(context),
        if (widget.isAdmin)
          GestureDetector(
            onTap: () async => exportToExcel(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
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
          final years = [for (int y = _firstPickerYear; y <= lastYear; y++) y];
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                child: SizedBox(
                  // Never wider than the screen on small windows.
                  width: min(340.0, MediaQuery.of(dialogContext).size.width - 48),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
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
                    color: _ink,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: hidden ? _surface : color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: hidden ? _border : color.withOpacity(.35)),
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
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: hidden ? Colors.transparent : color,
                border: Border.all(color: hidden ? _muted : color, width: 1.4),
                borderRadius: BorderRadius.circular(3),
              ),
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
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
