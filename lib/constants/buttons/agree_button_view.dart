// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String text;

  AgreeButton({super.key, required this.onTap, required this.text});
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: animatedContaner());
  }

  Widget animatedContaner() {
    return Obx(() {
      return AnimatedContainer(
        decoration: const BoxDecoration(borderRadius: borderRadius20, color: kPrimaryColor2),
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8.h),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: homeController.agreeButton.value ? 0 : 10.h),
        width: homeController.agreeButton.value ? 60.w : Get.size.width,
        duration: const Duration(milliseconds: 800),
        child: homeController.agreeButton.value
            ? Center(
                child: SizedBox(
                  width: 34.w,
                  height: 29.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                text.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 22),
              ),
      );
    });
  }
}
