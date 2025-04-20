import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({super.key, this.onChanged, this.onClear, required this.controller});
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padding.low,
      child: Card(
        child: ListTile(
          leading: const Icon(
            IconlyLight.search,
            color: Colors.black,
          ),
          title: TextField(controller: controller, decoration: InputDecoration(hintText: 'search'.tr, border: InputBorder.none), onChanged: onChanged),
          contentPadding: EdgeInsets.only(left: 15.w),
          trailing: IconButton(icon: const Icon(CupertinoIcons.xmark_circle), onPressed: onClear),
        ),
      ),
    );
  }
}
