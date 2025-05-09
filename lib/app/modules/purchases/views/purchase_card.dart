import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchases_product_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

// ignore: must_be_immutable
class PurchaseCard extends StatelessWidget {
  final PurchasesModel purchasesModel;
  final bool showInProductProfil;
  final int index;
  const PurchaseCard({required this.purchasesModel, required this.showInProductProfil, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PurchasesProductsView(purchasesModel: purchasesModel)),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 10.w, right: 0.w, top: 10.h, bottom: 10.h),
        child: Row(
          children: [
            Container(
              width: 30.w,
              alignment: Alignment.center,
              child: Text(
                "${index} - ",
                style: TextStyle(color: Colors.grey, fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
            _textWidget(big: true, text: purchasesModel.title),
            _textWidget(big: false, text: purchasesModel.date),
            _textWidget(big: false, text: purchasesModel.source),
            _textWidget(big: false, text: purchasesModel.productCount.toString()),
            showInProductProfil ? const SizedBox.shrink() : _textWidget(big: true, text: purchasesModel.cost + " \$"),
            IconButton(
                onPressed: () async {
                  await PurchasesService().deletePurchases(id: purchasesModel.id);
                },
                icon: Icon(IconlyLight.delete, color: Colors.red, size: 20.sp)),
          ],
        ),
      ),
    );
  }

  Expanded _textWidget({required bool big, required String text}) {
    return Expanded(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: big ? Colors.black : Colors.grey, fontSize: 16.sp, fontWeight: big ? FontWeight.w600 : FontWeight.normal),
      ),
    );
  }
}
