import 'package:get/get.dart';
import 'package:stock_managament_admin/app/data/models/order_model.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

enum SortOptions { preparing, readyToShip, shipped, canceled, refund }

class SalesProductsView extends StatefulWidget {
  final OrderModel order;

  const SalesProductsView({required this.order});
  @override
  State<SalesProductsView> createState() => _SalesProductsViewState();
}

class _SalesProductsViewState extends State<SalesProductsView> {
  Map<String, Color> colorMapping = {"shipped": Colors.green, "canceled": Colors.red, "refund": Colors.red, "preparing": Colors.black, "readyToShip": Colors.purple};

  final SalesController salesController = Get.put(SalesController());

  Map<String, String> statusMapping = {"preparing": 'Preparing', "readyToShip": 'Ready to ship', "shipped": "Shipped", "canceled": "Canceled", "refund": 'Refund'};

  int statusRemover = 0;

  Map<String, SortOptions> statusSortOption = {"preparing": SortOptions.preparing, "readyToShip": SortOptions.readyToShip, "shipped": SortOptions.shipped, "canceled": SortOptions.canceled, "refund": SortOptions.refund};

  SortOptions _selectedSortOption = SortOptions.preparing;
  // Default sort option
  @override
  void initState() {
    super.initState();
    doStatusFunction(widget.order.status!.toLowerCase());
  }

  doStatusFunction(String status) {
    if (status == 'preparing') {
      _selectedSortOption = SortOptions.preparing;
    } else if (status == 'readyToShip' || status == "ready to ship" || status == "Ready to ship") {
      _selectedSortOption = SortOptions.readyToShip;
    } else if (status == 'shipped') {
      _selectedSortOption = SortOptions.shipped;
    } else if (status == 'canceled') {
      _selectedSortOption = SortOptions.canceled;
    } else if (status == 'refund') {
      _selectedSortOption = SortOptions.refund;
    }
    setState(() {});
  }

