import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/listview_top_text.dart';

class PurchasesProductsView extends StatefulWidget {
  final PurchasesModel purchasesModel;
  const PurchasesProductsView({required this.purchasesModel});
  @override
  State<PurchasesProductsView> createState() => _PurchasesProductsViewState();
}

class _PurchasesProductsViewState extends State<PurchasesProductsView> {
  final PurchasesController purchasesController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(backArrow: true, centerTitle: true, actionIcon: false, name: widget.purchasesModel.title),
        body: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: textsWidgetsListview(context),
            ),
            _topText(),
            listViewStyle(),
          ],
        ));
  }

  Widget listViewStyle() {
    return FutureBuilder<List<SearchModel>>(
        future: PurchasesService().getPurchasesByID(widget.purchasesModel.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.spinKit();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorData();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return CustomWidgets.emptyData();
          }
          {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      CustomWidgets.counter(index + 1),
                      Expanded(
                        child: SearchCard(
                          disableOnTap: true,
                          product: snapshot.data![index],
                          addCounterWidget: false,
                          whcihPage: '',
                        ),
                      )
                    ],
                  );
                });
          }
        });
  }

  ListviewTopText<SearchModel> _topText() {
    return ListviewTopText<SearchModel>(
      names: StringConstants.searchViewtopPartNames,
      listToSort: widget.purchasesModel.products,
      setSortedList: (newList) {},
      getSortValue: (model, key) {
        switch (key) {
          case 'name':
            return model.name;
          case 'price':
            return model.price;
          case 'cost':
            return model.cost;
          case 'count':
            return model.count;
          case 'brend':
            return model.brend;
          case 'category':
            return model.category;
          case 'gramm':
            return model.gramm;
          default:
            return '';
        }
      },
    );
  }

  Wrap textsWidgetsListview(BuildContext context) {
    List namesList = [
      {'text1': 'Title', "text2": widget.purchasesModel.title},
      {'text1': 'Date', "text2": widget.purchasesModel.date},
      {'text1': 'Source', "text2": widget.purchasesModel.source},
      {'text1': 'Cost', "text2": widget.purchasesModel.cost},
      {'text1': 'Products Count', "text2": widget.purchasesModel.count.toString()},
      {'text1': 'Description', "text2": widget.purchasesModel.description},
    ];
    return Wrap(children: List.generate(namesList.length, (index) => textWidgetOrderedPage(labelName: namesList[index]['text1'], value: namesList[index]['text2'])));
  }

  Widget textWidgetOrderedPage({required String labelName, required String value}) {
    FocusNode focusNode = FocusNode();
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = value;

    return GestureDetector(
      onTap: () {
        Get.defaultDialog(
          title: labelName,
          titleStyle: TextStyle(color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.bold),
          titlePadding: EdgeInsets.only(top: 20),
          content: Container(
            width: Get.size.width / 3,
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  onTap: () {
                    if (labelName == 'Date') {
                      DateTime? selectedDateTime;
                      showDateTimePicker(BuildContext context) async {
                        final result = await CustomWidgets.showDateTimePickerWidget(context: context);
                        if (result != null) {
                          setState(() {
                            selectedDateTime = result;
                            textEditingController.text = DateFormat('yyyy-MM-dd , HH:mm').format(selectedDateTime!);
                          });
                        }
                      }

                      showDateTimePicker(context);
                    }
                  },
                  labelName: labelName.toString(),
                  controller: textEditingController,
                  focusNode: focusNode,
                  requestfocusNode: focusNode,
                ),
                AgreeButton(onTap: () {}, text: "Change Data"),
                AgreeButton(
                    onTap: () {
                      Get.back();
                    },
                    showBorder: true,
                    text: "Cancel")
              ],
            ),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  labelName.tr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  labelName == 'Cost' ? "${value} \$" : value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Divider(color: Colors.grey.shade200),
            )
          ],
        ),
      ),
    );
  }
}
