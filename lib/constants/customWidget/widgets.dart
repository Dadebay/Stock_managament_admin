import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';

SnackbarController showSnackBar(String title, String subtitle, Color color) {
  if (SnackbarController.isSnackbarBeingShown) {
    SnackbarController.cancelAllSnackbars();
  }
  return Get.snackbar(
    title,
    subtitle,
    snackStyle: SnackStyle.FLOATING,
    titleText: title == ''
        ? const SizedBox.shrink()
        : Text(
            title.tr,
            style: const TextStyle(fontFamily: gilroySemiBold, fontSize: 18, color: Colors.white),
          ),
    messageText: Text(
      subtitle.tr,
      style: const TextStyle(fontFamily: gilroyRegular, fontSize: 16, color: Colors.white),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: color,
    borderRadius: 20.0,
    duration: const Duration(milliseconds: 1000),
    margin: const EdgeInsets.all(8),
  );
}

Center spinKit() {
  return Center(
    child: Lottie.asset(loadingLottie, width: 70.w, height: 70.h),
  );
}

Center errorData() {
  return const Center(
    child: Text("Error data"),
  );
}

Center emptyData() {
  return Center(
      child: Text(
    "noProduct".tr,
    style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 20.sp),
  ));
}

Text filterTextWidget(String name) {
  return Text(
    name,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.black,
      fontFamily: gilroySemiBold,
      fontSize: 22.sp,
    ),
  );
}

Widget imageView({required String imageURl}) {
  return ClipRRect(
    borderRadius: borderRadius10,
    child: Image.network(
      imageURl,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        return Center(
            child: Text(
          'noImage'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 15.sp),
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
  );
}

Future<DateTime?> showDateTimePickerWidget({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(selectedDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}

Padding topWidgetTextPart(bool addMorePadding) {
  final SeacrhViewController searchController = Get.put(SeacrhViewController());
  bool sortValue = false;
  return Padding(
    padding: EdgeInsets.only(left: addMorePadding ? 60.w : 30.w, right: 20.w, top: 10.h, bottom: 10.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "Product Name",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
          ),
        ),
        const Expanded(child: SizedBox()),
        button(searchController, sortValue, true, '   Cost', 'cost'),
        button(searchController, sortValue, true, 'Sell Price', 'sell_price'),
        button(searchController, sortValue, false, 'Brand', 'brand'),
        button(searchController, sortValue, false, 'Category', 'category'),
      ],
    ),
  );
}

Expanded button(SeacrhViewController searchController, bool sortValue, bool sortDoubleValue, String text, String sortText) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        List productList = [];
        productList = searchController.productsList;

        if (sortValue == false) {
          if (sortDoubleValue) {
            productList.sort((a, b) {
              final String first = a[sortText] ?? '0.0';
              final String second = b[sortText] ?? '0.0';
              final double firstCost = double.tryParse(first.replaceAll(',', '.')) ?? 0.0;
              final double secondCost = double.tryParse(second.replaceAll(',', '.')) ?? 0.0;
              return firstCost.compareTo(secondCost);
            });
          } else {
            productList.sort((a, b) {
              return a[sortText].compareTo(b[sortText]);
            });
          }
        } else {
          if (sortDoubleValue) {
            productList.sort((a, b) {
              final String first = a['cost'] ?? '0.0';
              final String second = b['cost'] ?? '0.0';
              final double firstCost = double.tryParse(first.replaceAll(',', '.')) ?? 0.0;
              final double secondCost = double.tryParse(second.replaceAll(',', '.')) ?? 0.0;
              return secondCost.compareTo(firstCost);
            });
          } else {
            print("Gymmatdan arzana");
            productList.sort((a, b) {
              return b[sortText].compareTo(a[sortText]);
            });
          }
        }
        sortValue = !sortValue;
      },
      child: Text(
        text,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
      ),
    ),
  );
}
