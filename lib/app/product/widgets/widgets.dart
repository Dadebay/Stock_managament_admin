import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class CustomWidgets {
  static final GlobalKey<ScaffoldMessengerState> snackBarKey =
      GlobalKey<ScaffoldMessengerState>();
  static Center spinKit() {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CircularProgressIndicator(
            strokeWidth: 3.5, color: ColorConstants.kPrimaryColor2),
      ),
    );
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
      style: TextStyle(
          color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20.sp),
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
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            flex: 3,
            child: Text(
              text2,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  static void showSnackBar(String title, String subtitle, Color color) {
    // Get.snackbar uses GetX's overlay queue. A route transition can leave
    // that queue without an Overlay on web, so use the app-level messenger.
    final messenger = snackBarKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1400),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(title.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.white)),
              Text(subtitle.tr, style: const TextStyle(color: Colors.white)),
            ]),
      ));
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
          Lottie.asset(IconConstants.noData,
              width: WidgetSizes.size256.value,
              height: WidgetSizes.size256.value,
              animate: true),
          Padding(
            padding: context.padding.verticalNormal,
            child: Text(
              "Data not found",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.general.textTheme.titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "If you want to see the data please check your internet connection",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.general.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: ColorConstants.greyColor),
          ),
        ],
      ),
    ));
  }

  static Widget counter(int index) {
    return SizedBox(
      width: 48.w,
      child: Center(
        child: Text(
          index.toString(),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: TextStyle(
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
              fontSize: 14.sp),
        ),
      ),
    );
  }

  static Widget imageWidget(String? url,
      {bool fit = false, int? cacheWidth, int? cacheHeight}) {
    // Null check and empty URL handling
    if (url == null || url.isEmpty) {
      return noImage();
    }

    return CachedNetworkImage(
      imageUrl: url,
      // Optimize memory cache - use actual display size
      memCacheWidth: cacheWidth ?? 400,
      memCacheHeight: cacheHeight ?? 400,
      // Optimize max cache size
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
      // Use fade in animation for better UX
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: imageProvider,
            fit: fit ? null : BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(IconlyLight.infoSquare, color: Colors.grey),
        ),
      ),
    );
  }
}
