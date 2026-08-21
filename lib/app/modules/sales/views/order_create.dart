// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/search/views/search_view.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderCreateView extends StatefulWidget {
  const OrderCreateView({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<OrderCreateView> createState() => _OrderCreateViewState();
}

class _OrderCreateViewState extends State<OrderCreateView> {
  List<FocusNode> focusNodes = List.generate(9, (_) => FocusNode());
  final SearchViewController _searchController =
      Get.find<SearchViewController>();

  String selectedStatus = "Preparing"; // Set an initial value
  List<TextEditingController> textControllers =
      List.generate(9, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textControllers[0].text = DateTime.now().toString().substring(0, 19);
    _searchController.selectedProductsToOrder.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: CustomAppBar(
          backArrow: true,
          centerTitle: true,
          actionIcon: false,
          name: 'createOrder'.tr),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
                    title: 'Sargyt maglumatlary',
                    subtitle: 'Sargydyň esasy maglumatlaryny dolduryň.',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final twoColumns = constraints.maxWidth > 680;
                        final width = twoColumns
                            ? (constraints.maxWidth - 16.w) / 2
                            : constraints.maxWidth;
                        return Wrap(spacing: 16.w, runSpacing: 14.h, children: [
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'date',
                                  controller: textControllers[0],
                                  focusNode: focusNodes[0],
                                  readOnly: true,
                                  suffix: Icons.calendar_today_outlined,
                                  onTap: _pickDate)),
                          SizedBox(width: width, child: _statusField()),
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'package',
                                  controller: textControllers[1],
                                  focusNode: focusNodes[1],
                                  nextFocus: focusNodes[2],
                                  icon: Icons.inventory_2_outlined)),
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'Coupon',
                                  controller: textControllers[5],
                                  focusNode: focusNodes[5],
                                  nextFocus: focusNodes[6],
                                  icon: Icons.confirmation_number_outlined)),
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'Discount',
                                  controller: textControllers[7],
                                  focusNode: focusNodes[6],
                                  nextFocus: focusNodes[7],
                                  icon: Icons.percent_rounded,
                                  number: true)),
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'note',
                                  controller: textControllers[6],
                                  focusNode: focusNodes[7],
                                  icon: Icons.notes_rounded,
                                  maxLines: 2)),
                        ]);
                      },
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _sectionCard(
                    title: 'Müşderi maglumatlary',
                    subtitle:
                        'Eltip bermek üçin müşderiniň maglumatlaryny goşuň.',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final twoColumns = constraints.maxWidth > 680;
                        final width = twoColumns
                            ? (constraints.maxWidth - 16.w) / 2
                            : constraints.maxWidth;
                        return Wrap(spacing: 16.w, runSpacing: 14.h, children: [
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'phone',
                                  controller: textControllers[2],
                                  focusNode: focusNodes[2],
                                  nextFocus: focusNodes[3],
                                  icon: Icons.phone_outlined,
                                  number: true,
                                  prefix: '+993 ',
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'loginErrorFillBlanks'.tr
                                          : null)),
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'userName',
                                  controller: textControllers[3],
                                  focusNode: focusNodes[3],
                                  nextFocus: focusNodes[4],
                                  icon: Icons.person_outline,
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'loginErrorFillBlanks'.tr
                                          : null)),
                          SizedBox(
                              width: width,
                              child: _webField(
                                  label: 'clientAddress',
                                  controller: textControllers[4],
                                  focusNode: focusNodes[4],
                                  icon: Icons.location_on_outlined)),
                        ]);
                      },
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _sectionCard(
                    title: 'Harytlar',
                    subtitle: 'Sargyda goşuljak harytlary saýlaň.',
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          selectedProductsView(),
                          SizedBox(height: 10.h),
                          OutlinedButton.icon(
                            onPressed: () => Get.to(() => SearchView(
                                selectableProducts: true,
                                hideAppBar: false,
                                addCounterWidget: true,
                                isAdmin: widget.isAdmin)),
                            icon: const Icon(Icons.add_shopping_cart_outlined,
                                size: 18),
                            label: Text('selectProducts'.tr),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 42),
                                side:
                                    const BorderSide(color: Color(0xff4F46E5)),
                                foregroundColor: const Color(0xff4F46E5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ]),
                  ),
                  SizedBox(height: 18.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text('agree'.tr),
                      style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff4F46E5),
                          minimumSize: const Size(150, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
          {required String title,
          required String subtitle,
          required Widget child}) =>
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffE2E8F0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 18,
                  offset: Offset(0, 5))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff172033))),
          SizedBox(height: 3.h),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 12.sp, color: const Color(0xff64748B))),
          SizedBox(height: 18.h),
          child,
        ]),
      );

  Widget _webField(
          {required String label,
          required TextEditingController controller,
          required FocusNode focusNode,
          FocusNode? nextFocus,
          IconData? icon,
          IconData? suffix,
          bool readOnly = false,
          bool number = false,
          int maxLines = 1,
          String? prefix,
          VoidCallback? onTap,
          String? Function(String?)? validator}) =>
      TextFormField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        maxLines: maxLines,
        validator: validator,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        onTap: onTap,
        onFieldSubmitted: (_) => nextFocus?.requestFocus(),
        style: TextStyle(fontSize: 14.sp, color: const Color(0xff172033)),
        decoration: InputDecoration(
            labelText: label.tr,
            prefixText: prefix,
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 18, color: const Color(0xff64748B)),
            suffixIcon: suffix == null
                ? null
                : Icon(suffix, size: 17, color: const Color(0xff64748B)),
            filled: true,
            fillColor: const Color(0xffF8FAFC),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffDCE4EF))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffDCE4EF))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xff4F46E5), width: 1.3))),
      );

  Widget _statusField() => DropdownButtonFormField<String>(
        value: selectedStatus,
        decoration: InputDecoration(
            labelText: 'status'.tr,
            prefixIcon: const Icon(Icons.local_shipping_outlined,
                size: 18, color: Color(0xff64748B)),
            filled: true,
            fillColor: const Color(0xffF8FAFC),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffDCE4EF)))),
        items: const [
          'Preparing',
          'Ready to ship',
          'Shipped',
          'Canceled',
          'Refund'
        ]
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => setState(() => selectedStatus = value!),
      );

  Future<void> _pickDate() async {
    final result =
        await CustomWidgets.showDateTimePickerWidget(context: context);
    if (result != null)
      setState(() => textControllers[0].text =
          DateFormat('yyyy-MM-dd, HH:mm').format(result));
  }

  final OrderController _orderController = Get.find<OrderController>();

  Future<void> _submit() async {
    int key = 0;
    for (var status in StringConstants.statusMapping) {
      if (status['name'] == selectedStatus) {
        key = int.parse(status['sortName'].toString());
      }
    }
    if (_formKey.currentState!.validate()) {
      print('\n===== ORDER CREATE VIEW DEBUG =====');
      print('Selected Status: $selectedStatus');
      print('Status Key: $key');
      print('Date: ${textControllers[0].text}');
      print('Package/Gaplama: ${textControllers[1].text}');
      print('Phone: ${textControllers[2].text}');
      print('Client Name: ${textControllers[3].text}');
      print('Client Address: ${textControllers[4].text}');
      print('Coupon: ${textControllers[5].text}');
      print('Description: ${textControllers[6].text}');
      print('Discount (raw): "${textControllers[7].text}"');
      print('Discount isEmpty: ${textControllers[7].text.isEmpty}');
      print(
          'Discount parsed: ${double.tryParse(textControllers[7].text.isEmpty ? "0" : textControllers[7].text)}');

      List<Map<String, int>> products = [];
      _searchController.selectedProductsToOrder.forEach(
        (element) {
          products
              .add({'id': element['product'].id, 'count': element['count']});
        },
      );

      print('Products count: ${products.length}');
      print('Products: $products');

      // Discount değerini temizle ve parse et
      String discountText = textControllers[7].text.trim();
      if (discountText.isEmpty) {
        discountText = "0";
      }

      print('Cleaned discount: "$discountText"');
      print('===================================\n');

      final OrderModel model = OrderModel(
        id: 0,
        status: key.toString(),
        date: textControllers[0].text.substring(0, 10),
        gaplama: textControllers[1].text,
        coupon: textControllers[5].text,
        discount: discountText,
        description: textControllers[6].text,
        name: "${textControllers[3].text} - ${textControllers[2].text}",
        clientID: 0,
        clientDetailModel: ClientDetailModel(
          id: 0,
          name: textControllers[3].text,
          address: textControllers[4].text,
          phone: textControllers[2].text,
          description: textControllers[6].text,
          ordercount: '',
          sumprice: '',
        ),
        products: [],
        count: _searchController.selectedProductsToOrder.length,
        totalsum: '',
        totalchykdajy: '',
      );
      await _orderController.createNewOrder(model: model, products: products);
    } else {
      CustomWidgets.showSnackBar(
          'errorTitle', 'loginErrorFillBlanks', Colors.red);
    }
  }

  Obx selectedProductsView() {
    return Obx(() {
      return _searchController.selectedProductsToOrder.isEmpty
          ? const SizedBox.shrink()
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('selectedProducts'.tr,
                  style: TextStyle(
                      color: const Color(0xff172033),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              ListView.separated(
                itemCount: _searchController.selectedProductsToOrder.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (BuildContext context, int index) {
                  final SearchModel product = _searchController
                      .selectedProductsToOrder[index]['product'];
                  return SearchCard(
                      product: product,
                      disableOnTap: false,
                      addCounterWidget: true,
                      isAdmin: widget.isAdmin,
                      whcihPage: '',
                      counter:
                          _searchController.selectedProductsToOrder.length -
                              index);
                },
              ),
            ]);
    });
  }
}
