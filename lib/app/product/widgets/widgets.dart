import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class CustomWidgets {
  static Center spinKit() {
    return Center(child: Lottie.asset(IconConstants.loading, width: 150, height: 150, animate: true));
  }

  static Center errorData() {
    return const Center(
      child: Text("Error data"),
    );
  }

  static Center noImage() {
    return Center(
        child: Text(
      'noImage'.tr,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 25.sp),
    ));
  }

  int getFlexForSize(String size) {
    if (size == ColumnSize.small.toString()) return 1;
    if (size == ColumnSize.medium.toString()) return 2;
    if (size == ColumnSize.large.toString()) return 3;
    return 1; // default
  }

  static Center emptyData() {
    return Center(
        child: Text(
      "noProduct".tr,
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20.sp),
    ));
  }

  static Future<DateTime?> showDateTimePickerWidget({
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

  static Widget textWidgetPrice(String text1, String text2) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              text1,
              maxLines: 1,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            flex: 3,
            child: Text(
              text2,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  static SnackbarController showSnackBar(String title, String subtitle, Color color) {
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
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
      messageText: Text(
        subtitle.tr,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      borderRadius: 20.0,
      duration: const Duration(milliseconds: 1000),
      margin: const EdgeInsets.all(8),
    );
  }

  static Text filterTextWidget(String name) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 22.sp,
      ),
    );
  }

  static Center errorFetchData(BuildContext context) {
    return Center(
        child: Padding(
      padding: context.padding.normal,
      child: Column(
        children: [
          Lottie.asset(IconConstants.noData, width: WidgetSizes.size256.value, height: WidgetSizes.size256.value, animate: true),
          Padding(
            padding: context.padding.verticalNormal,
            child: Text(
              "Data not found",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "If you want to see the data please check your internet connection",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.general.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500, fontSize: 20, color: ColorConstants.greyColor),
          ),
        ],
      ),
    ));
  }

  static Widget counter(int index) {
    return Container(
      width: 40.w,
      padding: EdgeInsets.only(right: 10.w),
      alignment: Alignment.center,
      child: Text(
        index.toString(),
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp),
      ),
    );
  }

  static Widget imageWidget(String? url, bool fit) {
    return CachedNetworkImage(
      imageUrl: url!,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: imageProvider,
            fit: fit ? null : BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => spinKit(),
      errorWidget: (context, url, error) {
        return ClipRRect(borderRadius: BorderRadius.circular(20), child: Icon(IconlyLight.infoSquare));
      },
    );
  }
}
