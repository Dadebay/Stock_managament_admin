import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';

class OrderProductsView extends StatefulWidget {
  final OrderModel order;

  const OrderProductsView({super.key, required this.order});
  @override
  State<OrderProductsView> createState() => _OrderProductsViewState();
}

class _OrderProductsViewState extends State<OrderProductsView> {
  final OrderController orderController = Get.find<OrderController>();
  late OrderModel _currentOrder;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _selectedStatus = StringConstants.statusMapping.firstWhere((map) => map['sortName'].toString() == _currentOrder.status, orElse: () => StringConstants.statusMapping.first)['name']!;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final updatedOrderFromController = orderController.allOrders.firstWhereOrNull((o) => o.id == widget.order.id);
      if (updatedOrderFromController != null) {
        _currentOrder = updatedOrderFromController;
        _selectedStatus = StringConstants.statusMapping.firstWhere((map) => map['sortName'].toString() == _currentOrder.status, orElse: () => StringConstants.statusMapping.first)['name']!;
      }

      return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            backArrow: true,
            centerTitle: true,
            actionIcon: true,
            icon: IconButton(
                onPressed: () async {
                  await OrderService().deleteOrder(model: _currentOrder);
                  Get.back();
                },
                icon: Icon(IconlyLight.delete, color: Colors.red)),
            name: _currentOrder.name,
          ),
          body: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: 30.h),
              textsWidgetsListview(context),
              SizedBox(height: 30.h),
              _topText(widget.order.products),
              _productView(),
            ],
          ));
    });
  }

  Widget _productView() {
    return FutureBuilder<List<SearchModel>>(
        future: OrderService().getOrderProduct(widget.order.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return SizedBox(height: 300, child: CustomWidgets.emptyData()); // Container yerine SizedBox
          }
          final productsToShow = snapshot.data!;
          return ListView.builder(
            itemCount: productsToShow.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            itemBuilder: (BuildContext context, int index) {
              return SearchCard(
                product: productsToShow[index],
                disableOnTap: true,
                addCounterWidget: false,
                whcihPage: '',
              );
            },
          );
        });
  }

  ListviewTopText<SearchModel> _topText(List<SearchModel> displayList) {
    return ListviewTopText<SearchModel>(
      names: StringConstants.searchViewtopPartNames,
      listToSort: displayList,
      setSortedList: (newList) {},
      getSortValue: (model, key) {
        switch (key) {
          case 'count':
            return model.count ?? 0;
          case 'price':
            return model.price ?? 0;
          case 'cost':
            return model.cost ?? 0;
          case 'brends':
            return model.brend?.name ?? '';
          case 'category':
            return model.category?.name ?? '';
          case 'location':
            return model.location?.name ?? '';
          default:
            return '';
        }
      },
    );
  }

  Wrap textsWidgetsListview(BuildContext context) {
    List<Map<String, String>> namesList = [
      {
        'text1': 'status',
        "text2": StringConstants.statusMapping.firstWhere((s) => s['sortName'].toString() == _currentOrder.status, orElse: () => {'name': 'Unknown'})['name']!
      },
      {'text1': 'date', "text2": _currentOrder.date.toString().substring(0, 16).replaceAll("T", ' ')},
      {'text1': 'clientName', "text2": _currentOrder.clientDetailModel?.name.toString() ?? 'N/A'},
      {'text1': 'phone', "text2": _currentOrder.clientDetailModel?.phone.toString() ?? 'N/A'},
      {'text1': 'address', "text2": _currentOrder.clientDetailModel?.address.toString() ?? 'N/A'},
      {'text1': 'gaplama', "text2": _currentOrder.gaplama.toString()},
      {'text1': 'discount', "text2": "${_currentOrder.discount.toString()} % "},
      {'text1': 'coupon', "text2": _currentOrder.coupon.toString()},
      {'text1': 'description', "text2": _currentOrder.description.toString()},
      {'text1': 'count', "text2": _currentOrder.count.toString()}, // Bu genellikle düzenlenemez
      {'text1': 'totalsum', "text2": "${_currentOrder.totalsum.toString()} \$"}, // Bu genellikle düzenlenemez
      {'text1': 'totalchykdajy', "text2": "${_currentOrder.totalchykdajy.toString()} \$"}, // Bu genellikle düzenlenemez
    ];
    return Wrap(
        children: List.generate(namesList.length, (index) {
      bool isEditable = ![
        'count',
        'totalsum',
        'totalchykdajy',
      ].contains(namesList[index]['text1']);
      return textWidgetOrderedPage(labelName: namesList[index]['text1']!, value: namesList[index]['text2']!, isEditable: isEditable);
    }));
  }

  Widget textWidgetOrderedPage({required String labelName, required String value, bool isEditable = true}) {
    FocusNode focusNode = FocusNode();
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = value;
    if (labelName == 'discount') {
      textEditingController.text = value.replaceAll(" % ", "").trim();
    }

    return GestureDetector(
      onTap: !isEditable
          ? null
          : () {
              String? tempSelectedStatusValue = _currentOrder.status;
  
              Get.defaultDialog(
                title: "${labelName.tr}",
                content: Container(
                  width: Get.size.width / 3,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setStateDialog) {
                      Widget contentWidget;
                      if (labelName == 'date') {
                        contentWidget = CustomTextField(
                          readOnly: true,
                          onTap: () async {
                            final result = await CustomWidgets.showDateTimePickerWidget(context: context);
                            if (result != null) {
                              setStateDialog(() {
                                textEditingController.text = DateFormat('yyyy-MM-dd , HH:mm').format(result);
                              });
                            }
                          },
                          labelName: labelName.tr,
                          controller: textEditingController,
                          focusNode: focusNode,
                          requestfocusNode: focusNode,
                        );
                      } else if (labelName == 'status') {
                        contentWidget = Column(
                          children: List.generate(
                              StringConstants.statusMapping.length,
                              (index) => Container(
                                    padding: context.padding.low,
                                    margin: context.padding.low,
                                    width: Get.size.width / 4,
                                    decoration: BoxDecoration(border: Border.all(color: StringConstants.statusMapping[index]['color']!, width: 2), borderRadius: BorderRadius.circular(10), color: StringConstants.statusMapping[index]['color']!.withOpacity(0.5)),
                                    child: Text(StringConstants.statusMapping[index]['name'], style: TextStyle(color: StringConstants.statusMapping[index]['color'], fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                  )),
                        );
                      } else {
                        contentWidget = CustomTextField(
                          labelName: labelName.tr,
                          controller: textEditingController,
                          focusNode: focusNode,
                          isNumberOnly: labelName == 'discount',
                          requestfocusNode: focusNode,
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          contentWidget,
                          SizedBox(height: 20.h),
                          AgreeButton(
                              onTap: () async {
                                OrderModel updatedOrderData = _currentOrder;
                                switch (labelName) {
                                  case 'date':
                                    updatedOrderData = _currentOrder.copyWith(date: textEditingController.text);
                                    break;
                                  case 'status':
                                    updatedOrderData = _currentOrder.copyWith(status: tempSelectedStatusValue);
                                    break;
                                  case 'clientName':
                                    final newClientDetail = _currentOrder.clientDetailModel?.copyWith(name: textEditingController.text);
                                    updatedOrderData = _currentOrder.copyWith(
                                      clientDetailModel: newClientDetail,
                                      name: "${textEditingController.text} - ${_currentOrder.clientDetailModel?.phone ?? ''}",
                                    );
                                    break;
                                  case 'phone':
                                    final newClientDetail = _currentOrder.clientDetailModel?.copyWith(phone: textEditingController.text);
                                    updatedOrderData = _currentOrder.copyWith(
                                      clientDetailModel: newClientDetail,
                                      name: "${_currentOrder.clientDetailModel?.name ?? ''} - ${textEditingController.text}",
                                    );
                                    break;
                                  case 'address':
                                    final newClientDetail = _currentOrder.clientDetailModel?.copyWith(address: textEditingController.text);
                                    updatedOrderData = _currentOrder.copyWith(clientDetailModel: newClientDetail);
                                    break;
                                  case 'gaplama':
                                    updatedOrderData = _currentOrder.copyWith(gaplama: textEditingController.text);
                                    break;
                                  case 'discount':
                                    updatedOrderData = _currentOrder.copyWith(discount: textEditingController.text.isEmpty ? "0" : textEditingController.text);
                                    break;
                                  case 'coupon':
                                    updatedOrderData = _currentOrder.copyWith(coupon: textEditingController.text);
                                    break;
                                  case 'description':
                                    updatedOrderData = _currentOrder.copyWith(description: textEditingController.text);
                                    break;
                                  default:
                                    break;
                                }

                                Get.back(); // Dialog'u kapat
                                await OrderService().editOrder(model: updatedOrderData);
                              },
                              text: "Change Data".tr),
                          SizedBox(height: 10.h),
                          AgreeButton(
                              onTap: () {
                                Get.back();
                              },
                              showBorder: true,
                              text: "Cancel".tr)
                        ],
                      );
                    },
                  ),
                ),
              );
            },
      child: Container(
        color: Colors.white, // Tıklanabilirliği artırmak için
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h), // Biraz dikey padding ekledim
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    labelName == "date" ? labelName.tr : "${labelName.tr} :",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10.w), // Arada boşluk
                  Expanded(
                    // Değerin taşmasını engellemek için Expanded
                    child: Text(
                      value,
                      textAlign: TextAlign.end, // Sağa yasla
                      // overflow: TextOverflow.ellipsis, // Taşarsa ...
                      style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h), // Divider padding'ini azalttım
              child: Divider(color: Colors.grey.shade200, height: 1), // Yüksekliği 1 yaptım
            )
          ],
        ),
      ),
    );
  }
}
