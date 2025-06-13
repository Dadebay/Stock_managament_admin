import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/views/order_products_view.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

// ignore: must_be_immutable
class OrderCardView extends StatelessWidget {
  OrderCardView({Key? key, required this.order, required this.index, required this.isAdmin}) : super(key: key);
  final OrderModel order;
  final int index;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => OrderProductsView(
            order: order,
            isAdmin: isAdmin,
          )),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 10.h, bottom: 10.h, right: 15.w),
        child: Row(
          children: [
            CustomWidgets.counter(index),
            Expanded(
              flex: 5,
              child: Text(
                "${order.clientDetailModel?.name}  -  ${order.clientDetailModel?.phone!.replaceAll("+993", "")}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
                flex: 2,
                child: Text(
                  order.date.isNotEmpty ? order.date.substring(0, 10) : '',
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                )),
            Expanded(
              flex: 2,
              child: Text(
                order.count.toString(),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "${order.totalsum.toString()} \$",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "${order.totalchykdajy.toString()} \$",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: StringConstants.statusMapping.firstWhere((s) => s['sortName'] == order.status)['color']?.withOpacity(0.15),
                    border: Border.all(color: StringConstants.statusMapping.firstWhere((s) => s['sortName'] == order.status)['color'] ?? Colors.transparent, width: 1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "${StringConstants.statusMapping.firstWhere((s) => s['sortName'] == order.status)['name']}".tr,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: StringConstants.statusMapping.firstWhere((s) => s['sortName'] == order.status)['color'], fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
