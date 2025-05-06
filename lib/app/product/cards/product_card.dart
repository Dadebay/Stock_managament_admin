import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/products_page/views/product_profil_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    required this.product,
    required this.disableOnTap,
  });
  final bool disableOnTap;

  final ProductModel product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final SalesController salesController = Get.put(SalesController());

  @override
  Widget build(BuildContext context) {
    return noCounterWidget();
  }

  GestureDetector noCounterWidget() {
    return GestureDetector(
      onTap: () {
        if (!widget.disableOnTap) {
          Get.to(() => ProductProfilView(product: widget.product));
        } else {
          CustomWidgets.showSnackBar('Error', 'Cannot show this product for you beacause it is SOLD', ColorConstants.redColor);
        }
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        child: Row(
          children: [
            Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 15.w),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, spreadRadius: 5)]),
                child: CustomWidgets.imageWidget(widget.product.img, false)),
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
                          widget.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15.sp),
                        ),
                        Text(
                          "${"quantity".tr}: ${widget.product.count}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.cost} \$",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.price} \$",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.brend?.name ?? ''}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.category?.name ?? ''}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${widget.product.location?.name ?? ''}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondProductCard extends StatelessWidget {
  const SecondProductCard({
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
          margin: EdgeInsets.only(right: 15.w),
          decoration: BoxDecoration(
            color: Colors.grey,
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
