import 'package:get/utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class CustomTextField extends StatefulWidget {
  final String labelName;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;
  final IconData? prefixIcon;
  final int? maxLine;
  final bool? enabled;
  final Function()? onTap;

  const CustomTextField({
    required this.labelName,
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    this.maxLine,
    this.prefixIcon,
    this.enabled,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: context.padding.onlyTopNormal,
      child: TextFormField(
        style: context.general.textTheme.bodyLarge!.copyWith(color: widget.enabled == false ? ColorConstants.greyColor : ColorConstants.blackColor, fontSize: 16.sp, fontWeight: FontWeight.w600),
        enabled: widget.enabled ?? true,
        controller: widget.controller,
        onTap: widget.onTap,
        validator: (value) {
          if (value == null || value.isEmpty) return 'textfield_error'.tr;
          return null;
        },
        onEditingComplete: () => widget.requestfocusNode.requestFocus(),
        keyboardType: TextInputType.text,
        maxLines: widget.maxLine ?? 1,
        focusNode: widget.focusNode,
        textInputAction: TextInputAction.done,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(minWidth: widget.prefixIcon == null ? 20 : 10, minHeight: 0),
          prefixIcon: widget.prefixIcon == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    widget.prefixIcon,
                    color: ColorConstants.greyColor,
                    size: WidgetSizes.size32.value,
                  ),
                ),
          labelText: widget.labelName.tr,
          labelStyle: context.general.textTheme.bodyLarge!.copyWith(color: ColorConstants.greyColor, fontSize: 16.sp, fontWeight: FontWeight.w500),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          contentPadding: context.padding.normal,
          isDense: true,
          alignLabelWithHint: true,
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
