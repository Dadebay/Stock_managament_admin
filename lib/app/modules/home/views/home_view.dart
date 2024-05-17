import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'HomeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}


// class _ExpencesViewState extends State<ExpencesView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           addExpences(context);
//         },
//         child: const Icon(IconlyLight.plus),
//       ),
//       body: NestedScrollView(
//           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//             return <Widget>[
//               SliverAppBar(
//                 title: const Text('Weight Tracker'),
//                 pinned: false,
//                 floating: true,
//                 forceElevated: innerBoxIsScrolled,
//                 bottom: PreferredSize(
//                   preferredSize: const Size.fromHeight(300),
//                   child: Container(
//                     color: Colors.red,
//                   ),
//                 ),
//               ),
//             ];
//           },
//           body: mineBody()
//           ),
//     );
//   }
