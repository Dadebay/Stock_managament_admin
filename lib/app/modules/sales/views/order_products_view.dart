// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class OrderProductsView extends StatefulWidget {
  final OrderModel order;
  final bool isAdmin;
  const OrderProductsView(
      {super.key, required this.order, required this.isAdmin});

  @override
  State<OrderProductsView> createState() => _OrderProductsViewState();
}

class _OrderProductsViewState extends State<OrderProductsView> {
  final OrderController orderController = Get.find<OrderController>();
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  List<Map<String, dynamic>> buildOrderDetailsFields(OrderModel order) {
    return [
      {'label': 'status', 'editable': true},
      {'label': 'date', 'editable': true},
      {'label': 'clientName', 'editable': true}, // Bu alan için sorun yaşanıyor
      {'label': 'phone', 'editable': true},
      {'label': 'address', 'editable': true},
      {'label': 'gaplama', 'editable': true},
      {'label': 'discount', 'editable': true},
      {'label': 'coupon', 'editable': true},
      {'label': 'description', 'editable': true},
      {'label': 'count', 'editable': true},
      {'label': 'cost', 'editable': true},
      {'label': 'totalIncome', 'editable': true},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final fieldDefinitions = buildOrderDetailsFields(_currentOrder);
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: CustomAppBar(
        backArrow: true,
        centerTitle: true,
        actionIcon: widget.isAdmin ? true : false,
        icon: IconButton(
          onPressed: () async {
            final russian = Get.locale?.languageCode == 'ru';
            final confirm = await ConfirmDialog.show(
              title: russian ? 'Удалить заказ' : 'Sargydy pozmak',
              message: russian
                  ? 'Подтвердите удаление этого заказа.'
                  : 'Soňkyra dowam etmek isleseňiz, bu sargydy pozuň.',
            );
            if (confirm == true) {
              // await OrderService().deleteOrder(model: _currentOrder);
              orderController.deleteOrderFromUI(model: _currentOrder);
            }
          },
          icon: Icon(IconlyLight.delete, color: Colors.red),
        ),
        name: _currentOrder.name,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1480),
          child: ListView(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
            children: [
              Text('Sargyt maglumatlary',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff172033))),
              SizedBox(height: 4.h),
              Text(
                  widget.isAdmin
                      ? 'Kartlara basyp maglumatlary üýtgedip bilersiňiz.'
                      : 'Sargyt maglumatlary.',
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xff64748B))),
              SizedBox(height: 16.h),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth > 1040
                    ? 3
                    : constraints.maxWidth > 660
                        ? 2
                        : 1;
                final width =
                    (constraints.maxWidth - ((columns - 1) * 12.w)) / columns;
                return Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: List.generate(fieldDefinitions.length, (index) {
                    final fieldDef = fieldDefinitions[index];
                    return SizedBox(
                      width: width,
                      child: OrderDetailField(
                        key: ValueKey(
                            _currentOrder.id.toString() + fieldDef['label']!),
                        label: fieldDef['label']!,
                        isEditable: fieldDef['editable'] as bool,
                        currentOrder: _currentOrder,
                        onUpdate: (updatedOrderFromField) {
                          setState(() => _currentOrder = updatedOrderFromField);
                          orderController
                              .editOrderInList(updatedOrderFromField);
                        },
                        isAdmin: widget.isAdmin,
                      ),
                    );
                  }),
                );
              }),
              SizedBox(height: 26.h),
              Text('Harytlar',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff172033))),
              SizedBox(height: 12.h),
              if (_currentOrder.products.isNotEmpty)
                ListviewTopText<SearchModel>(
                  names: StringConstants.searchViewtopPartNames,
                  listToSort: _currentOrder.products,
                  setSortedList: (newList) {},
                  getSortValue: (model, key) =>
                      orderController.getProductSortValue(model, key),
                ),
              _buildProductList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (_currentOrder.id == 0) {
      return SizedBox(
          height: 300, child: Center(child: Text("Order ID is missing".tr)));
    }
    return FutureBuilder<List<ProductModel>>(
      future: OrderService().getOrderProduct(_currentOrder.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CustomWidgets.spinKit();
        if (snapshot.hasError)
          return SizedBox(
              height: 300,
              child: Center(child: Text('Error: ${snapshot.error}'.tr)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (_currentOrder.products.isNotEmpty) {
            final products = _currentOrder.products;
            return ListView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return SearchCard(
                    product: products[index],
                    disableOnTap: true,
                    addCounterWidget: false,
                    isAdmin: widget.isAdmin,
                    whcihPage: '',
                  );
                });
          }
          return SizedBox(height: 300, child: CustomWidgets.emptyData());
        }

        final products = snapshot.data!;
        return ListView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final productModel = products[index];
              if (productModel.product == null) {
                return _deletedProductCard(count: productModel.count);
              }
              return SearchCard(
                product: productModel.product!,
                externalCount: productModel.count,
                disableOnTap: true,
                addCounterWidget: false,
                isAdmin: widget.isAdmin,
                whcihPage: '',
                counter: products.length - index,
              );
            });
      },
    );
  }

  Widget _deletedProductCard({required int count}) {
    final russian = Get.locale?.languageCode == 'ru';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.hide_image_outlined,
              color: Color(0xffDC2626), size: 19),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(russian ? 'Товар удалён' : 'Haryt pozulan',
                style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff172033))),
            SizedBox(height: 2.h),
            Text(
                russian
                    ? 'Этот товар был удалён из каталога'
                    : 'Bu haryt kataloglardan pozulypdyr',
                style:
                    TextStyle(fontSize: 11.5.sp, color: const Color(0xff64748B))),
          ]),
        ),
        Text('x$count',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xff64748B))),
      ]),
    );
  }
}

