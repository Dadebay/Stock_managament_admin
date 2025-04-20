import 'package:stock_managament_admin/app/data/models/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/views/sales_products_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

// ignore: must_be_immutable
class OrderedCard extends StatelessWidget {
  OrderedCard({Key? key, required this.order}) : super(key: key);
  final OrderModel order;
  Map<String, Color> colorMapping = {"shipped": Colors.green, "canceled": Colors.red, "refund": Colors.red, "preparing": ColorConstants.kPrimaryColor2, "readyToShip": Colors.purple, "ready to ship": Colors.purple};

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
          return SalesProductsView(order: order);
        }));
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                "${order.clientName!}  -  ${order.clientNumber!}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 14.sp),
              ),
            ),
            Expanded(
                child: Text(
              order.date!.substring(0, 10),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            )),
            Expanded(
              child: Text(
                order.products!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            Expanded(
              child: Text(
                "${order.sumPrice} \$",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            Expanded(
              child: Text(
                "${double.parse(order.sumCost.toString()).toStringAsFixed(2)} \$",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorMapping[order.status.toString().toLowerCase()]!.withOpacity(0.15), borderRadius: context.border.normalBorderRadius),
                child: Text(
                  "${order.status}",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorMapping[order.status.toString().toLowerCase()], fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
