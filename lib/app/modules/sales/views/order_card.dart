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

  /// Status (durum) bilgisini güvenli bir şekilde almak için yardımcı fonksiyon.
  /// `firstWhere` metoduna `orElse` ekleyerek bilinmeyen bir status değeri gelirse
  /// uygulamanın çökmesini engeller ve varsayılan bir renk/isim döndürür.
  Map<String, dynamic> _getSafeStatusInfo() {
    return StringConstants.statusMapping.firstWhere(
      (s) => s['sortName'] == order.status,
      orElse: () => {
        'name': 'Unknown', // Varsayılan isim
        'color': Colors.grey, // Varsayılan renk
        'sortName': 0
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Status bilgilerini widget'ın en başında bir kez ve güvenli bir şekilde alalım.
    final statusInfo = _getSafeStatusInfo();
    final Color statusColor = statusInfo['color'] as Color;
    final String statusName = statusInfo['name'] as String;

    // Telefon numarasını null kontolü yaparak güvenli bir şekilde alalım.
    final String clientName = order.clientDetailModel?.name ?? 'No Name'.tr;
    final String? phone = order.clientDetailModel?.phone;
    final String displayPhone = (phone != null && phone.isNotEmpty) ? phone.replaceAll("+993", "") : 'No Phone'.tr;

    return GestureDetector(
      onTap: () => Get.to(() => OrderProductsView(
            order: order,
            isAdmin: isAdmin,
          )),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 10.h, bottom: 10.h, right: 15.w, left: 5.w),
        child: Row(
          children: [
            CustomWidgets.counter(index),
            Expanded(
              flex: 5,
              child: Text(
                "$clientName  -  $displayPhone",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 20.w),
            // DATE
            Expanded(
                flex: 2,
                child: Text(
                  // `order.date` null veya boş olabilir, kontrol eklemek iyidir.
                  order.date.toString().isNotEmpty ? order.date.toString().substring(0, 10) : '',
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                )),
            // COUNT
            Expanded(
              flex: 1, // Diğerlerine göre daha az yer kaplasın
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
                "${order.totalchykdajy.toString()} \$",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            // TOTAL SUM
            Expanded(
              flex: 2,
              child: Text(
                "${order.totalsum.toString()} \$",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            // TOTAL COST

            // STATUS
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    // Önceden aldığımız güvenli `statusColor`'ı kullanıyoruz.
                    color: statusColor.withOpacity(0.15),
                    border: Border.all(color: statusColor, width: 1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  // Önceden aldığımız güvenli `statusName`'i kullanıyoruz.
                  statusName.tr,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: statusColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
