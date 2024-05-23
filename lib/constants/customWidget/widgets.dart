import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';

List statusList = [
  {'name': 'Shipped', 'statusName': 'shipped'},
  {'name': 'Canceled', 'statusName': 'canceled'},
  {'name': 'Refund', 'statusName': 'refund'},
  {'name': 'Preparing', 'statusName': 'preparing'},
  {'name': 'Ready to ship', 'statusName': 'ready to ship'},
];
List topPartNames = [
  {'name': 'Order Name', 'sortName': "client_number"},
  {'name': 'Date', 'sortName': "date"},
  {'name': 'Product count', 'sortName': "product_count"},
  {'name': '   Sum Price', 'sortName': "sum_price"},
  {'name': ' Sum Cost', 'sortName': "sum_cost"},
  {'name': 'Status', 'sortName': "status"},
];
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

Container topWidgetPurchases(bool value) {
  List topPartNamesPurchases = [
    {'name': 'Purchase Title', 'sortName': "client_number"},
    {'name': 'Date', 'sortName': "date"},
    {'name': 'Source', 'sortName': "source"},
    {'name': 'Product count', 'sortName': "product_count"},
    {'name': 'Sum Cost', 'sortName': "cost"},
  ];

  bool sortValue = false;
  return Container(
    color: Colors.white,
    padding: EdgeInsets.only(left: value ? 0.w : 60.w, right: 20.w, top: 10.h, bottom: 10.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        button(sortValue, false, topPartNamesPurchases[0]['name'], topPartNamesPurchases[0]['sortName'], false, 2, true, true),
        button(sortValue, false, topPartNamesPurchases[1]['name'], topPartNamesPurchases[1]['sortName'], false, 2, true, true),
        button(sortValue, false, topPartNamesPurchases[2]['name'], topPartNamesPurchases[2]['sortName'], false, 2, true, true),
        button(sortValue, false, topPartNamesPurchases[3]['name'], topPartNamesPurchases[3]['sortName'], false, 1, true, true),
        value ? const SizedBox.shrink() : button(sortValue, false, topPartNamesPurchases[4]['name'], topPartNamesPurchases[4]['sortName'], false, 1, true, true),
      ],
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
    // ignore: use_build_context_synchronously
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

final SeacrhViewController searchController = Get.put(SeacrhViewController());

Container topWidgetTextPart({required bool addMorePadding, required List names, required bool ordersView, required bool clientView, required bool purchasesView}) {
  bool sortValue = false;
  return Container(
    color: Colors.white,
    padding: EdgeInsets.only(left: addMorePadding ? 60.w : 30.w, right: ordersView ? 0.0 : 20.w, top: 10.h, bottom: 10.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        button(sortValue, false, names[0]['name'], names[0]['sortName'], ordersView, 2, clientView, false),
        clientView ? const SizedBox.shrink() : const Expanded(child: SizedBox.shrink()),
        button(sortValue, clientView ? false : !ordersView, names[1]['name'], names[1]['sortName'], ordersView, clientView ? 2 : 1, clientView, false),
        button(sortValue, clientView ? false : true, names[2]['name'], names[2]['sortName'], ordersView, purchasesView ? 2 : 1, clientView, false),
        button(sortValue, false, names[3]['name'], names[3]['sortName'], ordersView, 1, clientView, false),
        button(sortValue, false, names[4]['name'], names[4]['sortName'], ordersView, 1, clientView, false),
        ordersView ? button(sortValue, true, names[5]['name'], names[5]['sortName'], ordersView, 1, clientView, false) : const SizedBox.shrink(),
      ],
    ),
  );
}

Widget textWidgetPrice(String text1, String text2) {
  return Expanded(
    child: Row(
      children: [
        Expanded(
          child: Text(
            text1,
            maxLines: 1,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
          ),
        ),
        Expanded(
          child: Text(
            text2,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
          ),
        ),
      ],
    ),
  );
}

final ClientsController clientsController = Get.put(ClientsController());
Expanded button(bool sortValue, bool sortDoubleValue, String text, String sortText, bool orderView, int flex, bool clientView, bool purchaseV) {
  final SalesController salesController = Get.put(SalesController());
  return Expanded(
    flex: flex,
    child: GestureDetector(
      onTap: () {
        List productList = [];
        if (orderView == true) {
          productList = salesController.orderCardList;
        } else if (clientView == true) {
          productList = clientsController.clients;
        } else {
          productList = searchController.productsList;
        }
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
              final String first = a[sortText] ?? '0.0';
              final String second = b[sortText] ?? '0.0';
              final double firstCost = double.tryParse(first.replaceAll(',', '.')) ?? 0.0;
              final double secondCost = double.tryParse(second.replaceAll(',', '.')) ?? 0.0;
              return secondCost.compareTo(firstCost);
            });
          } else {
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
