import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

class FourInOnePageView extends StatefulWidget {
  const FourInOnePageView({super.key});

  @override
  State<FourInOnePageView> createState() => _FourInOnePageViewState();
}

class _FourInOnePageViewState extends State<FourInOnePageView> {
  // ignore: non_constant_identifier_names
  List four_in_one_names = [
    {'name': 'brands', 'pageView': "Brands", "countName": 'brand'},
    {'name': 'categories', 'pageView': "Categories", "countName": 'category'},
    {'name': 'locations', 'pageView': "Locations", "countName": 'location'},
    {'name': 'materials', 'pageView': "Materials", "countName": 'material'},
  ];

  FloatingActionButton addDataButtonFourInONe() {
    return FloatingActionButton(
        onPressed: () {
          Get.defaultDialog(
            title: "Add Data",
            titleStyle: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 32.sp),
            content: SizedBox(
              height: Get.height / 3,
              width: Get.size.width / 3,
              child: ListView.builder(
                itemCount: four_in_one_names.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Get.back();
                      fourInOneEditFields('', '', '', '', false, index: index);
                    },
                    title: Text(
                      four_in_one_names[index]['pageView'],
                      style: TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 28.sp),
                    ),
                    trailing: const Icon(IconlyLight.plus),
                  );
                },
              ),
            ),
          );
        },
        child: const Icon(IconlyLight.plus));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        page(),
        Positioned(bottom: 15, right: 15, child: addDataButtonFourInONe()),
      ],
    );
  }

  ListView page() {
    return ListView.builder(
      itemCount: four_in_one_names.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ExpansionTile(
          title: Text(
            four_in_one_names[index]['pageView'],
            style: TextStyle(color: Colors.black, fontFamily: gilroyMedium, fontSize: 18.sp),
          ),
          children: [
            FutureBuilder(
              future: FirebaseFirestore.instance.collection(four_in_one_names[index]['name']).get(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (ConnectionState.waiting == snapshot.connectionState) {
                  return spinKit();
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int indexx) {
                      return ListTile(
                        title: Text(snapshot.data!.docs[indexx]['name'] + "  -  " + snapshot.data!.docs[indexx]['quantity'].toString() + " sany "),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  fourInOneEditFields(snapshot.data!.docs[indexx]['name'], snapshot.data!.docs[indexx]['note'], index == 2 ? snapshot.data!.docs[indexx]['address'] : '',
                                      snapshot.data!.docs[indexx].id, true,
                                      index: index);
                                },
                                icon: const Icon(
                                  IconlyLight.editSquare,
                                  color: Colors.green,
                                )),
                            IconButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection(four_in_one_names[index]['name']).doc(snapshot.data!.docs[indexx].id).delete().then((value) {
                                    showSnackBar("Done", snapshot.data!.docs[indexx]['name'] + " deleted succefully", Colors.green);
                                    setState(() {});
                                  });
                                },
                                icon: const Icon(
                                  IconlyLight.delete,
                                  color: Colors.red,
                                )),
                          ],
                        ),
                      );
                    },
                  );
                }
                return emptyData();
              },
            )
          ],
        );
      },
    );
  }

  Future<dynamic> fourInOneEditFields(String? firstText, String? secondText, String? thirdText, String? docID, bool? edit, {required int index}) {
    TextEditingController nameEditingController = TextEditingController();
    TextEditingController noteEditingController = TextEditingController();
    TextEditingController addressEditingController = TextEditingController();
    FocusNode focusNode = FocusNode();
    FocusNode focusNode1 = FocusNode();
    FocusNode focusNode2 = FocusNode();
    final HomeController homeController = Get.put(HomeController());
    if (edit == true) {
      nameEditingController.text = firstText!;
      noteEditingController.text = secondText!;
      addressEditingController.text = thirdText!;
    }
    return Get.defaultDialog(
        title: four_in_one_names[index]['pageView'],
        titleStyle: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 32.sp),
        content: SizedBox(
          width: Get.size.width / 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(labelName: 'Name', controller: nameEditingController, focusNode: focusNode, requestfocusNode: focusNode1, unFocus: true, readOnly: true),
              CustomTextField(labelName: 'Note', controller: noteEditingController, focusNode: focusNode1, requestfocusNode: index == 2 ? focusNode2 : focusNode, unFocus: true, readOnly: true),
              index == 2
                  ? CustomTextField(labelName: 'Address', controller: addressEditingController, focusNode: focusNode2, requestfocusNode: focusNode, unFocus: true, readOnly: true)
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 30,
              ),
              AgreeButton(
                  onTap: () async {
                    homeController.agreeButton.value = !homeController.agreeButton.value;
                    if (index == 2) {
                      if (edit == true) {
                        await FirebaseFirestore.instance.collection(four_in_one_names[index]['name']).doc(docID).update({
                          'name': nameEditingController.text,
                          'note': noteEditingController.text,
                          'address': noteEditingController.text,
                          'quantity': 0,
                        }).then((value) {
                          Get.back();
                          setState(() {});
                          showSnackBar('Done', "${nameEditingController.text} added succesfully", Colors.green);
                          homeController.agreeButton.value = !homeController.agreeButton.value;
                        });
                      } else {
                        await FirebaseFirestore.instance.collection(four_in_one_names[index]['name']).add({
                          'name': nameEditingController.text,
                          'note': noteEditingController.text,
                          'address': noteEditingController.text,
                          'quantity': 0,
                        }).then((value) {
                          Get.back();
                          setState(() {});
                          showSnackBar('Done', "${nameEditingController.text} added succesfully", Colors.green);
                          homeController.agreeButton.value = !homeController.agreeButton.value;
                        });
                      }
                    } else {
                      if (edit == true) {
                        await FirebaseFirestore.instance.collection(four_in_one_names[index]['name']).doc(docID).update({
                          'name': nameEditingController.text,
                          'note': noteEditingController.text,
                          'quantity': 0,
                        }).then((value) {
                          Get.back();
                          setState(() {});
                          showSnackBar('Done', "${nameEditingController.text} added succesfully", Colors.green);
                          homeController.agreeButton.value = !homeController.agreeButton.value;
                        });
                      } else {
                        await FirebaseFirestore.instance.collection(four_in_one_names[index]['name']).add({
                          'name': nameEditingController.text,
                          'note': noteEditingController.text,
                          'quantity': 0,
                        }).then((value) {
                          Get.back();
                          setState(() {});
                          showSnackBar('Done', "${nameEditingController.text} added succesfully", Colors.green);
                          homeController.agreeButton.value = !homeController.agreeButton.value;
                        });
                      }
                    }
                  },
                  text: edit == true ? "Change" : "add".tr)
            ],
          ),
        ));
  }
}
