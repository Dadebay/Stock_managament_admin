import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/views/clients_view.dart';
import 'package:stock_managament_admin/app/modules/expences/views/expences_view.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_page_view.dart';
import 'package:stock_managament_admin/app/modules/home/views/home_view.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchases_view.dart';
import 'package:stock_managament_admin/app/modules/sales/views/sales_view.dart';
import 'package:stock_managament_admin/app/modules/search/controllers/search_controller.dart';
import 'package:stock_managament_admin/app/modules/search/views/search_view.dart';
import 'package:stock_managament_admin/app/modules/settings/views/settings_view.dart';
import 'package:stock_managament_admin/constants/buttons/drawer_button.dart';
import 'package:stock_managament_admin/constants/customWidget/constants.dart';

class NavBarPageView extends StatefulWidget {
  const NavBarPageView({super.key});

  @override
  State<NavBarPageView> createState() => _NavBarPageViewState();
}

class _NavBarPageViewState extends State<NavBarPageView> {
  List pages = [const HomeView(), const SalesView(), const PurchasesView(), const SearchView(), const FourInOnePageView(), const ExpencesView(), const ClientsView(), const SettingsView()];
  List icons = [IconlyLight.chart, IconlyLight.paper, CupertinoIcons.cart_badge_plus, IconlyLight.search, IconlyLight.category, IconlyLight.wallet, IconlyLight.user3, IconlyLight.setting];
  List titles = ['home', 'Sales', 'Purchases', 'Search', 'Four in One page', 'Expences', 'Clients', 'Settings'];
  int selecedIndex = 0;
  final SeacrhViewController seacrhViewController = Get.put(SeacrhViewController());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          drawer(width),
          Expanded(
            flex: 6,
            child:
                // Container(color: Colors.white, child: const PurchasesView()),
                Container(
              color: Colors.white,
              child: pages[selecedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Expanded drawer(double width) {
    return Expanded(
        flex: 1,
        child: Column(
          children: [
            header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                color: Colors.amber.withOpacity(0.2),
                thickness: 2,
              ),
            ),
            Expanded(
                flex: 13,
                child: Column(
                    children: List.generate(
                        pages.length,
                        (index) => DrawerButtonMine(
                              onTap: () {
                                setState(() {
                                  selecedIndex = index;
                                });
                              },
                              index: index,
                              selectedIndex: selecedIndex,
                              showIconOnly: width > 1000.0 ? false : true,
                              icon: icons[index],
                              title: titles[index],
                            )))),
          ],
        ));
  }

  Widget header() {
    return const Expanded(
      flex: 2,
      child: Center(
        child: Text(
          'Stock management',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.amber, fontFamily: gilroyBold, fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
    );
  }
}
