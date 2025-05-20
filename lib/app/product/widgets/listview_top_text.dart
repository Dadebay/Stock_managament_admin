import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ListviewTopText<T> extends StatefulWidget {
  final List<Map<String, String>> names;
  final bool hideLastColumn;
  final List<T> listToSort;
  final void Function(List<T> newList) setSortedList;
  final dynamic Function(T item, String sortKey) getSortValue;

  const ListviewTopText({
    super.key,
    required this.names,
    required this.listToSort,
    required this.setSortedList,
    required this.getSortValue,
    this.hideLastColumn = false,
  });

  @override
  State<ListviewTopText> createState() => _ListviewTopTextState<T>();
}

class _ListviewTopTextState<T> extends State<ListviewTopText<T>> {
  late List<bool> sortStates;
  int? _currentSortIndex;

  @override
  void initState() {
    super.initState();
    sortStates = List.filled(widget.names.length, false);
  }

  void _handleSortTap(int index, String sortKey) {
    bool ascending = true;

    if (_currentSortIndex == index) {
      ascending = !sortStates[index];
    } else {
      if (_currentSortIndex != null) sortStates[_currentSortIndex!] = false;
    }

    setState(() {
      sortStates[index] = ascending;
      _currentSortIndex = index;
    });

    List<T> sortedList = List<T>.from(widget.listToSort);
    // sortedList.sort((a, b) {
    //   var aVal = widget.getSortValue(a, sortKey);
    //   var bVal = widget.getSortValue(b, sortKey);

    //   if (aVal is num && bVal is num) {
    //     return ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    //   } else if (_isNumericString(aVal) && _isNumericString(bVal)) {
    //     final aNum = double.tryParse(aVal.toString().replaceAll(',', '.')) ?? 0;
    //     final bNum = double.tryParse(bVal.toString().replaceAll(',', '.')) ?? 0;
    //     return ascending ? aNum.compareTo(bNum) : bNum.compareTo(aNum);
    //   } else {
    //     return ascending ? aVal.toString().compareTo(bVal.toString()) : bVal.toString().compareTo(aVal.toString());
    //   }
    // });
    sortedList.sort((a, b) {
      final aVal = widget.getSortValue(a, sortKey);
      final bVal = widget.getSortValue(b, sortKey);

      final aNum = _parseToDouble(aVal);
      final bNum = _parseToDouble(bVal);

      if (aNum != null && bNum != null) {
        return ascending ? aNum.compareTo(bNum) : bNum.compareTo(aNum);
      }

      final aStr = aVal?.toString() ?? '';
      final bStr = bVal?.toString() ?? '';

      return ascending ? aStr.compareTo(bStr) : bStr.compareTo(aStr);
    });

    widget.setSortedList(sortedList);
  }

  double? _parseToDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) {
      return double.tryParse(val.replaceAll(',', '.'));
    }
    return null;
  }

  bool _isNumericString(dynamic value) {
    return double.tryParse(value.toString().replaceAll(',', '.')) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < widget.names.length; i++)
            if (!(widget.hideLastColumn && i == widget.names.length - 1))
              Expanded(
                flex: CustomWidgets().getFlexForSize(widget.names[i]['size'] ?? ColumnSize.medium.toString()),
                child: GestureDetector(
                  onTap: () => _handleSortTap(i, widget.names[i]['sortName']!),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          widget.names[i]['name']!,
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_currentSortIndex == i)
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Icon(
                            sortStates[i] ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16.sp,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