  final SeacrhViewController seacrhViewController = Get.put(SeacrhViewController());
  Widget radioButton(SortOptions option, String text) {
    return RadioListTile(
      title: Text(text),
      value: option,
      groupValue: _selectedSortOption,
      onChanged: (SortOptions? value) async {
        if (option == SortOptions.canceled || option == SortOptions.refund) {
          FirebaseFirestore.instance.collection('clients').get().then((value) {
            for (var element in value.docs) {
              if (element['number'] == widget.order.clientNumber) {
                double sumClientPrice = double.parse(element['sum_price'].toString()) - double.parse(widget.order.sumPrice.toString());
                element.reference.update({'sum_price': sumClientPrice, 'order_count': element['order_count'] - 1});
              }
            }
          });

          await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).collection('products').get().then((value) async {
            for (var element in value.docs) {
              await FirebaseFirestore.instance.collection('products').where('name', isEqualTo: element['name']).get().then((value2) {
                FirebaseFirestore.instance.collection('products').doc(value2.docs[0].id).update({'quantity': int.parse(value2.docs[0]['quantity'].toString()) + int.parse(element['quantity'].toString())}).then((value3) {
                  return value3;
                });
              });
            }
          });
        }
        _selectedSortOption = value!;
        doStatusFunction(statusMapping[_selectedSortOption.name.toString()].toString());
        await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).update({
          "status": statusMapping[_selectedSortOption.name.toString()].toString(),
        }).then((value) {
          Navigator.of(context).pop();
          CustomWidgets.showSnackBar("Done", "Status changed succefully", Colors.green);
        });
        // salesController.getData();
      },
    );
  }

  GestureDetector statusChangeButton(BuildContext context, String labelName) {
    return GestureDetector(
      onTap: () {
        statusChangeDialog(context);
      },
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "status".tr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
                Text(
                  statusMapping[_selectedSortOption.name.toString()].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorMapping[_selectedSortOption.name], fontSize: 16.sp),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.grey.shade200,
          )
        ],
      ),
    );
  }

  Future<dynamic> statusChangeDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: Text(
            'Status',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 20.sp),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusMapping.entries.map(
              (e) {
                String a = e.value.toLowerCase();
                if (a == "Ready to ship") a = "readyToShip";
                return radioButton(statusSortOption[a == "ready to ship" ? 'readyToShip' : a] ?? SortOptions.readyToShip, e.value);
              },
            ).toList(),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 18.sp),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(fontSize: 18.sp),
              ),
              onPressed: () {
                FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).update({
                  "status": statusMapping[_selectedSortOption.name.toString()].toString(),
                }).then((value) {
                  CustomWidgets.showSnackBar("Done", "Status changed succefully", Colors.green);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final List _topPartNames = [
    {'name': 'Product Name', 'sortName': "quantity"},
    {'name': '   Cost', 'sortName': "cost"},
    {'name': 'Sell Price', 'sortName': "sell_price"},
    {'name': 'Brand', 'sortName': "brand"},
    {'name': 'Category', 'sortName': "category"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID!).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CustomWidgets.spinKit();
            } else if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: statusChangeButton(context, 'Name'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: textsWidgetsListview(context, snapshot),
                  ),
                  // CustomWidgets().topWidgetTextPart(addMorePadding: false, names: _topPartNames, ordersView: false, clientView: false, purchasesView: false),
                  productsListview()
                ],
              );
            }
            return CustomWidgets.emptyData();
          }),
    );
  }

  AppBar customAppBar(BuildContext context) {
    return AppBar(
      title: Text('${"order".tr}   #${widget.order.orderID.toString().substring(0, 5).toString()}'),
      centerTitle: true,
      actions: [
        IconButton(
            onPressed: () async {
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text('This action will permanently delete this ORDER'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        final snapshot = await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).collection('products').get();
                        for (var doc in snapshot.docs) {
                          doc.reference.delete();
                        }

                        await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).delete().then((value) async {
                          salesController.orderCardList.removeWhere((element) => element.id == widget.order.orderID);

                          CustomWidgets.showSnackBar("Deleted", "Succesfully deleted your ORDER", Colors.green);
                        });
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              IconlyLight.delete,
              color: Colors.black,
            )),
      ],
      leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(IconlyLight.arrowLeftCircle, color: Colors.black)),
    );
  }

  Wrap textsWidgetsListview(BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    List namesList = [
      {'text1': 'dateOrder', "text2": 'date'},
      {'text1': 'package', "text2": 'package'},
      {'text1': 'clientNumber', "text2": 'client_number'},
      {'text1': 'userName', "text2": 'client_name'},
      {'text1': 'clientAddress', "text2": 'client_address'},
      {'text1': 'discount', "text2": 'discount'},
      {'text1': 'Coupon', "text2": 'coupon'},
      {'text1': 'note', "text2": 'note'},
      {'text1': 'productCount', "text2": 'product_count'},
      {'text1': 'priceProduct', "text2": 'sum_price'},
      {'text1': 'sumCost', "text2": 'sum_cost'},
    ];
    return Wrap(
        children: List.generate(
            namesList.length,
            (index) => textWidgetOrderedPage(
                text1: namesList[index]['text1'],
                text2: namesList[index]['text1'] == 'priceProduct'
                    ? "${snapshot.data![namesList[index]['text2']]}\$"
                    : namesList[index]['text1'] == 'sumCost'
                        ? "${double.parse(snapshot.data![namesList[index]['text2']].toString()).toStringAsFixed(2)}\$"
                        : snapshot.data![namesList[index]['text2']].toString(),
                firebaseName: namesList[index]['text2'])));
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchData() async {
    final snapshot = await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).collection('products').get();
    return snapshot;
  }

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> productsListview() {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorData();
          } else if (snapshot.data!.docs.isEmpty) {
            return CustomWidgets.emptyData();
          } else if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                final product = ProductModel(
                  name: snapshot.data!.docs[index]['name'],
                  brandName: snapshot.data!.docs[index]['brand'].toString(),
                  category: snapshot.data!.docs[index]['category'].toString(),
                  cost: snapshot.data!.docs[index]['cost'].toString(),
                  gramm: snapshot.data!.docs[index]['gramm'].toString(),
                  image: snapshot.data!.docs[index]['image'].toString(),
                  location: snapshot.data!.docs[index]['location'].toString(),
                  material: snapshot.data!.docs[index]['material'].toString(),
                  quantity: int.parse(snapshot.data!.docs[index]['quantity'].toString()),
                  sellPrice: snapshot.data!.docs[index]['sell_price'].toString(),
                  note: snapshot.data!.docs[index]['note'].toString(),
                  package: snapshot.data!.docs[index]['package'].toString(),
                  documentID: snapshot.data!.docs[index].id,
                );

                return ProductCard(
                  addCounterWidget: false,
                  product: product,
                  purchaseView: false,
                  disableOnTap: true,
                );
              },
            );
          }

          return const Text("No data");
        });
  }

  Widget textWidgetOrderedPage({required String text1, required String text2, required String firebaseName}) {
    FocusNode focusNode = FocusNode();
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = text2;

    return GestureDetector(
      onTap: () {
        Get.defaultDialog(
            title: text1.tr,
            contentPadding: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
            content: CustomTextField(
              labelName: text1.toString(),
              controller: textEditingController,
              focusNode: focusNode,
              requestfocusNode: focusNode,
            ),
            actions: [
              TextButton(
                child: Text('no'.tr, style: TextStyle(fontSize: 18.sp)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('yes'.tr, style: TextStyle(fontSize: 18.sp)),
                onPressed: () async {
                  if (text1 == 'discount') {
                    double sumPrice = double.parse(widget.order.sumPrice.toString());
                    double discount = textEditingController.text.isEmpty ? 0.0 : double.parse(textEditingController.text.toString());
                    if (sumPrice == discount || discount > sumPrice) {
                      CustomWidgets.showSnackBar('errorTitle', 'notHigherThanSumPrice', Colors.red);
                    } else {
                      await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).update({firebaseName: textEditingController.text, 'sum_price': sumPrice - discount}).then((value) {
                        CustomWidgets.showSnackBar("copySucces", "changesUpdated", Colors.green);
                      });
                    }
                  } else {
                    if (firebaseName == 'client_number') {
                      FirebaseFirestore.instance.collection('clients').get().then((value) {
                        bool clientAddValue = false;
                        for (var element in value.docs) {
                          if (element['number'] == textEditingController.text) {
                            clientAddValue = true;
                            double sumClientPrice = double.parse(element['sum_price'].toString()) + double.parse(widget.order.sumPrice.toString());
                            element.reference.update({'sum_price': sumClientPrice, 'order_count': element['order_count'] + 1});
                            FirebaseFirestore.instance.collection('clients').where('number', isEqualTo: text2).get().then((valueaa) {
                              for (var element22 in valueaa.docs) {
                                element22.reference.delete();
                              }
                            });
                          }
                        }
                        if (clientAddValue == false) {
                          for (var element in value.docs) {
                            if (element['number'] == text2) {
                              element.reference.update({'number': textEditingController.text});
                            }
                          }
                        }
                      });
                    }

                    await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).update({firebaseName: textEditingController.text}).then((value) {
                      CustomWidgets.showSnackBar("copySucces", "changesUpdated", Colors.green);
                    });
                    salesController.orderCardList.removeWhere((element) => element.id == widget.order.orderID);
                    await FirebaseFirestore.instance.collection('sales').doc(widget.order.orderID).get().then((value) {
                      salesController.orderCardList.add(value);
                    });
                    salesController.orderCardList.sort((a, b) => b['date'].compareTo(a['date']));
                  }

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 10.h, bottom: 8.h),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text1.tr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
                Text(
                  text1 == "clientNumber"
                      ? "+993 $text2"
                      : text1 == "priceProduct"
                          ? text2
                          : text1 == "discount" || text1 == "Coupon"
                              ? text2
                              : text2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                )
              ],
            ),
            Divider(
              color: Colors.grey.shade200,
            )
          ],
        ),
      ),
    );
  }
}
