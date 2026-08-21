import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_controller.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_card.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/dialogs/dialogs_utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class FourInOnePageView extends StatefulWidget {
  const FourInOnePageView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<FourInOnePageView> createState() => _FourInOnePageViewState();
}

class _FourInOnePageViewState extends State<FourInOnePageView> {
  final FourInOnePageController fourInOnePageController =
      Get.find<FourInOnePageController>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          itemCount: StringConstants.four_in_one_names.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final item = StringConstants.four_in_one_names[index];
            final key = item['countName'].toString();
            return FutureBuilder<List<FourInOneModel>>(
              future:
                  FourInOnePageService().getData(url: item['url'].toString()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    fourInOnePageController.addListData(key, snapshot.data!);
                  });
                }

                return Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    collapsedIconColor: const Color(0xFF64748B),
                    iconColor: const Color(0xFF4F46E5),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['pageView'].toString().tr,
                            style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w600,
                                fontSize: 18.sp),
                          ),
                        ),
                        Obx(() => _CategoryCountBadge(
                              count: fourInOnePageController
                                      .fourInOneDataMap[key]?.length ??
                                  snapshot.data?.length ??
                                  0,
                              isLoading: snapshot.connectionState ==
                                  ConnectionState.waiting,
                            )),
                      ],
                    ),
                    children: [
                      if (snapshot.connectionState == ConnectionState.waiting)
                        CustomWidgets.spinKit()
                      else if (snapshot.hasError)
                        CustomWidgets.errorData()
                      else if (!snapshot.hasData || snapshot.data!.isEmpty)
                        CustomWidgets.emptyData()
                      else
                        Obx(() {
                          final list =
                              fourInOnePageController.fourInOneDataMap[key] ??
                                  <FourInOneModel>[].obs;
                          return ListView.builder(
                            itemCount: list.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, i) => FourInOneCard(
                              count: i + 1,
                              fourInOneModel: list[i],
                              dataKey: key,
                              url: item['url'].toString(),
                              isAdmin: widget.isAdmin,
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              color: ColorConstants.greyColor.withValues(alpha: .4),
              thickness: 1,
            );
          },
        ),
        widget.isAdmin
            ? Positioned(
                bottom: 15,
                right: 15,
                child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    onPressed: () => DialogsUtils.fourInOneAddData(),
                    child: const Icon(
                      IconlyLight.plus,
                      color: Colors.amber,
                    )))
            : SizedBox(),
      ],
    );
  }
}

class _CategoryCountBadge extends StatelessWidget {
  const _CategoryCountBadge({required this.count, required this.isLoading});

  final int count;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLoading ? '…' : '$count',
        style: TextStyle(
            color: const Color(0xFF4338CA),
            fontSize: 13.sp,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
