import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_admin/app/modules/home/controllers/home_controller.dart';
import 'package:stock_managament_admin/app/modules/nav_bar_page/views/nav_bar_page_view.dart';
import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';
import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
import 'package:stock_managament_admin/constants/customWidget/widgets.dart';

import '../controllers/login_controller.dart';

// ignore: must_be_immutable
class LoginView extends GetView<LoginController> {
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingController1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final HomeController homeController = Get.put(HomeController());
  GetStorage storage = GetStorage();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
              flex: 4,
              child: SizedBox(
                width: Get.size.width,
                height: Get.size.height,
                child: Image.asset(
                  'assets/image/image1.jpg',
                  fit: BoxFit.cover,
                ),
              )),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 40.w),
              alignment: Alignment.center,
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  children: [
                    Text(
                      'login'.tr.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber, fontFamily: gilroyBold, fontSize: 22.sp),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                      child: Text(
                        'Nice to meet you :-)'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontFamily: gilroyBold, fontSize: 18.sp),
                      ),
                    ),
                    CustomTextField(
                      labelName: 'userName',
                      controller: textEditingController,
                      focusNode: focusNode,
                      requestfocusNode: focusNode1,
                      isNumber: false,
                      borderRadius: true,
                      unFocus: false,
                      readOnly: true,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: CustomTextField(
                        labelName: 'userpassword',
                        controller: textEditingController1,
                        focusNode: focusNode1,
                        requestfocusNode: focusNode,
                        isNumber: false,
                        borderRadius: true,
                        unFocus: false,
                        readOnly: true,
                      ),
                    ),
                    Center(
                      child: AgreeButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            bool valueLogin = false;
                            FirebaseFirestore.instance.collection('users').get().then((value) async {
                              homeController.agreeButton.value = !homeController.agreeButton.value;

                              for (var element in value.docs) {
                                if (textEditingController.text.toLowerCase() == element['username'].toString().toLowerCase() &&
                                    textEditingController1.text.toLowerCase() == element['password'].toString().toLowerCase()) {
                                  if (element['active'] == false) {
                                    FirebaseFirestore.instance.collection('users').doc(element.id).update({'active': true});
                                    await storage.write('login', true);

                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const NavBarPageView()));
                                    valueLogin = true;
                                    homeController.agreeButton.value = !homeController.agreeButton.value;
                                  } else {
                                    showSnackBar('errorTitle', 'loginError1', Colors.red);
                                  }
                                }
                              }
                              if (valueLogin == false) {
                                textEditingController.clear();
                                textEditingController1.clear();
                                showSnackBar('errorTitle', 'signInDialog', Colors.red);
                                homeController.agreeButton.value = !homeController.agreeButton.value;
                              }
                            });
                          } else {
                            showSnackBar('errorTitle', 'loginErrorFillBlanks', Colors.red);
                          }
                        },
                        text: "login",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
