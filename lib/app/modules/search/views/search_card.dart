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
    final SearchViewController seacrhViewController =
        Get.find<SearchViewController>();
    String url = '';
    if (product.img!.contains(ApiConstants.imageURL)) {
      url = product.img!;
    } else {
      url = ApiConstants.imageURL2 + product.img!;
    }
    return GestureDetector(
      onTap: () {
        if (!disableOnTap) {
          Get.to(() => ProductProfilView(
              product: product,
              disableUpdate: addCounterWidget,
              isAdmin: isAdmin));
        } else {
          CustomWidgets.showSnackBar(
              'Error',
              'Cannot show this product because it is SOLD',
              ColorConstants.redColor);
        }
      },
      child: RepaintBoundary(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(8.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ID Badge
              SizedBox(
                width: 34.w,
                height: 34.h,
                child: Center(
                  child: Text(
                    '${counter!}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Image
              Container(
                width: 54.w,
                height: 54.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: 160,
                  memCacheHeight: 160,
                  errorWidget: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF94A3B8)),
                ),
              ),
              SizedBox(width: 10.w),
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
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: (externalCount ?? product.count) > 0
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Sany: ${externalCount ?? product.count}",
                              style: TextStyle(
                                color: (externalCount ?? product.count) > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoColumn("${product.cost} \$"),
                    ),
                    Expanded(
                      child: _buildInfoColumn("${product.price} \$"),
                    ),
                    Expanded(
                      child: _buildInfoColumn(product.brend?.name ?? '-'),
                    ),
                    Expanded(
                      child: _buildInfoColumn(product.category?.name ?? '-'),
                    ),
                    Expanded(
                      child: _buildInfoColumn(product.location?.name ?? '-'),
                    ),
                  ],
                ),
              ),
              addCounterWidget
                  ? Obx(() {
                      final selectedCount = seacrhViewController
                          .getProductCount(product.id.toString());

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.minus_circle,
                                color: Colors.black),
                            onPressed: () {
                              if (selectedCount > 0) {
                                seacrhViewController.decreaseCount(
                                    product.id.toString(), selectedCount - 1);
                              }
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              _showQuantityDialog(context, seacrhViewController,
                                  product, selectedCount);
                            },
                            child: Container(
                              width: 30.w,
                              alignment: Alignment.center,
                              child: Text(
                                selectedCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.add_circled,
                                color: Colors.black),
                            onPressed: () {
                              if (whcihPage == null &&
                                  selectedCount >= product.count) {
                                CustomWidgets.showSnackBar(
                                    "Error", "Not in stock", Colors.red);
                              } else {
                                seacrhViewController.addOrUpdateProduct(
                                    product: product, count: selectedCount + 1);
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

  void _showQuantityDialog(BuildContext context,
      SearchViewController controller, SearchModel product, int currentCount) {
    final TextEditingController textEditingController =
        TextEditingController(text: currentCount.toString());
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
                final newCount =
                    int.tryParse(textEditingController.text) ?? currentCount;
                if (whcihPage == null && newCount > product.count) {
                  CustomWidgets.showSnackBar(
                      "Error", "Not in stock", Colors.red);
                } else {
                  controller.addOrUpdateProduct(
                      product: product, count: newCount);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoColumn(String value) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFF334155),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      onTap: () => Get.to(() => ProductProfilView(
          product: product, disableUpdate: false, isAdmin: isAdmin)),
      child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.img ?? '',
              fit: BoxFit.cover,
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
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.grey),
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
