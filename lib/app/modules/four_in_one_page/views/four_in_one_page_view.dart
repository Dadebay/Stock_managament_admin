import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_controller.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_add.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_card.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class FourInOnePageView extends StatefulWidget {
  const FourInOnePageView({super.key});

  @override
  State<FourInOnePageView> createState() => _FourInOnePageViewState();
}

class _FourInOnePageViewState extends State<FourInOnePageView> {
  FourInOnePageController fourInOnePageController = Get.put(FourInOnePageController());
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          itemCount: StringConstants.four_in_one_names.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  StringConstants.four_in_one_names[index]['pageView'].toString(),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18.sp),
                ),
                children: [
                  FutureBuilder<List<FourInOneModel>>(
                    future: FourInOnePageService().getData(url: StringConstants.four_in_one_names[index]['url'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CustomWidgets.spinKit();
                      } else if (snapshot.hasError) {
                        return CustomWidgets.errorData();
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return CustomWidgets.emptyData();
                      }
                      final categories = snapshot.data!;
                      fourInOnePageController.fourInOneList.addAll(categories);
                      if (categories.isEmpty) {
                        return CustomWidgets.emptyData();
                      }
                      return ListView.builder(
                        itemCount: categories.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return FourInOneCard(
                            fourInOneModel: categories[index],
                            count: index + 1,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: ColorConstants.greyColor.withOpacity(.4),
              thickness: 1,
            );
          },
        ),
        Positioned(bottom: 15, right: 15, child: addDataButtonFourInONe()),
      ],
    );
  }
}

FloatingActionButton addDataButtonFourInONe() {
  return FloatingActionButton(
      onPressed: () {
        Get.defaultDialog(
          title: "Add data",
          titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp),
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
                    showDialog(
                      context: context,
                      builder: (context) => AddEditFourInOneDialog(name: StringConstants.four_in_one_names[index]['pageView'].toString()),
                    );
                  },
                  title: Text(
                    StringConstants.four_in_one_names[index]['pageView'].toString(),
                    style: TextStyle(color: Colors.black, fontSize: 24.sp),
                  ),
                  trailing: const Icon(IconlyLight.plus),
                );
              },
            ),
          ),
        );
      },
      child: const Icon(IconlyLight.plus));
}
