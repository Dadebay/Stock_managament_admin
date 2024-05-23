import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/data/models/client_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/phone_number.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

import '../controllers/clients_controller.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  final SalesController salesController = Get.put(SalesController());

  final ClientsController clientsController = Get.put(ClientsController());
  @override
  void initState() {
    super.initState();
    clientsController.getAllClients();
  }

  final TextEditingController _userNameEditingController = TextEditingController();
  final TextEditingController _addressEditingController = TextEditingController();
  final TextEditingController _phoneNumberEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: Row(
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
        body: mineBody());
  }

  FloatingActionButton addButton() {
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
                CustomTextField(labelName: 'Client name', controller: _userNameEditingController, focusNode: focusNode, requestfocusNode: focusNode1, unFocus: false, readOnly: true),
                CustomTextField(labelName: 'Address', controller: _addressEditingController, focusNode: focusNode1, requestfocusNode: focusNode2, unFocus: false, readOnly: true),
                PhoneNumber(mineFocus: focusNode2, controller: _phoneNumberEditingController, requestFocus: focusNode, style: true, unFocus: false),
                SizedBox(
                  height: 20.h,
                ),
                AgreeButton(
                    onTap: () {
                      clientsController.addClient(clientName: _userNameEditingController.text, clientAddress: _addressEditingController.text, clientPhoneNumber: _phoneNumberEditingController.text);
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

  List clientNames = [
    {'name': 'Client Name', 'sortName': "name"},
    {'name': 'Address', 'sortName': "address"},
    {'name': 'Client number', 'sortName': "number"},
    {'name': 'Order count', 'sortName': "order_count"},
    {'name': 'Sum price', 'sortName': "sum_price"},
  ];
  TextEditingController searchEditingController = TextEditingController();

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

  Column mineBody() {
    return Column(
      children: [
        searchWidget(),
        topWidgetTextPart(addMorePadding: true, names: clientNames, ordersView: false, clientView: true, purchasesView: false),
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        Expanded(child: Obx(() {
          return clientsController.loadData.value
              ? spinKit()
              : clientsController.searchResult.isNotEmpty
                  ? listView(clientsController.searchResult)
                  : clientsController.clients.isEmpty
                      ? emptyData()
                      : listView(clientsController.clients);
        })),
      ],
    );
  }

  ListView listView(List list) {
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        Client clinet = Client(
            date: list[index]['date'],
            address: list[index]['address'],
            orderCount: int.parse(list[index]['order_count'].toString()),
            name: list[index]['name'],
            number: list[index]['number'],
            sumPrice: double.parse(list[index]['sum_price'].toString()));

        return Row(children: [
          SizedBox(
            width: 60.w,
            child: Text(
              "${index + 1}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 20.sp),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      clinet.name,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      clinet.address,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      clinet.number,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      clinet.orderCount.toString(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${clinet.sumPrice} \$",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('clients').doc(list[index]['docID']).delete().then((value) {
                          showSnackBar("Done", "${clinet.name} deleted succesfully", Colors.green);
                        });
                        clientsController.clients.removeWhere((element) => element['number'] == clinet.number);
                      },
                      icon: const Icon(
                        IconlyLight.delete,
                        color: Colors.red,
                      )),
                ],
              ),
            ),
          )
        ]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.grey.shade200,
          thickness: 1,
        );
      },
    );
  }
}
