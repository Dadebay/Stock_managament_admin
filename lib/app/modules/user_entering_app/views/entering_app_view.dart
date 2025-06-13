// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/components/enter_add_button.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/views/enter_Card.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

import '../controllers/enter_controller.dart';

class EnteringAppView extends StatelessWidget {
  final bool isAdmin;
  final EnterController clientsController = Get.put<EnterController>(EnterController());
  TextEditingController searchEditingController = TextEditingController();

  EnteringAppView({super.key, required this.isAdmin});
  @override
  Widget build(BuildContext context) {
    print(isAdmin);
    print(isAdmin);
    print(isAdmin);
    return Stack(
      children: [
        FutureBuilder<List<EnterModel>>(
          future: EnterService().getClients(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomWidgets.spinKit();
            } else if (snapshot.hasError) {
              return CustomWidgets.errorData();
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return CustomWidgets.emptyData();
            }
            final clients = snapshot.data!;
            clientsController.clients.assignAll(clients);
            return Obx(() {
              final isSearching = searchEditingController.text.isNotEmpty;
              final hasResult = clientsController.searchResult.isNotEmpty;
              final displayList = (isSearching && hasResult) ? clientsController.searchResult.toList() : clientsController.clients.toList();

              return Column(
                children: [
                  SearchWidget(
                    controller: searchEditingController,
                    onChanged: (value) => clientsController.onSearchTextChanged(value),
                    onClear: () {
                      searchEditingController.clear();
                      clientsController.searchResult.clear();
                    },
                  ),
                  ListviewTopText<EnterModel>(
                    names: StringConstants.userNames,
                    listToSort: displayList,
                    setSortedList: (newList) {
                      if (isSearching) {
                        clientsController.searchResult.assignAll(newList);
                      } else {
                        clientsController.clients.assignAll(newList);
                      }
                    },
                    getSortValue: (item, key) {
                      switch (key) {
                        case 'username':
                          return item.username;
                        case 'password':
                          return item.password;
                        case 'isSuperUser':
                          return item.isSuperUser;
                        default:
                          return '';
                      }
                    },
                  ),
                  Expanded(
                    child: (searchEditingController.text.isNotEmpty && clientsController.searchResult.isEmpty)
                        ? CustomWidgets.emptyData()
                        : ListView.separated(
                            padding: context.padding.onlyBottomHigh,
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              return EnterCard(
                                isAdmin: isAdmin,
                                client: displayList[index],
                                count: (clientsController.clients.length - index),
                                topTextColumnSize: StringConstants.userNames,
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 30.w),
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
        isAdmin ? bottomButtons() : SizedBox.shrink(),
      ],
    );
  }

  Positioned bottomButtons() {
    return Positioned(
      right: 15.0,
      bottom: 15.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              clientsController.exportToExcel();
            },
            backgroundColor: Colors.black,
            child: const Icon(
              IconlyLight.document,
              color: Colors.amber,
            ),
          ),
          SizedBox(width: 30.w),
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              showDialog(
                context: Get.context!,
                builder: (context) {
                  return EnterAddButton();
                },
              );
            },
            child: const Icon(CupertinoIcons.add, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}
