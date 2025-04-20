// ignore_for_file: file_names, must_be_immutable, use_key_in_widget_constructors

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class PhoneNumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode mineFocus;
  final FocusNode requestFocus;
  final bool style;
  final bool? disabled;
  final bool unFocus;
  const PhoneNumberTextField({required this.mineFocus, required this.controller, required this.requestFocus, required this.style, this.disabled, required this.unFocus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: TextFormField(
        enabled: disabled ?? true,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        cursorColor: Colors.black,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        focusNode: mineFocus,
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return 'errorEmpty'.tr;
          } else if (value.length != 8) {
            return 'errorPhoneCount'.tr;
          }
          return null;
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(8),
        ],
        onEditingComplete: () {
          unFocus ? FocusScope.of(context).unfocus() : requestFocus.requestFocus();
        },
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          errorMaxLines: 2,
          errorStyle: const TextStyle(),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(
              left: 15,
            ),
            child: Text(
              '+ 993',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 25, top: 16, bottom: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 70),
          isDense: true,
          hintText: '65 656565 ',
          alignLabelWithHint: true,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          border: _buildOutlineInputBorder(borderColor: ColorConstants.blackColor),
          enabledBorder: _buildOutlineInputBorder(borderColor: ColorConstants.greyColor.withOpacity(.5)),
          focusedBorder: _buildOutlineInputBorder(borderColor: ColorConstants.kPrimaryColor),
          focusedErrorBorder: _buildOutlineInputBorder(borderColor: ColorConstants.redColor),
          errorBorder: _buildOutlineInputBorder(borderColor: ColorConstants.redColor),
        ),
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 2),
    );
  }
}
