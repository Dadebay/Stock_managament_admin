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
                  ListviewTopText(names: StringConstants.expencesNames, listToSort: expencesController.expencesList),
                  Expanded(
                    child: (searchEditingController.text.isNotEmpty && expencesController.searchResult.isEmpty)
                        ? CustomWidgets.emptyData()
                        : ListView.builder(
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              return ExpencesCard(
                                expencesModel: displayList[index],
                                count: displayList.length - index,
                                topTextColumnSize: StringConstants.expencesNames,
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
            onPressed: () {
              expencesController.exportToExcel();
            },
            child: Icon(IconlyLight.document),
          ),
          SizedBox(width: 20.w),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const EditAddExpencesDialog(),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Column bottomSumPrice(BuildContext context) {
    return Column(
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
    );
  }
}
