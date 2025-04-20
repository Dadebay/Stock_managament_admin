import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/components/client_add_button.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
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
            if (clientsController.clients.isEmpty) {
              clientsController.clients.addAll(clients);
            }
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
                  ListviewTopText(
                    names: StringConstants.clientNames,
                    listToSort: displayList,
                  ),
                  Expanded(
                    child: (searchEditingController.text.isNotEmpty && clientsController.searchResult.isEmpty)
                        ? CustomWidgets.emptyData()
                        : ListView.builder(
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              return ClientCard(
                                client: displayList[index],
                                count: displayList.length - index,
                                topTextColumnSize: StringConstants.clientNames,
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
            heroTag: 'button1',
            onPressed: () {
              clientsController.exportToExcel();
            },
            child: const Icon(CupertinoIcons.doc_person),
          ),
          SizedBox(width: 30.w),
          ClientAddButton(),
        ],
      ),
    );
  }
}
