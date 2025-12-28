// ignore_for_file: file_names, must_be_immutable

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final bool? showBorder;
  final RxBool? isLoading;

  AgreeButton({required this.onTap, required this.text, this.showBorder, this.isLoading});
  HomeController? homeController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: animatedContaner(context));
  }

  Widget animatedContaner(BuildContext context) {
    // HomeController'ı bul
    if (homeController == null && isLoading == null) {
      try {
        homeController = Get.find<HomeController>();
      } catch (e) {
        homeController = null;
      }
    }

    // isLoading parametresi varsa onu kullan, yoksa homeController'daki değeri kullan
    final loadingValue = isLoading ?? homeController?.agreeButton ?? false.obs;

    return Obx(() {
      return AnimatedContainer(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: showBorder == true ? Colors.transparent : ColorConstants.kPrimaryColor2, border: Border.all(color: ColorConstants.kPrimaryColor2)),
        margin: context.padding.onlyTopNormal,
        padding: context.padding.normal.copyWith(top: 15, bottom: 15),
        width: loadingValue.value ? 60.w : Get.size.width,
        duration: const Duration(milliseconds: 800),
        alignment: Alignment.center,
        child: loadingValue.value
            ? SizedBox(
                width: 34.w,
                height: 25.h,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Text(
                text.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp, color: showBorder == true ? ColorConstants.kPrimaryColor2 : Colors.white),
              ),
      );
    });
  }
}
