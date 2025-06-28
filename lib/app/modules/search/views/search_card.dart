import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/products_page/views/product_profil_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({
    required this.product,
    required this.disableOnTap,
    required this.addCounterWidget,
    required this.whcihPage,
    this.externalCount,
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;
  final bool disableOnTap;
  final bool addCounterWidget;
  final String? whcihPage;
  final int? externalCount;
  final SearchModel product;

  @override
  Widget build(BuildContext context) {
    final SearchViewController seacrhViewController = Get.find<SearchViewController>();
    String url = '';
    if (product.img!.contains(ApiConstants.imageURL)) {
      url = product.img!;
    } else {
      url = ApiConstants.imageURL2 + product.img!;
    }

    return GestureDetector(
      onTap: () {
        if (!disableOnTap) {
          Get.to(() => ProductProfilView(product: product, disableUpdate: addCounterWidget, isAdmin: isAdmin));
        } else {
          CustomWidgets.showSnackBar('Error', 'Cannot show this product because it is SOLD', ColorConstants.redColor);
        }
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 15.h, bottom: 15.h, right: 15.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.only(right: 15.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade200,
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, spreadRadius: 5)],
              ),
              child: CustomWidgets.imageWidget(url, false),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16.sp),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Text(
                            "${"quantity".tr}: ${externalCount ?? product.count}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(child: Text("${product.cost} \$", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.sp))),
                  Expanded(child: Text("${product.price} \$", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.sp))),
                  Expanded(child: Text("${product.brend?.name ?? ''}", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 14.sp))),
                  Expanded(child: Text("${product.category?.name ?? ''}", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 14.sp))),
                  Expanded(child: Text("${product.location?.name ?? ''}", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 14.sp))),
                ],
              ),
            ),
            addCounterWidget
                ? Obx(() {
                    final selectedCount = seacrhViewController.getProductCount(product.id.toString());

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(CupertinoIcons.minus_circle, color: Colors.black),
                          onPressed: () {
                            if (selectedCount > 0) {
                              seacrhViewController.decreaseCount(product.id.toString(), selectedCount - 1);
                            }
                          },
                        ),
                        Container(
                          width: 30.w,
                          alignment: Alignment.center,
                          child: Text(
                            selectedCount.toString(),
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
                            maxLines: 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.add_circled, color: Colors.black),
                          onPressed: () {
                            if (whcihPage == null && selectedCount >= product.count) {
                              CustomWidgets.showSnackBar("Error", "Not in stock", Colors.red);
                            } else {
                              seacrhViewController.addOrUpdateProduct(product: product, count: selectedCount + 1);
                            }
                          },
                        ),
                      ],
                    );
                  })
                : const Icon(IconlyLight.arrowRightCircle),
          ],
        ),
      ),
    );
  }
}

class SecondProductCard extends StatelessWidget {
  const SecondProductCard({
    required this.product,
    required this.isAdmin,
  });
  final bool isAdmin;
  final SearchModel product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductProfilView(product: product, disableUpdate: false, isAdmin: isAdmin)),
      child: Container(
          margin: EdgeInsets.only(right: 15.w),
          decoration: BoxDecoration(
            color: Colors.grey,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 5,
                spreadRadius: 5,
              ),
            ],
            borderRadius: context.border.lowBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: context.border.lowBorderRadius,
            child: Image.network(
              product.img!,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return CustomWidgets.noImage();
              },
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return CustomWidgets.spinKit();
              },
            ),
          )),
    );
  }
}
