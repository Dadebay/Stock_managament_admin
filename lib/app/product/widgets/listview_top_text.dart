import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ListviewTopText extends StatefulWidget {
  final List<Map<String, String>> names;
  final bool hideLastColumn;
  final List<dynamic> listToSort;

  const ListviewTopText({
    super.key,
    required this.names,
    required this.listToSort,
    this.hideLastColumn = false,
  });

  @override
  State<ListviewTopText> createState() => _ListviewTopTextState();
}

class _ListviewTopTextState extends State<ListviewTopText> {
  late List<bool> sortStates;
  late List<dynamic> currentList;

  @override
  void initState() {
    super.initState();
    sortStates = List.filled(widget.names.length, false);
    currentList = [...widget.listToSort];
  }

  void sortList(int index, String sortKey, bool isDouble) {
    final bool ascending = !sortStates[index];
    widget.listToSort.forEach((element) {
      print(element['address']);
    });
    print(sortKey);
    currentList.sort((a, b) {
      final aVal = a[sortKey];
      final bVal = b[sortKey];
      if (isDouble) {
        final double aNum = double.tryParse((aVal ?? '0').toString().replaceAll(',', '.')) ?? 0.0;
        final double bNum = double.tryParse((bVal ?? '0').toString().replaceAll(',', '.')) ?? 0.0;
        return ascending ? aNum.compareTo(bNum) : bNum.compareTo(aNum);
      } else {
        return ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      }
    });

    setState(() {
      sortStates[index] = !sortStates[index];
    });
    print(currentList);
  }

  Widget buildSortButton({
    required int index,
    required String text,
    required String sortKey,
    required bool isDouble,
    required int flex,
    required bool textAlign,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => sortList(index, sortKey, isDouble),
        child: Text(
          text,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final names = widget.names;

    return Container(
      padding: context.padding.normal.copyWith(left: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 2.0, // Kalınlık
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < names.length; i++)
            if (!(widget.hideLastColumn && i == names.length - 1))
              buildSortButton(index: i, text: names[i]['name']!, sortKey: names[i]['sortName']!, isDouble: _isDoubleField(names[i]['sortName']!), flex: CustomWidgets().getFlexForSize(names[i]['size']!), textAlign: names[i]['size'] == ColumnSize.medium.toString() ? true : false),
        ],
      ),
    );
  }

  bool _isDoubleField(String field) {
    return ["price", "cost", "sum", "product_count"].contains(field);
  }
}
