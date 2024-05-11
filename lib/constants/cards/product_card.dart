import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/data/models/product_model.dart';
import 'package:stock_managament_admin/app/modules/products_page/views/product_profil_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductProfilView(
              product: widget.product,
            ));
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        child: Row(
          children: [
            Container(
                width: 50.w,
                height: 60.h,
                margin: EdgeInsets.only(right: 15.w),
                decoration: BoxDecoration(borderRadius: borderRadius10, color: Colors.grey, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, spreadRadius: 5)]),
                child: imageView(imageURl: widget.product.image!)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
                        ),
                        Text(
                          "${"quantity".tr}: ${widget.product.quantity}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Expanded(
                    child: Text(
                      "${widget.product.cost} \$",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.sellPrice} \$",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.brandName}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.category}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(IconlyLight.arrowRightCircle)
          ],
        ),
      ),
    );
  }
}

class SecondProductCard extends StatelessWidget {
  const SecondProductCard({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
          return ProductProfilView(product: product);
        }));
      },
      child: Container(
          width: 50.w,
          height: 60.h,
          margin: EdgeInsets.only(right: 15.w),
          decoration: BoxDecoration(borderRadius: borderRadius30, color: Colors.grey, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, spreadRadius: 5)]),
          child: ClipRRect(
            borderRadius: borderRadius30,
            child: Image.network(
              product.image!,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                    child: Text(
                  'noImage'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 25.sp),
                ));
              },
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                  ),
                );
              },
            ),
          )),
    );
  }
}
