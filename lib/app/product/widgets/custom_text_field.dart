// ignore_for_file: deprecated_member_use

import 'package:get/utils.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class CustomTextField extends StatefulWidget {
  final String labelName;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;
  final IconData? prefixIcon;
  final double? prefixIconSize;
  final Widget? prefixIconWidget;
  final int? maxLine;
  final bool? enabled;
  final Function()? onTap;
  final bool isNumberOnly;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool obscureText;
  const CustomTextField({
    required this.labelName,
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    this.maxLine,
    this.isNumberOnly = false,
    this.readOnly = false,
    this.prefixIcon,
    this.prefixIconSize,
    this.prefixIconWidget,
    this.enabled,
    this.onTap,
    Key? key,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure = widget.obscureText;

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
        readOnly: widget.readOnly,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        onEditingComplete: () => widget.requestfocusNode.requestFocus(),
        maxLines: widget.obscureText ? 1 : (widget.maxLine ?? 1),
        obscureText: _obscure,
        keyboardType: widget.isNumberOnly ? TextInputType.number : TextInputType.text,
        inputFormatters: widget.isNumberOnly ? [FilteringTextInputFormatter.digitsOnly] : [],
        focusNode: widget.focusNode,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(minWidth: (widget.prefixIcon == null && widget.prefixIconWidget == null) ? 20 : 10, minHeight: 0),
          prefixIcon: widget.prefixIconWidget != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: widget.prefixIconWidget,
                )
              : widget.prefixIcon == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Icon(
                        widget.prefixIcon,
                        color: ColorConstants.greyColor,
                        size: widget.prefixIconSize ?? WidgetSizes.size32.value,
                      ),
                    ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: ColorConstants.greyColor,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
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
