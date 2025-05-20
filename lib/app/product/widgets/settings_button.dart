// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class IndicatorButton extends StatelessWidget {
  final String name;
  final Function() onTap;
  const IndicatorButton({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: ColorConstants.blackColor, borderRadius: BorderRadius.circular(15)),
        child: Text(
          name.tr,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: Colors.yellow, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
