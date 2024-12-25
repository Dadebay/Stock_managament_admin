import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_managament_admin/app/data/models/client_model.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

import '../customWidget/constants.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({required this.client, required this.count, required this.docID});
  final Client client;
  final int count;
  final String docID;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 60.w,
        child: Text(
          count.toString(),
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
                  client.name,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  client.address,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  client.number,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                ),
              ),
              Expanded(
                child: Text(
                  client.orderCount.toString(),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                ),
              ),
              Expanded(
                child: Text(
                  "${client.sumPrice} \$",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('clients').doc(docID).delete().then((value) {
                      showSnackBar("Done", "${client.name} deleted succesfully", Colors.green);
                    });
                    clientsController.clients.removeWhere((element) => element['number'] == client.number);
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
  }
}
