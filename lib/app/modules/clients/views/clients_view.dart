import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/data/models/client_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/sales_controller.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return mineBody();
  }

  List clientNames = [
    {'name': 'Client Name', 'sortName': "name"},
    {'name': 'Address', 'sortName': "address"},
    {'name': 'Client number', 'sortName': "number"},
    {'name': 'Order count', 'sortName': "order_count"},
    {'name': 'Sum price', 'sortName': "sum_price"},
  ];
  TextEditingController controller = TextEditingController();

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
            controller: controller,
            decoration: InputDecoration(hintText: 'search'.tr, border: InputBorder.none),
            onChanged: (String value) {
              clientsController.onSearchTextChanged(value);
            },
          ),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle),
            onPressed: () {
              controller.clear();
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
        topWidgetTextPart(true, clientNames, false, true),
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
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${clinet.sumPrice} \$",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                    ),
                  ),
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

  void addExpences({required BuildContext context, required bool edit, required String docID, required String cost, required String name, required String note, required String date}) {}
}