class OrderDetailField extends StatefulWidget {
  final String label;
  final bool isEditable;
  final bool isAdmin;
  final OrderModel currentOrder;
  final Function(OrderModel) onUpdate;

  const OrderDetailField({
    super.key,
    required this.label,
    required this.isEditable,
    required this.currentOrder,
    required this.onUpdate,
    required this.isAdmin,
  });

  @override
  State<OrderDetailField> createState() => _OrderDetailFieldState();
}

class _OrderDetailFieldState extends State<OrderDetailField> {
  late String _displayedValue;
  @override
  void initState() {
    super.initState();
    _displayedValue = _getValue(widget.label, widget.currentOrder);
  }

  @override
  void didUpdateWidget(covariant OrderDetailField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentOrder != oldWidget.currentOrder) {
      final newValue = _getValue(widget.label, widget.currentOrder);
      if (_displayedValue != newValue) {
        setState(() {
          _displayedValue = newValue;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _displayedValue = _getValue(widget.label, widget.currentOrder);
    return GestureDetector(
      onTap: !widget.isEditable
          ? null
          : () {
              if (widget.isAdmin)
                showEditDialog(
                  context: context,
                  label: widget.label,
                  initialValue: _displayedValue, // Dialog için başlangıç değeri
                  currentOrder: widget.currentOrder,
                  onSave: (locallyUpdatedOrder) async {
                    print('\n========== ORDER FIELD SAVE START ==========');
                    print('Field: ${widget.label}');
                    print('Order ID: ${locallyUpdatedOrder.id}');
                    print(
                        'Local value prepared for save: ${_getValue(widget.label, locallyUpdatedOrder)}');

                    final updatedOrderFromBackend = await OrderService()
                        .editOrderManually(model: locallyUpdatedOrder);

                    if (updatedOrderFromBackend != null) {
                      print(
                          'Backend update success. Applying backend response to UI.');
                      print(
                          'Backend value after save: ${_getValue(widget.label, updatedOrderFromBackend)}');
                      widget.onUpdate(updatedOrderFromBackend);
                    } else {
                      print(
                          'Backend update failed or returned null. UI will not be updated from local draft.');
                    }

                    print('========== ORDER FIELD SAVE END ==========\n');
                  },
                );
            },
      child: Container(
        constraints: BoxConstraints(minHeight: 82.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x080F172A), blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(widget.label.tr,
                    style: TextStyle(
                        color: const Color(0xff64748B),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500))),
            if (widget.isAdmin && widget.isEditable)
              const Icon(Icons.edit_outlined,
                  size: 15, color: Color(0xff94A3B8)),
          ]),
          SizedBox(height: 8.h),
          if (widget.label == 'status')
            _statusPill()
          else
            Text(_displayedValue,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: const Color(0xff172033),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _statusPill() {
    final status = StringConstants.statusMapping.firstWhere(
      (item) => item['name'] == _displayedValue,
      orElse: () => {'name': _displayedValue, 'color': const Color(0xff64748B)},
    );
    final color = status['color'] as Color? ?? const Color(0xff64748B);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text('${status['name']}'.tr,
          style: TextStyle(
              color: color, fontSize: 12.sp, fontWeight: FontWeight.w600)),
    );
  }

  void showEditDialog({
    required BuildContext context,
    required String label,
    required String initialValue,
    required OrderModel currentOrder,
    required Function(OrderModel) onSave,
  }) {
    final TextEditingController controller = TextEditingController();

    if (label == 'status') {
      _showStatusDialog(currentOrder, onSave);
      return;
    }

    if (label == 'discount') {
      controller.text = currentOrder.discount.replaceAll(" % ", "").trim();
    } else if (label == 'phone') {
      final phoneNum = currentOrder.clientDetailModel?.phone ?? '';
      controller.text =
          phoneNum.startsWith('+993') ? phoneNum.substring(4) : phoneNum;
    } else {
      controller.text = initialValue == 'N/A' ? '' : initialValue;
    }

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: Padding(
            padding: EdgeInsets.all(22.w),
            child: StatefulBuilder(
                builder: (dialogContext, setStateDialog) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                    color: const Color(0xffEEF2FF),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.edit_outlined,
                                    size: 19, color: Color(0xff4F46E5))),
                            SizedBox(width: 12.w),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('${label.tr} üýtget',
                                      style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xff172033))),
                                  Text('Maglumaty täze baha bilen çalşyryň.',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: const Color(0xff64748B)))
                                ])),
                            IconButton(
                                onPressed: Get.back,
                                icon: const Icon(Icons.close,
                                    size: 19, color: Color(0xff94A3B8))),
                          ]),
                          SizedBox(height: 22.h),
                          TextFormField(
                            controller: controller,
                            readOnly: label == 'date',
                            keyboardType: [
                              'discount',
                              'phone',
                              'count',
                              'cost',
                              'totalIncome'
                            ].contains(label)
                                ? TextInputType.number
                                : TextInputType.text,
                            maxLines:
                                label == 'description' || label == 'address'
                                    ? 3
                                    : 1,
                            onTap: label == 'date'
                                ? () async {
                                    final result = await CustomWidgets
                                        .showDateTimePickerWidget(
                                            context: dialogContext);
                                    if (result != null) {
                                      controller.text =
                                          DateFormat('yyyy-MM-dd HH:mm')
                                              .format(result);
                                      setStateDialog(() {});
                                    }
                                  }
                                : null,
                            decoration: InputDecoration(
                                labelText: label.tr,
                                filled: true,
                                fillColor: const Color(0xffF8FAFC),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 13.h),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xffDCE4EF))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xffDCE4EF))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xff4F46E5)))),
                          ),
                          SizedBox(height: 22.h),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: Get.back,
                                    child: Text('Cancel'.tr)),
                                SizedBox(width: 8.w),
                                FilledButton.icon(
                                    onPressed: () async {
                                      final updated = _copyUpdatedOrder(
                                          label, controller.text, currentOrder);
                                      Get.back();
                                      await onSave(updated);
                                    },
                                    icon: const Icon(Icons.check, size: 17),
                                    label: Text('Change Data'.tr),
                                    style: FilledButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xff4F46E5),
                                        minimumSize: const Size(0, 42),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)))),
                              ]),
                        ])),
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(OrderModel currentOrder, Function(OrderModel) onSave) {
    Get.dialog(Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: EdgeInsets.all(22.w),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 20, color: Color(0xff4F46E5)),
                  SizedBox(width: 10.w),
                  Expanded(
                      child: Text('status'.tr,
                          style: TextStyle(
                              fontSize: 17.sp, fontWeight: FontWeight.w700))),
                  IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close,
                          size: 19, color: Color(0xff94A3B8)))
                ]),
                SizedBox(height: 16.h),
                ...StringConstants.statusMapping2.map((item) {
                  final color = item['color'] as Color;
                  return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: InkWell(
                          onTap: () async {
                            Get.back();
                            await onSave(currentOrder.copyWith(
                                status: item['sortName']!));
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 13.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                  color: color.withOpacity(.08),
                                  border:
                                      Border.all(color: color.withOpacity(.25)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(children: [
                                Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: color, shape: BoxShape.circle)),
                                SizedBox(width: 10.w),
                                Expanded(
                                    child: Text('${item['name']}'.tr,
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff172033)))),
                                const Icon(Icons.chevron_right,
                                    size: 18, color: Color(0xff94A3B8))
                              ]))));
                }),
              ]),
        ),
      ),
    ));
  }

  String _getValue(String label, OrderModel order) {
    switch (label) {
      case 'status':
        return StringConstants.statusMapping.firstWhere(
            (s) => s['sortName'] == order.status,
            orElse: () => {'name': 'Unknown'})['name']!;
      case 'date':
        String dateStr = order.date.toString();
        return dateStr.length >= 16
            ? dateStr.substring(0, 16).replaceAll("T", ' ')
            : dateStr.replaceAll("T", ' ');
      case 'clientName':
        return order.clientDetailModel?.name ?? 'N/A';
      case 'phone':
        final phoneNum = order.clientDetailModel?.phone ?? 'N/A';
        return phoneNum.startsWith('+993') && phoneNum.length > 4
            ? phoneNum.substring(4)
            : phoneNum; // Display without +993
      case 'address':
        return order.clientDetailModel?.address ?? 'N/A';
      case 'gaplama':
        return order.gaplama.toString();
      case 'discount':
        return "${order.discount}  ";
      case 'coupon':
        return order.coupon.toString();
      case 'description':
        return order.description.toString();
      case 'count':
        return order.count.toString();

      case 'cost':
        return "${order.totalchykdajy}";
      case 'totalIncome':
        return "${order.totalsum}";
      default:
        return 'Bilinmeyen Alan'.tr;
    }
  }

  OrderModel _copyUpdatedOrder(String label, String value, OrderModel current) {
    ClientDetailModel clientDetails = current.clientDetailModel ??
        ClientDetailModel(id: current.clientID, name: '');
    switch (label) {
      case 'date':
        return current.copyWith(date: value.replaceAll(" ", "T"));
      case 'clientName':
        return current.copyWith(
            clientDetailModel: clientDetails.copyWith(name: value));
      case 'phone':
        final String phoneNumber =
            value.startsWith('+993') || value.isEmpty ? value : '+993$value';
        return current.copyWith(
            clientDetailModel: clientDetails.copyWith(phone: phoneNumber));
      case 'address':
        return current.copyWith(
            clientDetailModel: clientDetails.copyWith(address: value));
      case 'gaplama':
        return current.copyWith(gaplama: value);
      case 'discount':
        return current.copyWith(discount: value);
      case 'coupon':
        return current.copyWith(coupon: value);
      case 'description':
        return current.copyWith(description: value);
      case 'count':
        return current.copyWith(count: int.parse(value));
      case 'cost':
        return current.copyWith(totalchykdajy: value);
      case 'totalIncome':
        return current.copyWith(totalsum: value);
      default:
        return current;
    }
  }
}
