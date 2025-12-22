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
    this.counter,
    super.key,
    required this.isAdmin,
  });

  final bool isAdmin;
  final bool disableOnTap;
  final bool addCounterWidget;
  final String? whcihPage;
  final int? externalCount;
  final int? counter;
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
      child: RepaintBoundary(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
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
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ID Badge
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${counter!}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Image
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomWidgets.imageWidget(url),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: (externalCount ?? product.count) > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Sany: ${externalCount ?? product.count}",
                              style: TextStyle(
                                color: (externalCount ?? product.count) > 0 ? Colors.green[700] : Colors.red[700],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoColumn("Alyş", "${product.cost} \$", Colors.orange),
                    ),
                    Expanded(
                      child: _buildInfoColumn("Satış", "${product.price} \$", Colors.green),
                    ),
                    Expanded(
                      child: _buildInfoColumn("Brend", product.brend?.name ?? '-', Colors.blue),
                    ),
                    Expanded(
                      child: _buildInfoColumn("Kategoriýa", product.category?.name ?? '-', Colors.purple),
                    ),
                    Expanded(
                      child: _buildInfoColumn("Ýerleşýän ýeri", product.location?.name ?? '-', Colors.teal),
                    ),
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
                          GestureDetector(
                            onTap: () {
                              _showQuantityDialog(context, seacrhViewController, product, selectedCount);
                            },
                            child: Container(
                              width: 30.w,
                              alignment: Alignment.center,
                              child: Text(
                                selectedCount.toString(),
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
                                maxLines: 1,
                              ),
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
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, SearchViewController controller, SearchModel product, int currentCount) {
    final TextEditingController textEditingController = TextEditingController(text: currentCount.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Quantity'.tr),
          content: TextField(
            controller: textEditingController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'quantity'.tr,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ok'.tr),
              onPressed: () {
                final newCount = int.tryParse(textEditingController.text) ?? currentCount;
                if (whcihPage == null && newCount > product.count) {
                  CustomWidgets.showSnackBar("Error", "Not in stock", Colors.red);
                } else {
                  controller.addOrUpdateProduct(product: product, count: newCount);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
            child: CachedNetworkImage(
              imageUrl: product.img ?? '',
              fit: BoxFit.fill,
              // Optimize for list view - smaller cache size
              memCacheWidth: 300,
              memCacheHeight: 300,
              maxWidthDiskCache: 600,
              maxHeightDiskCache: 600,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                  ),
                ),
              ),
              errorWidget: (context, error, stackTrace) {
                return CustomWidgets.noImage();
              },
            ),
          )),
    );
  }
}
