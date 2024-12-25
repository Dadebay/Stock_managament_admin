import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/data/models/client_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/cards/client_card.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/phone_number.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

import '../controllers/clients_controller.dart';

class ClientsView extends StatelessWidget {
  List clientNames = [
    {'name': 'Client Name', 'sortName': "name"},
    {'name': 'Address', 'sortName': "address"},
    {'name': 'Client number', 'sortName': "number"},
    {'name': 'Order count', 'sortName': "order_count"},
    {'name': 'Sum price', 'sortName': "sum_price"},
  ];
  final ClientsController clientsController = Get.put(ClientsController());
  final SalesController salesController = Get.put(SalesController());
  TextEditingController searchEditingController = TextEditingController();

  FloatingActionButton addButton() {
    final TextEditingController userNameEditingController = TextEditingController();
    final TextEditingController addressEditingController = TextEditingController();
    final TextEditingController phoneNumberEditingController = TextEditingController();
    FocusNode focusNode = FocusNode();
    FocusNode focusNode1 = FocusNode();
    FocusNode focusNode2 = FocusNode();
    return FloatingActionButton(
      heroTag: "button",
      onPressed: () {
        Get.defaultDialog(
          title: "Add client",
          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          content: SizedBox(
            width: Get.size.width / 3,
            height: Get.size.height / 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomTextField(labelName: 'Client name', controller: userNameEditingController, focusNode: focusNode, requestfocusNode: focusNode1, unFocus: false, readOnly: true),
                CustomTextField(labelName: 'Address', controller: addressEditingController, focusNode: focusNode1, requestfocusNode: focusNode2, unFocus: false, readOnly: true),
                PhoneNumber(mineFocus: focusNode2, controller: phoneNumberEditingController, requestFocus: focusNode, style: true, unFocus: false),
                SizedBox(
                  height: 20.h,
                ),
                AgreeButton(
                    onTap: () {
                      clientsController.addClient(clientName: userNameEditingController.text, clientAddress: addressEditingController.text, clientPhoneNumber: phoneNumberEditingController.text);
                    },
                    text: "Add client")
              ],
            ),
          ),
        );
      },
      child: const Icon(IconlyLight.plus),
    );
  }

  Padding searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          leading: const Icon(
            IconlyLight.search,
            color: Colors.black,
          ),
          title: TextField(
            controller: searchEditingController,
            decoration: InputDecoration(hintText: 'search'.tr, border: InputBorder.none),
            onChanged: (String value) {
              clientsController.onSearchTextChanged(value);
            },
          ),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            onPressed: () {
              searchEditingController.clear();
              clientsController.clearFilter();
            },
          ),
        ),
      ),
    );
  }

  ListView listView(List list) {
    return ListView.separated(
      itemCount: list.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (list.length > index) {
          Client client = Client(
              date: list[index]['date'],
              address: list[index]['address'],
              orderCount: int.parse(list[index]['order_count'].toString()),
              name: list[index]['name'],
              number: list[index]['number'],
              sumPrice: double.parse(list[index]['sum_price'].toString()));

          return ClientCard(client: client, count: list.length - index, docID: list[index]['docID']);
        }
        return const SizedBox(
          height: 50,
          width: 150,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.grey.shade200,
          thickness: 1,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            searchWidget(),
            topWidgetTextPart(addMorePadding: true, names: clientNames, ordersView: false, clientView: true, purchasesView: false),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Expanded(child: Obx(() {
              if (clientsController.loadData.value) {
                return spinKit();
              } else {
                if (clientsController.searchResult.isEmpty && searchEditingController.text.isNotEmpty) {
                  return emptyData();
                } else {
                  return listView(clientsController.clients);
                }
              }
            })),
          ],
        ),
        Positioned(
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
              SizedBox(
                width: 30.w,
              ),
              addButton(),
            ],
          ),
        ),
      ],
    );
  }
}
