// ignore_for_file: inference_failure_on_function_return_type, inference_failure_on_function_invocation, duplicate_ignore, unused_local_variable

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_add.dart';

import '../constants/string_constants.dart';
import '../init/packages.dart';

class DialogsUtils {
  static filterDialogSearchView() {
    final SearchViewController searchViewController = Get.find();

    return Get.defaultDialog(
        title: 'Filter',
        titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
        titlePadding: EdgeInsets.only(top: 20),
        content: Container(
          width: Get.size.width / 3,
          height: Get.size.height / 2,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: StringConstants.searchViewFilters.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () => filterHelper(index: index),
                      minVerticalPadding: 10.h,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Text(
                        StringConstants.searchViewFilters[index]['name'].toString(),
                        style: TextStyle(color: const Color.fromARGB(255, 115, 109, 109), fontSize: 22.sp, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(IconlyLight.arrowRightCircle),
                    );
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    searchViewController.clearFilter();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.kPrimaryColor2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10)),
                  child: Text(
                    "clearFilter".tr,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ));
  }

  static orderFilterDialog() {
    List nameMapping = ['preparing', 'shipped', 'canceled', 'refund', 'readyToShip'];
    List numberMapping = [1, 2, 3, 4, 5];
    List<Color> colorMapping = [ColorConstants.kPrimaryColor2, Colors.green, Colors.red, Colors.red, Colors.purple];
    final OrderController orderViewController = Get.find();
    return Get.defaultDialog(
        title: 'Filter by status',
        titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
        titlePadding: EdgeInsets.only(top: 20),
        content: Container(
          width: Get.size.width / 3,
          height: Get.size.height / 2,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
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
                          orderViewController.filterByStatus(numberMapping[index].toString());
                          Get.back();
                        },
                        minVerticalPadding: 10.h,
                        tileColor: colorMapping[index].withOpacity(.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: colorMapping[index])),
                        title: Text(
                          nameMapping[index].toString().tr,
                          style: TextStyle(color: Colors.black, fontSize: 22.sp, fontWeight: FontWeight.w500),
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
                  style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.kPrimaryColor2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10)),
                  child: Text(
                    "clearFilter".tr,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ));
  }

  void showSelectableDialog({
    required BuildContext context,
    required String title,
    required String url,
    required TextEditingController targetController,
    required void Function(String id) onIdSelected,
  }) {
    Get.defaultDialog(
      title: title.tr,
      titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
      titlePadding: EdgeInsets.only(top: 20),
      content: Container(
        width: Get.size.width / 3,
        height: Get.size.height / 2,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
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
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  minVerticalPadding: 10.h,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  title: Text(
                    item.name.tr,
                    style: TextStyle(color: const Color.fromARGB(255, 115, 109, 109), fontSize: 22.sp, fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(IconlyLight.arrowRightCircle),
                  onTap: () {
                    targetController.text = item.name;
                    onIdSelected(item.id.toString());
                    Get.back();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  static filterHelper({required int index}) {
    final SearchViewController searchViewController = Get.find();
    final String filterTypeForController = StringConstants.searchViewFilters[index]['searchName'].toString();
    final String dialogTitle = StringConstants.searchViewFilters[index]['name'].toString();
    Get.defaultDialog(
        title: "${"Select".tr} ${dialogTitle.tr}",
        titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
        titlePadding: EdgeInsets.only(top: 20.h),
        content: Container(
            width: Get.size.width / 3,
            height: Get.size.height / 1.8,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: FutureBuilder<List<FourInOneModel>>(
              future: FourInOnePageService().getData(url: StringConstants.four_in_one_names[index]['url'].toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomWidgets.spinKit();
                } else if (snapshot.hasError) {
                  return CustomWidgets.errorData();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return CustomWidgets.emptyData();
                }
                final filterValues = snapshot.data!;

                return ListView.builder(
                  itemCount: filterValues.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return ListTile(
                      minVerticalPadding: 10.h,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onTap: () {
                        searchViewController.applyFilter(filterTypeForController, filterValues[i].name);
                        Get.back();
                        Get.back();
                      },
                      trailing: const Icon(IconlyLight.arrowRightCircle),
                      title: Text(
                        filterValues[i].name,
                        style: TextStyle(color: const Color.fromARGB(255, 115, 109, 109), fontSize: 22.sp, fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                );
              },
            )));
  }

  static fourInOneAddData() {
    return Get.defaultDialog(
      title: "addData".tr,
      titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
      titlePadding: EdgeInsets.only(top: 20),
      content: SizedBox(
        height: Get.height / 3,
        width: Get.size.width / 3,
        child: ListView.builder(
          itemCount: StringConstants.four_in_one_names.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                Get.back();
                showDialog(
                  context: context,
                  builder: (context) => AddEditFourInOneDialog(name: StringConstants.four_in_one_names[index]['countName'].toString(), url: StringConstants.four_in_one_names[index]['url'].toString(), editKey: StringConstants.four_in_one_names[index]['countName'].toString()),
                );
              },
              title: Text(
                StringConstants.four_in_one_names[index]['pageView'].toString().tr,
                style: TextStyle(color: const Color.fromARGB(255, 115, 109, 109), fontSize: 22.sp, fontWeight: FontWeight.w500),
              ),
              minVerticalPadding: 10.h,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              trailing: const Icon(IconlyLight.plus),
            );
          },
        ),
      ),
    );
  }
}
