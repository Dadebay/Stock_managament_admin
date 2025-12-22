import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchases_product_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

// ignore: must_be_immutable
class PurchaseCard extends StatelessWidget {
  final PurchasesModel purchasesModel;
  final bool showInProductProfil;
  final int index;
  final bool isAdmin;
  const PurchaseCard({super.key, required this.purchasesModel, required this.showInProductProfil, required this.index, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PurchasesProductsView(purchasesModel: purchasesModel, isAdmin: isAdmin)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // ID Badge
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Content
              Expanded(child: _textWidget(big: true, text: purchasesModel.title)),
              SizedBox(width: 12.w),
              Expanded(child: _textWidget(big: false, text: purchasesModel.date)),
              Expanded(child: _textWidget(big: false, text: purchasesModel.source)),
              Expanded(child: _textWidget(big: false, text: purchasesModel.count.toString(), textAlign: TextAlign.center)),
              if (!showInProductProfil) Expanded(child: _textWidget(big: true, text: "${purchasesModel.cost} \$", textAlign: TextAlign.center)),
              // Action buttons
              if (isAdmin) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final confirm = await ConfirmDialog.show(
                        title: 'delete'.tr,
                        message: '${'confirmDelete'.tr} ${purchasesModel.title}?',
                      );

                      if (confirm == true) {
                        await PurchasesService().deletePurchases(id: purchasesModel.id);
                      }
                    },
                    icon: Icon(IconlyLight.delete, color: Colors.red, size: 20.sp),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => Get.to(() => PurchasesProductsView(purchasesModel: purchasesModel, isAdmin: isAdmin)),
                    icon: Icon(IconlyLight.editSquare, color: Colors.black87, size: 20.sp),
                  ),
                ),
              ] else
                SizedBox(width: 80.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textWidget({required bool big, TextAlign? textAlign, required String text}) {
    return Text(
      text,
      maxLines: 1,
      textAlign: textAlign ?? TextAlign.start,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: big ? Colors.black : Colors.grey, fontSize: big ? 17.sp : 15.sp, fontWeight: big ? FontWeight.w600 : FontWeight.normal),
    );
  }
}
