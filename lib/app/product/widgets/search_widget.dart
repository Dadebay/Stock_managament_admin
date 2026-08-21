import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({super.key, this.onChanged, this.onClear, required this.controller});
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padding.low,
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorConstants.greyColor.withOpacity(.2)),
        ),
        child: Row(
          children: [
            SizedBox(width: 12.w),
            Icon(IconlyLight.search, color: ColorConstants.greyColor, size: 18),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(color: ColorConstants.blackColor, fontSize: 13.5.sp, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'search'.tr,
                  hintStyle: TextStyle(color: ColorConstants.greyColor, fontSize: 13.sp, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
            IconButton(
              splashRadius: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(CupertinoIcons.xmark_circle, color: ColorConstants.greyColor, size: 17),
              onPressed: onClear,
            ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }
}
