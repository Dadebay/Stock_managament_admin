import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_hide/scroll_to_hide.dart';
import 'package:stock_managament_admin/app/data/models/expences_model.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

import '../../home/controllers/home_controller.dart';

class ExpencesView extends StatefulWidget {
  const ExpencesView({super.key});

  @override
  State<ExpencesView> createState() => _ExpencesViewState();
}

class _ExpencesViewState extends State<ExpencesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('expences').get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var document in querySnapshot.docs) {
        sumPrice += double.parse(document['cost'].toString());
      }
    }
    setState(() {});
  }

  double sumPrice = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            addExpences(context: context, edit: false, cost: '', docID: '', name: '', note: '', date: '');
          },
          child: const Icon(IconlyLight.plus),
        ),
        body: mineBody(),
        bottomNavigationBar: ScrollToHide(
            scrollController: _scrollController,
            height: 60, // Initial height of the bottom navigation bar.
            hideDirection: Axis.vertical,
            child: Column(
              children: [
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Sum of expences :",
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        " $sumPrice TMT",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  Column mineBody() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.w, right: 20.w, top: 10.h, bottom: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Expences name",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                ),
              ),
              const Expanded(child: SizedBox()),
              Expanded(
                child: Text(
                  "Date",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                ),
              ),
              Expanded(
                child: Text(
                  "Cost",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                ),
              ),
              Expanded(
                child: Text(
                  "Note",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        Expanded(
          child: FirestorePagination(
            limit: 20, // Defaults to 10.
            isLive: true, // Defaults to false.
            viewType: ViewType.list,
            reverse: false,
            query: FirebaseFirestore.instance.collection('expences').orderBy("date", descending: true),
            itemBuilder: (context, documentSnapshot, index) {
              final data = documentSnapshot.data() as Map<String, dynamic>?;
              if (data == null) return Container();

              final expence = ExpencesModel(date: data['date'], name: data['name'], note: data['note'], cost: data['cost']);
              return GestureDetector(
                onTap: () {
                  addExpences(context: context, edit: true, docID: documentSnapshot.id, cost: expence.cost!, name: expence.name!, note: expence.note!, date: expence.date!);
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          expence.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 14.sp),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: Text(
                          "${expence.date}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${expence.cost} TMT",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${expence.note}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontFamily: gilroyRegular, fontSize: 14.sp),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('expences').doc(documentSnapshot.id).delete().then((value) {
                              sumPrice -= double.parse(expence.cost.toString());
                              showSnackBar("Done", "${expence.name} deleted succefully", Colors.green);
                              setState(() {});
                            });
                          },
                          icon: const Icon(
                            IconlyLight.delete,
                            color: Colors.red,
                          )),
                      SizedBox(
                        width: 20.w,
                      ),
                      const Icon(IconlyLight.editSquare)
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                height: 5,
                thickness: 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<dynamic> addExpences({required BuildContext context, required bool edit, required String docID, required String cost, required String name, required String note, required String date}) {
    TextEditingController nameEditingController = TextEditingController();
    TextEditingController noteEditingController = TextEditingController();
    TextEditingController costEditingController = TextEditingController();
    TextEditingController dateEditingController = TextEditingController();
    FocusNode focusNode = FocusNode();
    FocusNode focusNode1 = FocusNode();
    FocusNode focusNode2 = FocusNode();
    FocusNode focusNode3 = FocusNode();
    if (edit == true) {
      nameEditingController.text = name;
      dateEditingController.text = date;
      costEditingController.text = cost;
      noteEditingController.text = note;
    }
    DateTime? selectedDateTime;

    showDateTimePicker(BuildContext context) async {
      final result = await showDateTimePickerWidget(context: context);
      if (result != null) {
        setState(() {
          selectedDateTime = result;
          dateEditingController.text = DateFormat('HH:mm, MMM d, yyyy').format(selectedDateTime!);
        });
      }
    }

    final HomeController homeController = Get.put(HomeController());
    return Get.defaultDialog(
        title: edit == true ? 'Change expence data' : 'Add expence',
        titlePadding: const EdgeInsets.only(top: 20),
        titleStyle: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 30.sp),
        content: SizedBox(
          width: Get.size.width / 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(labelName: 'Name', controller: nameEditingController, focusNode: focusNode, requestfocusNode: focusNode, unFocus: true, readOnly: true),
              CustomTextField(labelName: 'Cost', controller: costEditingController, focusNode: focusNode1, requestfocusNode: focusNode2, unFocus: true, readOnly: true),
              CustomTextField(labelName: 'Note', maxline: 3, controller: noteEditingController, focusNode: focusNode2, requestfocusNode: focusNode3, unFocus: true, readOnly: true),
              CustomTextField(
                  labelName: 'Date',
                  onTap: () {
                    showDateTimePicker(context);
                  },
                  controller: dateEditingController,
                  focusNode: focusNode3,
                  requestfocusNode: focusNode,
                  unFocus: true,
                  readOnly: true),
              const SizedBox(
                height: 30,
              ),
              AgreeButton(
                  onTap: () async {
                    homeController.agreeButton.value = !homeController.agreeButton.value;
                    if (edit == true) {
                      await FirebaseFirestore.instance.collection('expences').doc(docID).update({
                        'name': nameEditingController.text,
                        'note': noteEditingController.text,
                        'cost': costEditingController.text,
                        'date': dateEditingController.text,
                      }).then((value) {
                        Get.back();
                        showSnackBar('Changed', "Expences changed succesfully", Colors.green);
                        homeController.agreeButton.value = !homeController.agreeButton.value;
                      });
                    } else {
                      await FirebaseFirestore.instance.collection('expences').add({
                        'name': nameEditingController.text,
                        'note': noteEditingController.text,
                        'cost': costEditingController.text,
                        'date': dateEditingController.text,
                      }).then((value) {
                        Get.back();
                        showSnackBar('Done', "Expences added succesfully", Colors.green);
                        homeController.agreeButton.value = !homeController.agreeButton.value;
                      });
                    }
                    sumPrice += double.parse(costEditingController.text.toString());
                  },
                  text: edit ? "Edit" : "add".tr)
            ],
          ),
        ));
  }
}
