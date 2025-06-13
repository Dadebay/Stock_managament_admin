import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';

class OrderProductsView extends StatefulWidget {
  final OrderModel order;
  final bool isAdmin;
  const OrderProductsView({super.key, required this.order, required this.isAdmin});

  @override
  State<OrderProductsView> createState() => _OrderProductsViewState();
}

class _OrderProductsViewState extends State<OrderProductsView> {
  final OrderController orderController = Get.put<OrderController>(OrderController());
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
      {'label': 'totalsum', 'editable': true},
      {'label': 'totalchykdajy', 'editable': true},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final fieldDefinitions = buildOrderDetailsFields(_currentOrder);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backArrow: true,
        centerTitle: true,
        actionIcon: widget.isAdmin ? true : false,
        icon: IconButton(
          onPressed: () async {
            final confirm = await Get.defaultDialog<bool>(
              title: 'Delete Order'.tr,
              middleText: 'Are you sure you want to delete this order?'.tr,
              textConfirm: 'Delete'.tr,
              textCancel: 'Cancel'.tr,
              confirmTextColor: Colors.white,
              onConfirm: () => Get.back(result: true),
              onCancel: () => Get.back(result: false),
            );
            if (confirm == true) {
              await OrderService().deleteOrder(model: _currentOrder);
            }
          },
          icon: Icon(IconlyLight.delete, color: Colors.red),
        ),
        name: _currentOrder.name,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Column(
              children: List.generate(fieldDefinitions.length, (index) {
                final fieldDef = fieldDefinitions[index];
                return OrderDetailField(
                  key: ValueKey(_currentOrder.id.toString() + fieldDef['label']!),
                  label: fieldDef['label']!,
                  isEditable: fieldDef['editable'] as bool,
                  currentOrder: _currentOrder,
                  onUpdate: (updatedOrderFromField) {
                    setState(() {
                      _currentOrder = updatedOrderFromField;
                    });
                    orderController.editOrderInList(updatedOrderFromField);
                  },
                  isAdmin: widget.isAdmin,
                );
              }),
            ),
          ),
          if (_currentOrder.products.isNotEmpty)
            ListviewTopText<SearchModel>(
              names: StringConstants.searchViewtopPartNames,
              listToSort: _currentOrder.products,
              setSortedList: (newList) {},
              getSortValue: (model, key) => orderController.getProductSortValue(model, key),
            ),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_currentOrder.id == 0) {
      return SizedBox(height: 300, child: Center(child: Text("Order ID is missing".tr)));
    }
    return FutureBuilder<List<ProductModel>>(
      future: OrderService().getOrderProduct(_currentOrder.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return CustomWidgets.spinKit();
        if (snapshot.hasError) return SizedBox(height: 300, child: Center(child: Text('Error: ${snapshot.error}'.tr)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (_currentOrder.products.isNotEmpty) {
            final products = _currentOrder.products;
            return ListView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              itemBuilder: (context, index) => SearchCard(
                product: products[index],
                disableOnTap: true,
                addCounterWidget: false,
                isAdmin: widget.isAdmin,
                whcihPage: '',
              ),
            );
          }
          return SizedBox(height: 300, child: CustomWidgets.emptyData());
        }

        final products = snapshot.data!;
        return ListView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            itemBuilder: (context, index) {
              final productModel = products[index];
              return SearchCard(
                product: productModel.product!,
                externalCount: productModel.count,
                disableOnTap: true,
                addCounterWidget: false,
                isAdmin: widget.isAdmin,
                whcihPage: '',
              );
            });
      },
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

  String _getValue(String label, OrderModel order) {
    switch (label) {
      case 'status':
        return StringConstants.statusMapping.firstWhere((s) => s['sortName'] == order.status, orElse: () => {'name': 'Unknown'})['name']!;
      case 'date':
        return order.date.toString().substring(0, 16).replaceAll("T", ' ');
      case 'clientName':
        return order.clientDetailModel?.name ?? 'N/A';
      case 'phone':
        final phoneNum = order.clientDetailModel?.phone ?? 'N/A';
        return phoneNum.startsWith('+993') ? phoneNum.substring(4) : phoneNum; // Display without +993
      case 'address':
        return order.clientDetailModel?.address ?? 'N/A';
      case 'gaplama':
        return order.gaplama.toString();
      case 'discount':
        return "${order.discount} % ";
      case 'coupon':
        return order.coupon.toString();
      case 'description':
        return order.description.toString();
      case 'count':
        return order.count.toString();
      case 'totalsum':
        return "${order.totalchykdajy} \$";
      case 'totalchykdajy':
        return "${order.totalsum} \$";
      default:
        return 'Bilinmeyen Alan'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    _displayedValue = _getValue(widget.label, widget.currentOrder);
    return GestureDetector(
      onTap: !widget.isEditable
          ? null
          : () {
              print(widget.isAdmin);
              if (widget.isAdmin)
                showEditDialog(
                  context: context,
                  label: widget.label,
                  initialValue: _displayedValue, // Dialog için başlangıç değeri
                  currentOrder: widget.currentOrder,
                  onSave: (locallyUpdatedOrder) async {
                    await OrderService().editOrderManually(model: locallyUpdatedOrder);
                    widget.onUpdate(locallyUpdatedOrder);
                  },
                );
            },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label == "date" ? widget.label.tr : "${widget.label.tr} :",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10.w),
                  widget.label == 'status'
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: StringConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['color']?.withOpacity(0.15),
                              border: Border.all(color: StringConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['color']!, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            "${StringConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['name']}".tr,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: StringConstants.statusMapping.firstWhere((s) => s['name'] == _displayedValue)['color'], fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Expanded(
                          child: Text(
                            _displayedValue, // Her zaman güncel olan _displayedValue'yu kullan
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Divider(color: Colors.grey.shade200, height: 1),
            )
          ],
        ),
      ),
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
      Get.defaultDialog(
        title: label.tr,
        titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: Get.size.width / 3,
          padding: context.padding.normal,
          child: SingleChildScrollView(
            child: Column(
              children: StringConstants.statusMapping2.map((statusItem) {
                return GestureDetector(
                  onTap: () async {
                    final updatedOrder = currentOrder.copyWith(status: statusItem['sortName']!);
                    Get.back();
                    await onSave(updatedOrder);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: (statusItem['color'] as Color).withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: (statusItem['color'] as Color).withOpacity(0.2),
                    ),
                    child: Text(
                      "${statusItem['name']!}".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: statusItem['color'] as Color, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
      return;
    }

    if (label == 'discount') {
      controller.text = currentOrder.discount.replaceAll(" % ", "").trim();
    } else if (label == 'phone') {
      final phoneNum = currentOrder.clientDetailModel?.phone ?? '';
      controller.text = phoneNum.startsWith('+993') ? phoneNum.substring(4) : phoneNum;
    } else {
      controller.text = initialValue == 'N/A' ? '' : initialValue;
    }

    Get.defaultDialog(
      title: label.tr,
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return Container(
            width: Get.size.width / 3,
            padding: context.padding.normal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelName: label.tr,
                  controller: controller,

                  isNumberOnly: ['discount'].contains(label) || (label == 'phone'), // Telefon için de sayısal olabilir
                  readOnly: label == 'date',
                  onTap: label == 'date'
                      ? () async {
                          final resultTime = await CustomWidgets.showDateTimePickerWidget(context: context);
                          if (resultTime != null) {
                            controller.text = DateFormat('yyyy-MM-dd HH:mm').format(resultTime);
                            setStateDialog(() {});
                          }
                        }
                      : null,
                  focusNode: FocusNode(),
                  requestfocusNode: FocusNode(),
                ),
                SizedBox(height: 10.h),
                AgreeButton(
                  text: 'Change Data'.tr,
                  onTap: () async {
                    final newValueFromInput = controller.text;
                    OrderModel updatedOrderWithNewValue = _copyUpdatedOrder(label, newValueFromInput, currentOrder);
                    Get.back();
                    await onSave(updatedOrderWithNewValue); // onSave çağrısı
                  },
                ),
                SizedBox(height: 5.h),
                AgreeButton(onTap: () => Get.back(), text: 'Cancel'.tr, showBorder: true),
              ],
            ),
          );
        },
      ),
    );
  }

  OrderModel _copyUpdatedOrder(String label, String value, OrderModel current) {
    ClientDetailModel clientDetails = current.clientDetailModel ?? ClientDetailModel(id: current.clientID, name: '');
    switch (label) {
      case 'date':
        return current.copyWith(date: value.replaceAll(" ", "T"));
      case 'clientName':
        return current.copyWith(clientDetailModel: clientDetails.copyWith(name: value));
      case 'phone':
        final String phoneNumber = value.startsWith('+993') || value.isEmpty ? value : '+993$value';
        return current.copyWith(clientDetailModel: clientDetails.copyWith(phone: phoneNumber));
      case 'address':
        return current.copyWith(clientDetailModel: clientDetails.copyWith(address: value));
      case 'gaplama':
        return current.copyWith(gaplama: value);
      case 'discount':
        return current.copyWith(discount: value); // Modeldeki discount string ise
      case 'coupon':
        return current.copyWith(coupon: value);
      case 'description':
        return current.copyWith(description: value);
      case 'discount':
        return current.copyWith(discount: value);
      case 'count':
        return current.copyWith(count: int.parse(value));
      case 'totalsum':
        return current.copyWith(totalsum: value);
      case 'totalchykdajy':
        return current.copyWith(totalchykdajy: value);
      default:
        return current;
    }
  }
}
