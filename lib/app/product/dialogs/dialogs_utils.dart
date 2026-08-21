// ignore_for_file: inference_failure_on_function_return_type, inference_failure_on_function_invocation, duplicate_ignore, unused_local_variable, deprecated_member_use

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_add.dart';

import '../constants/string_constants.dart';
import '../init/packages.dart';

class DialogsUtils {
  static filterDialogSearchView() {
    final SearchViewController searchViewController = Get.find();
    final isRussian = Get.locale?.languageCode == 'ru';
    final labels = isRussian
        ? ['Бренд', 'Категории', 'Адреса', 'Материалы']
        : ['Brend', 'Kategoriýa', 'Haryt salgysy', 'Material'];
    return Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
                color: const Color(0xFFF8FAFC),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.filter_list_rounded,
                        color: Color(0xFF2563EB), size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(isRussian ? 'Фильтры' : 'Süzgüçler',
                          style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700))),
                  IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF94A3B8))),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  ...List.generate(
                      labels.length,
                      (index) => Padding(
                            padding: EdgeInsets.only(
                                bottom: index == labels.length - 1 ? 0 : 8),
                            child: Material(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => filterHelper(index: index),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 13),
                                  child: Row(children: [
                                    Expanded(
                                        child: Text(labels[index],
                                            style: const TextStyle(
                                                color: Color(0xFF334155),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600))),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: Color(0xFF94A3B8)),
                                  ]),
                                ),
                              ),
                            ),
                          )),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: searchViewController.clearFilter,
                      child: Text(isRussian ? 'Очистить' : 'Arassala',
                          style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  static orderFilterDialog() {
    List nameMapping = [
      'preparing',
      'shipped',
      'canceled',
      'refund',
      'readyToShip'
    ];
    List numberMapping = [1, 2, 3, 4, 5];
    List<Color> colorMapping = [
      ColorConstants.kPrimaryColor2,
      Colors.green,
      Colors.red,
      Colors.red,
      Colors.purple
    ];
    final OrderController orderViewController = Get.find();
    final isRussian = Get.locale?.languageCode == 'ru';
    return Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                color: const Color(0xFFF8FAFC),
                child: Row(children: [
                  const Icon(Icons.tune_rounded, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          isRussian
                              ? 'Фильтр по статусу'
                              : 'Ýagdaý boýunça süzgüç',
                          style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.w700))),
                  IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF94A3B8))),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  ...List.generate(
                      nameMapping.length,
                      (index) => Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    index == nameMapping.length - 1 ? 0 : 7),
                            child: Material(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () =>
                                      orderViewController.filterByStatus(
                                          numberMapping[index].toString()),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      child: Row(children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                              color: colorMapping[index],
                                              shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: Text(
                                                nameMapping[index]
                                                    .toString()
                                                    .tr,
                                                style: const TextStyle(
                                                    color: Color(0xFF334155),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        const Icon(Icons.chevron_right_rounded,
                                            color: Color(0xFF94A3B8)),
                                      ])),
                                )),
                          )),
                  const SizedBox(height: 10),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: orderViewController.clearFilter,
                          child: Text(isRussian ? 'Очистить' : 'Arassala',
                              style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700)))),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
    /*
    return Get.defaultDialog(
        title: isRussian ? 'Фильтр по статусу' : 'Ýagdaý boýunça süzgüç',
        titleStyle: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700),
        titlePadding: const EdgeInsets.only(top: 18),
        content: Container(
          width: Get.size.width / 3,
          height: Get.size.height / 2.5,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: nameMapping.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () {
                          orderViewController
                              .filterByStatus(numberMapping[index].toString());
                          Get.back();
                        },
                        minVerticalPadding: 4.h,
                        tileColor: colorMapping[index].withOpacity(.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: colorMapping[index])),
                        title: Text(
                          nameMapping[index].toString().tr,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(IconlyLight.arrowRightCircle),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    orderViewController.clearFilter();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.kPrimaryColor2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14)),
                  child: Text(
                    "clearFilter".tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ));*/
  }

  void showSelectableDialog({
    required BuildContext context,
    required String title,
    required String url,
    required TextEditingController targetController,
    required void Function(String id) onIdSelected,
  }) {
    final isRussian = Get.locale?.languageCode == 'ru';
    final rawTitle = title.toLowerCase();
    final typeTitle = isRussian
        ? (rawTitle.contains('category')
            ? 'Категория'
            : rawTitle.contains('brand')
                ? 'Бренд'
                : rawTitle.contains('location')
                    ? 'Адрес'
                    : rawTitle.contains('material')
                        ? 'Материал'
                        : title)
        : (rawTitle.contains('category')
            ? 'Kategoriýa'
            : rawTitle.contains('brand')
                ? 'Brend'
                : rawTitle.contains('location')
                    ? 'Haryt salgysy'
                    : rawTitle.contains('material')
                        ? 'Material'
                        : title.tr);
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
                color: const Color(0xFFF8FAFC),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.tune_rounded,
                        color: Color(0xFF2563EB), size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            isRussian
                                ? 'Выберите: $typeTitle'
                                : '$typeTitle saýlaň',
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                            isRussian
                                ? 'Выберите один вариант'
                                : 'Saýlamak üçin birini basyň',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12)),
                      ])),
                  IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF94A3B8))),
                ]),
              ),
              Flexible(
                child: FutureBuilder<List<FourInOneModel>>(
                  future: FourInOnePageService().getData(url: url),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CustomWidgets.spinKit();
                    } else if (snapshot.hasError) {
                      return CustomWidgets.errorData();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return CustomWidgets.emptyData();
                    }
                    final items = snapshot.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Material(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              targetController.text = item.name;
                              onIdSelected(item.id.toString());
                              Get.back();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 13),
                              child: Row(children: [
                                Expanded(
                                    child: Text(item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF334155),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600))),
                                const Icon(Icons.chevron_right_rounded,
                                    color: Color(0xFF94A3B8)),
                              ]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  static filterHelper({required int index}) {
    final SearchViewController searchViewController = Get.find();
    final String filterTypeForController =
        StringConstants.searchViewFilters[index]['searchName'].toString();
    final isRussian = Get.locale?.languageCode == 'ru';
    final labels = isRussian
        ? ['Бренд', 'Категории', 'Адреса', 'Материалы']
        : ['Brend', 'Kategoriýa', 'Haryt salgysy', 'Material'];
    final String dialogTitle = labels[index];
    return Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
                color: const Color(0xFFF8FAFC),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.tune_rounded,
                        color: Color(0xFF2563EB), size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            isRussian
                                ? 'Выберите: $dialogTitle'
                                : '$dialogTitle saýlaň',
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(
                            isRussian
                                ? 'Нажмите, чтобы применить фильтр'
                                : 'Süzgüç üçin birini saýlaň',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12)),
                      ])),
                  IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF94A3B8))),
                ]),
              ),
              Flexible(
                child: FutureBuilder<List<FourInOneModel>>(
                  future: FourInOnePageService().getData(
                      url: StringConstants.four_in_one_names[index]['url']
                          .toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CustomWidgets.spinKit();
                    } else if (snapshot.hasError) {
                      return CustomWidgets.errorData();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return CustomWidgets.emptyData();
                    }
                    final filterValues = snapshot.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filterValues.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 7),
                      itemBuilder: (context, i) => Material(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            searchViewController.applyFilter(
                                filterTypeForController, filterValues[i].name);
                            Get.back();
                            Get.back();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            child: Row(children: [
                              Expanded(
                                  child: Text(filterValues[i].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xFF334155),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              const Icon(Icons.chevron_right_rounded,
                                  color: Color(0xFF94A3B8)),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  static fourInOneAddData() {
    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('addData'.tr,
                        style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Choose the record type you want to create.',
                        style: TextStyle(
                            color: const Color(0xFF64748B), fontSize: 14.sp)),
                    const SizedBox(height: 20),
                    ...List.generate(StringConstants.four_in_one_names.length,
                        (index) {
                      final item = StringConstants.four_in_one_names[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Get.back();
                              showDialog(
                                  context: Get.context!,
                                  builder: (_) => AddEditFourInOneDialog(
                                      name: item['countName'].toString(),
                                      url: item['url'].toString(),
                                      editKey: item['countName'].toString()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 15),
                              child: Row(children: [
                                Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Icon(IconlyLight.plus,
                                        color: Color(0xFF4F46E5), size: 19)),
                                const SizedBox(width: 14),
                                Expanded(
                                    child: Text(item['pageView'].toString().tr,
                                        style: TextStyle(
                                            color: const Color(0xFF1E293B),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600))),
                                const Icon(IconlyLight.arrowRight2,
                                    color: Color(0xFF94A3B8), size: 18),
                              ]),
                            ),
                          ),
                        ),
                      );
                    }),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
