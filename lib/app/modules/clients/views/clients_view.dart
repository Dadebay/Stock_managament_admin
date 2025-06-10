// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/components/client_add_button.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/search_widget.dart';

import '../controllers/clients_controller.dart';

class ClientsView extends StatelessWidget {
  final ClientsController clientsController = Get.find();
  TextEditingController searchEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<ClientModel>>(
          future: ClientsService().getClients(),
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
                  ListviewTopText<ClientModel>(
                    names: StringConstants.clientNames,
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
                        case 'name':
                          return item.name;
                        case 'address':
                          return item.address;
                        case 'number':
                          return item.phone;
                        case 'order_count':
                          return item.orderCount;
                        case 'sum_price':
                          return item.sumPrice;
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
                              return ClientCard(
                                client: displayList[index],
                                count: (displayList.length - index),
                                topTextColumnSize: StringConstants.clientNames,
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
        bottomButtons(),
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
            onPressed: () async {
              await SignInService().getClients('didario', "Didar123#");
              await AuthStorage().getAdminStatus().then((value) {
                print(value);
                if (value == true) {
                  clientsController.exportToExcel();
                } else {
                  CustomWidgets.showSnackBar("Error", "You are not admin", Colors.red);
                }
              });
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
                  return ClientAddButton();
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
