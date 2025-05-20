// ignore_for_file: must_be_immutable

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_service.dart';
import 'package:stock_managament_admin/app/modules/expences/views/edit_add_expences.dart';
import 'package:stock_managament_admin/app/modules/expences/views/expences_card.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

class ExpencesView extends StatelessWidget {
  final ExpencesController expencesController = Get.put<ExpencesController>(ExpencesController());
  TextEditingController searchEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<ExpencesModel>>(
          future: ExpencesService().getExpences(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomWidgets.spinKit();
            } else if (snapshot.hasError) {
              return CustomWidgets.errorData();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return CustomWidgets.emptyData();
            }
            final expences = snapshot.data!;
            return Obx(() {
              if (expencesController.expencesList.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  expencesController.expencesList.addAll(expences);
                  double sum = 0.0;
                  for (var expense in expences) {
                    sum += double.tryParse(expense.cost.toString()) ?? 0.0;
                  }
                  expencesController.totalPrice.value = sum;
                });
              }
              final isSearching = searchEditingController.text.isNotEmpty;
              final hasResult = expencesController.searchResult.isNotEmpty;
              final displayList = (isSearching && hasResult) ? expencesController.searchResult.toList() : expencesController.expencesList.toList();
              return Column(
                children: [
                  SearchWidget(
                    controller: searchEditingController,
                    onChanged: (value) => expencesController.onSearchTextChanged(value),
                    onClear: () {
                      searchEditingController.clear();
                      expencesController.searchResult.clear();
                    },
                  ),
                  ListviewTopText<ExpencesModel>(
                    names: StringConstants.expencesNames,
                    listToSort: displayList,
                    setSortedList: (newList) {
                      if (isSearching) {
                        expencesController.searchResult.assignAll(newList);
                      } else {
                        expencesController.expencesList.assignAll(newList);
                      }
                    },
                    getSortValue: (item, key) {
                      switch (key) {
                        case 'name':
                          return item.name;
                        case 'date':
                          return item.date;
                        case 'cost':
                          return item.cost;
                        case 'notes':
                          return item.note;
                        default:
                          return '';
                      }
                    },
                  ),
                  Expanded(
                    child: (searchEditingController.text.isNotEmpty && expencesController.searchResult.isEmpty)
                        ? CustomWidgets.emptyData()
                        : ListView.separated(
                            itemCount: displayList.length,
                            padding: context.padding.onlyBottomHigh,
                            itemBuilder: (context, index) {
                              return ExpencesCard(
                                expencesModel: displayList[index],
                                count: displayList.length - index,
                                topTextColumnSize: StringConstants.expencesNames,
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 30.w),
                                child: Divider(thickness: 2, color: ColorConstants.greyColorwithOpacity),
                              );
                            },
                          ),
                  ),
                ],
              );
            });
          },
        ),
        Align(alignment: Alignment.bottomCenter, child: bottomSumPrice(context)),
        bottomButtons(context),
      ],
    );
  }

  Positioned bottomButtons(BuildContext context) {
    return Positioned(
      right: 15.0,
      bottom: 80.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'button1',
            backgroundColor: Colors.black,
            onPressed: () {
              expencesController.exportToExcel();
            },
            child: Icon(
              IconlyLight.document,
              color: Colors.amber,
            ),
          ),
          SizedBox(width: 20.w),
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const EditAddExpencesDialog(),
              );
            },
            child: const Icon(
              Icons.add,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSumPrice(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.grey, thickness: 1),
          Padding(
            padding: context.padding.verticalLow,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Sum of expences :",
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: context.general.textTheme.displayLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
                  ),
                ),
                Expanded(
                  child: Obx(() => Text(
                        expencesController.totalPrice.value.toString(),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: context.general.textTheme.displayLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
