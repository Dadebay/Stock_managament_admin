// // ignore_for_file: unused_local_variable

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_pagination/firebase_pagination.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_iconly/flutter_iconly.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:stock_managament_admin/app/modules/products_page/views/web_add_product_page.dart';
// import 'package:stock_managament_admin/app/product/widgets/widgets.dart';

// import '../controllers/products_page_controller.dart';

// // ignore: must_be_immutable
// class ProductsPageView extends GetView<ProductsPageController> {
//   List filters = [
//     {'name': 'Brands', 'searchName': 'brand'},
//     {'name': 'Categories', 'searchName': 'category'},
//     {'name': 'Locations', 'searchName': 'location'},
//     {'name': 'Materials', 'searchName': 'material'}
//   ];

//   final ProductsPageController _productsPageController = Get.put(ProductsPageController());

//   ProductsPageView({super.key});

//   Future<dynamic> filter() {
//     return Get.bottomSheet(Container(
//       padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
//       decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//       child: Wrap(
//         children: [
//           CustomWidgets.filterTextWidget('filter'.tr),
//           ListView.builder(
//             itemCount: filters.length,
//             shrinkWrap: true,
//             physics: const BouncingScrollPhysics(),
//             itemBuilder: (BuildContext context, int index) {
//               return ListTile(
//                 onTap: () {
//                   Get.bottomSheet(Container(
//                     padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
//                     decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
//                     child: Wrap(
//                       children: [
//                         CustomWidgets.filterTextWidget(filters[index]['name']),
//                         StreamBuilder(
//                             stream: FirebaseFirestore.instance.collection(filters[index]['name'].toLowerCase()).snapshots(),
//                             builder: (context, snapshot) {
//                               if (snapshot.hasData) {
//                                 return ListView.builder(
//                                   itemCount: snapshot.data!.docs.length,
//                                   shrinkWrap: true,
//                                   physics: const BouncingScrollPhysics(),
//                                   itemBuilder: (BuildContext context, int indexx) {
//                                     return ListTile(
//                                       onTap: () {
//                                         _productsPageController.filterProducts(filters[index]['searchName'], snapshot.data!.docs[indexx]['name']);
//                                       },
//                                       title: Text(snapshot.data!.docs[indexx]['name']),
//                                     );
//                                   },
//                                 );
//                               }
//                               return CustomWidgets.spinKit();
//                             }),
//                       ],
//                     ),
//                   ));
//                 },
//                 title: Text(filters[index]['name'].toString()),
//                 trailing: const Icon(IconlyLight.arrowRightCircle),
//               );
//             },
//           ),
//         ],
//       ),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () {
//               Get.to(() => const WebAddProductPage());
//             },
//             child: const Icon(IconlyLight.plus),
//           ),
//           const SizedBox(width: 20),
//           FloatingActionButton(
//             backgroundColor: Colors.black,
//             onPressed: () {
//               _productsPageController.showInGrid.value = !_productsPageController.showInGrid.value;
//             },
//             child: Obx(() {
//               return Icon(
//                 _productsPageController.showInGrid.value ? IconlyLight.paper : IconlyLight.category,
//                 color: Colors.amber,
//               );
//             }),
//           )
//         ],
//       ),
//       body: Obx(() {
//         return Column(
//           children: [
//             // _productsPageController.showInGrid.value ? CustomWidgets().topWidgetTextPart(addMorePadding: false, names: [], ordersView: false, clientView: false, purchasesView: false) : const SizedBox.shrink(),
//             _productsPageController.showInGrid.value
//                 ? const Divider(
//                     color: Colors.grey,
//                     thickness: 1,
//                   )
//                 : const SizedBox.shrink(),
//             Expanded(
//                 child: FirestorePagination(
//               limit: _productsPageController.showInGrid.value ? 20 : 40, // Defaults to 10.
//               isLive: true, // Defaults to false.
//               viewType: _productsPageController.showInGrid.value ? ViewType.list : ViewType.grid,
//               reverse: false,
//               padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Get.size.width > 800 ? 6 : 4, mainAxisSpacing: 20),
//               query: FirebaseFirestore.instance.collection('products').orderBy("date", descending: true),
//               itemBuilder: (context, documentSnapshot, index) {
//                 final data = documentSnapshot.data() as Map<String, dynamic>?;
//                 return Container();
//                 // final product = ProductModel(
//                 //     name: data['name'].toString(),
//                 //     brandName: data['brand'].toString(),
//                 //     category: data['category'].toString(),
//                 //     cost: data['cost'].toString(),
//                 //     gramm: data['gramm'].toString(),
//                 //     image: data['image'].toString(),
//                 //     date: data['date'].toString(),
//                 //     location: data['location'].toString(),
//                 //     material: data['material'].toString(),
//                 //     quantity: data['quantity'],
//                 //     sellPrice: data['sell_price'].toString(),
//                 //     note: data['note'].toString(),
//                 //     package: data['package'].toString(),
//                 //     documentID: documentSnapshot.id);
//                 // return _productsPageController.showInGrid.value
//                 //     ? ProductCard(
//                 //         purchaseView: false,
//                 //         product: product,
//                 //         addCounterWidget: false,
//                 //         disableOnTap: false,
//                 //       )
//                 //     : SecondProductCard(product: product);
//               },
//               separatorBuilder: (context, index) {
//                 return const Divider(
//                   height: 5,
//                   thickness: 1,
//                 );
//               },
//             )),
//           ],
//         );
//       }),
//     );
//   }
// }
