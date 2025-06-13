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
  final bool isAdmin;
  const PurchaseCard({required this.purchasesModel, required this.showInProductProfil, required this.index, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PurchasesProductsView(purchasesModel: purchasesModel, isAdmin: isAdmin)),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
        child: Row(
          children: [
            CustomWidgets.counter(index),
            _textWidget(big: true, text: purchasesModel.title),
            SizedBox(width: 20.w),
            _textWidget(big: false, text: purchasesModel.date),
            _textWidget(big: false, text: purchasesModel.source),
            _textWidget(big: false, text: purchasesModel.count.toString(), textAlign: TextAlign.center),
            showInProductProfil ? const SizedBox.shrink() : _textWidget(big: true, text: purchasesModel.cost + " \$", textAlign: TextAlign.center),
            isAdmin
                ? IconButton(
                    onPressed: () async {
                      await PurchasesService().deletePurchases(id: purchasesModel.id);
                    },
                    icon: Icon(IconlyLight.delete, color: Colors.red, size: 20.sp))
                : SizedBox.shrink(),
            isAdmin
                ? IconButton(onPressed: () => Get.to(() => PurchasesProductsView(purchasesModel: purchasesModel, isAdmin: isAdmin)), icon: Icon(IconlyLight.editSquare, color: Colors.black, size: 20.sp))
                : Container(
                    width: 80,
                  ),
          ],
        ),
      ),
    );
  }

  Expanded _textWidget({required bool big, TextAlign? textAlign, required String text}) {
    return Expanded(
      child: Text(
        text,
        maxLines: 1,
        textAlign: textAlign ?? TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: big ? Colors.black : Colors.grey, fontSize: big ? 17.sp : 15.sp, fontWeight: big ? FontWeight.w600 : FontWeight.normal),
      ),
    );
  }
}
