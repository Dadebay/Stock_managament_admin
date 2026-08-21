import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class PurchasesProductsView extends StatefulWidget {
  final PurchasesModel purchasesModel;
  final bool isAdmin;
  const PurchasesProductsView(
      {required this.purchasesModel, required this.isAdmin});
  @override
  State<PurchasesProductsView> createState() => _PurchasesProductsViewState();
}

class _PurchasesProductsViewState extends State<PurchasesProductsView> {
  final PurchasesController purchasesController = Get.find();

  late PurchasesModel _localModel;
  late final Future<List<ProductModelPurchases>> _productsFuture;
  String _sortKey = 'name';
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _localModel = widget.purchasesModel;
    _productsFuture = PurchasesService().getPurchasesByID(_localModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backArrow: true,
        centerTitle: true,
        actionIcon: false,
        name: _localModel.title,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        children: [
          textsWidgetsListview(context),
          const SizedBox(height: 22),
          _topText(),
          listViewStyle(),
        ],
      ),
    );
  }

  Widget listViewStyle() {
    return FutureBuilder<List<ProductModelPurchases>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomWidgets.spinKit();
        } else if (snapshot.hasError) {
          return CustomWidgets.errorData();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return CustomWidgets.emptyData();
        }
        final items = List<ProductModelPurchases>.from(snapshot.data!)
          ..sort((a, b) => _compareProducts(a.product!, b.product!));
        return ListView.separated(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8),
          separatorBuilder: (_, __) => const SizedBox(height: 5),
          itemBuilder: (BuildContext context, int index) {
            return _productRow(items[index], items.length - index);
          },
        );
      },
    );
  }

  Widget _productRow(ProductModelPurchases item, int index) {
    final product = item.product!;
    final rawImage = product.img ?? '';
    final imageUrl = rawImage.startsWith(ApiConstants.imageURL)
        ? rawImage
        : '${ApiConstants.imageURL2}$rawImage';
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Text('$index',
              style: const TextStyle(
                  color: Color(0xFF475569), fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: rawImage.isEmpty ? null : () => _showImagePreview(imageUrl),
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: 52,
            height: 52,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(5)),
            child: rawImage.isEmpty
                ? const Icon(Icons.inventory_2_outlined,
                    color: Color(0xFF94A3B8), size: 20)
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 160,
                    memCacheHeight: 160,
                    placeholder: (_, __) => const Center(
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF94A3B8),
                        size: 20),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('Sany: ${item.count}',
                      style: const TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
        ),
        _productCell('Alış', '${product.cost} ${String.fromCharCode(36)}'),
        _productCell('Satış', '${product.price} ${String.fromCharCode(36)}'),
        _productCell('Brend', product.brend?.name ?? '—'),
        _productCell('Kategoriýa', product.category?.name ?? '—'),
        _productCell('Ýerleşýän ýeri', product.location?.name ?? '—'),
      ]),
    );
  }

  Widget _productCell(String label, String value) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 11)),
                const SizedBox(height: 4),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ]),
        ),
      );

  void _showImagePreview(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(32),
        child: Stack(children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator())),
                errorWidget: (_, __, ___) => const SizedBox(
                    height: 240,
                    child: Center(child: Icon(Icons.broken_image_outlined))),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: .55),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _topText() => Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Row(children: [
          const SizedBox(width: 34),
          const SizedBox(width: 10),
          const SizedBox(width: 54),
          const SizedBox(width: 10),
          _head('Haryt ady', 'name', 3),
          _head('Satyn alnan bahasy', 'cost', 1),
          _head('Satylýan bahasy', 'price', 1),
          _head('Brend', 'brand', 1),
          _head('Kategoriýa', 'category', 1),
          _head('Haryt salgysy', 'location', 1)
        ]),
      );

  Widget _head(String label, String key, int flex) {
    final active = _sortKey == key;
    return Expanded(
        flex: flex,
        child: InkWell(
            onTap: () => setState(() {
                  if (active)
                    _ascending = !_ascending;
                  else {
                    _sortKey = key;
                    _ascending = true;
                  }
                }),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: active
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 3),
              Icon(
                  active
                      ? (_ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded)
                      : Icons.unfold_more_rounded,
                  size: 14,
                  color: active
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF94A3B8))
            ])));
  }

  int _compareProducts(SearchModel a, SearchModel b) {
    String value(SearchModel product) {
      switch (_sortKey) {
        case 'cost':
          return product.cost;
        case 'price':
          return product.price;
        case 'brand':
          return product.brend?.name ?? '';
        case 'category':
          return product.category?.name ?? '';
        case 'location':
          return product.location?.name ?? '';
        default:
          return product.name;
      }
    }

    final left = value(a);
    final right = value(b);
    final leftNum = double.tryParse(left);
    final rightNum = double.tryParse(right);
    final result = leftNum != null && rightNum != null
        ? leftNum.compareTo(rightNum)
        : left.toLowerCase().compareTo(right.toLowerCase());
    return _ascending ? result : -result;
  }

  Wrap textsWidgetsListview(BuildContext context) {
    List namesList = [
      {'text1': 'Title', "text2": _localModel.title},
      {'text1': 'Date', "text2": _localModel.date},
      {'text1': 'Source', "text2": _localModel.source},
      {'text1': 'Cost', "text2": _localModel.cost},
      {
        'text1': 'Products Count',
        "text2": _localModel.count.toString() == '0'
            ? widget.purchasesModel.products.length.toString()
            : _localModel.count.toString()
      },
      {'text1': 'Description', "text2": _localModel.description},
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        namesList.length,
        (index) => textWidgetOrderedPage(
          labelName: namesList[index]['text1'],
          value: namesList[index]['text2'],
        ),
      ),
    );
  }

  Widget textWidgetOrderedPage(
      {required String labelName, required String value}) {
    FocusNode focusNode = FocusNode();
    final TextEditingController textEditingController = TextEditingController();
    textEditingController.text = value;

    return GestureDetector(
      onTap: () {
        if (widget.isAdmin) {
          Get.defaultDialog(
            title: labelName,
            titleStyle: TextStyle(
                color: Colors.black,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold),
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
                          final result =
                              await CustomWidgets.showDateTimePickerWidget(
                                  context: context);
                          if (result != null) {
                            setState(() {
                              selectedDateTime = result;
                              textEditingController.text =
                                  DateFormat('yyyy-MM-dd , HH:mm')
                                      .format(selectedDateTime!);
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
                  AgreeButton(
                    onTap: () async {
                      // Safe substring for date
                      String dateValue = _localModel.date;
                      if (labelName == 'Date') {
                        dateValue = textEditingController.text.length >= 10
                            ? textEditingController.text.substring(0, 10)
                            : textEditingController.text;
                      }

                      final updatedModel = PurchasesModel(
                        id: _localModel.id,
                        title: labelName == 'Title'
                            ? textEditingController.text
                            : _localModel.title,
                        date: dateValue,
                        source: labelName == 'Source'
                            ? textEditingController.text
                            : _localModel.source,
                        cost: labelName == 'Cost'
                            ? textEditingController.text
                            : _localModel.cost,
                        description: labelName == 'Description'
                            ? textEditingController.text
                            : _localModel.description,
                        count: _localModel.count,
                        products: _localModel.products,
                      );

                      final result = await PurchasesService()
                          .editOrderManually(model: updatedModel);
                      if (result != null) {
                        setState(() {
                          _localModel = result;
                        });
                      }
                    },
                    text: "Change Data",
                  ),
                  AgreeButton(
                    onTap: () {
                      Get.back();
                    },
                    showBorder: true,
                    text: "Cancel",
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Container(
        width: (Get.width - 96) / 3,
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(labelName.tr,
                  style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(labelName == 'Cost' ? "$value \$" : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700)),
            ]),
      ),
    );
  }
}
