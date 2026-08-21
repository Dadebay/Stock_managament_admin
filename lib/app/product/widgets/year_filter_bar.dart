import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

/// Horizontal row of year chips used to slice a list by year.
///
/// Each chip carries the year's own total underneath it, so the bar doubles as
/// a year-by-year breakdown rather than being a bare filter control.
class YearFilterBar extends StatelessWidget {
  const YearFilterBar({
    required this.years,
    required this.selectedYear,
    required this.onSelected,
    required this.totalForYear,
    required this.totalForAll,
    this.height = 74,
    this.showBorder = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.verticalPadding = 8,
    this.dense = false,
    super.key,
  });

  final List<String> years;
  final String? selectedYear;
  final ValueChanged<String?> onSelected;
  final double Function(String year) totalForYear;
  final double totalForAll;
  final double height;
  final bool showBorder;
  final EdgeInsets padding;
  final double verticalPadding;
  final bool dense;

  static const Color _accent = Color(0xFF16A34A);
  static const Color _idleBorder = Color(0xFFE2E8F0);
  static const Color _idleText = Color(0xFF475569);
  static const Color _mutedText = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    if (years.length < 2) return const SizedBox.shrink();

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: _idleBorder)),
            )
          : null,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: years.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _chip(
              label: 'allYears'.tr,
              total: totalForAll,
              isSelected: selectedYear == null,
              onTap: () => onSelected(null),
            );
          }
          final year = years[index - 1];
          return _chip(
            label: year,
            total: totalForYear(year),
            isSelected: selectedYear == year,
            onTap: () => onSelected(year),
          );
        },
      ),
    );
  }

  Widget _chip({
    required String label,
    required double total,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? _accent : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _accent : _idleBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: (dense ? 11 : 14).sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : _idleText,
                ),
              ),
              SizedBox(height: dense ? 0 : 2),
              Text(
                '${total.toStringAsFixed(0)} \$',
                style: TextStyle(
                  fontSize: (dense ? 9.5 : 11.5).sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white.withValues(alpha: 0.85) : _mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
