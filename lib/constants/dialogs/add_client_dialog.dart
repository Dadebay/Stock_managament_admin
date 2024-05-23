// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:stock_managament_admin/constants/buttons/agree_button_view.dart';
// import 'package:stock_managament_admin/constants/customWidget/custom_text_field.dart';
// import 'package:stock_managament_admin/constants/customWidget/phone_number.dart';

// dynamic addClientDialog({required TextEditingController }){
//     Get.defaultDialog(
//           title: "Add client",
//           contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
//           content: SizedBox(
//             width: Get.size.width / 3,
//             height: Get.size.height / 3,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 CustomTextField(labelName: 'Client name', controller: _userNameEditingController, focusNode: focusNode, requestfocusNode: focusNode1, unFocus: false, readOnly: true),
//                 CustomTextField(labelName: 'Address', controller: _addressEditingController, focusNode: focusNode1, requestfocusNode: focusNode2, unFocus: false, readOnly: true),
//                 PhoneNumber(mineFocus: focusNode2, controller: _phoneNumberEditingController, requestFocus: focusNode, style: true, unFocus: false),
//                 SizedBox(
//                   height: 20.h,
//                 ),
//                 AgreeButton(
//                     onTap: () {
//                       clientsController.addClient(clientName: _userNameEditingController.text, clientAddress: _addressEditingController.text, clientPhoneNumber: _phoneNumberEditingController.text);
//                     },
//                     text: "Add client")
//               ],
//             ),
//           ),
//         );
// }