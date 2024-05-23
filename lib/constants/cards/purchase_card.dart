import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_admin/app/data/models/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchases_product_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';

// ignore: must_be_immutable
class PurchaseCard extends StatelessWidget {
  final PurchasesModel purchasesModel;
  final bool showInProductProfil;
  const PurchaseCard({super.key, required this.purchasesModel, required this.showInProductProfil});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
          return PurchasesProductsView(
            purchasesModel: purchasesModel,
            showInProductsView: showInProductProfil,
          );
        }));
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "${purchasesModel.title}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
                flex: 2,
                child: Text(
                  purchasesModel.date!.substring(0, 10),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                )),
            Expanded(
              flex: 2,
              child: Text(
                purchasesModel.source!,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
              ),
            ),
            Expanded(
              child: Text(
                "${purchasesModel.productsCount}",
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
              ),
            ),
            showInProductProfil
                ? const SizedBox.shrink()
                : Expanded(
                    child: Text(
                      "${purchasesModel.cost} \$",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
