import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/modules/clients/views/clients_view.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_controller.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_page_view.dart';
import 'package:stock_managament_admin/app/modules/home/views/home_view.dart';
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchases_view.dart';
import 'package:stock_managament_admin/app/modules/sales/views/order_view.dart';
import 'package:stock_managament_admin/app/modules/search/views/search_view.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/views/entering_app_view.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/views/logs_view.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/drawer_button.dart';

import '../../expences/views/expences_view.dart';

class NavBarPageView extends StatefulWidget {
  const NavBarPageView({super.key});

  @override
  State<NavBarPageView> createState() => _NavBarPageViewState();
}

class _NavBarPageViewState extends State<NavBarPageView> {
  int selecedIndex = 0;
  final SearchViewController seacrhViewController = Get.put(SearchViewController());
  final ClientsController clientsController = Get.put(ClientsController());
  final FourInOnePageController fourInOnePageController = Get.put(FourInOnePageController());
  final OrderController salesController = Get.put(OrderController());
  final PurchasesController purchasesController = Get.put(PurchasesController());
  final ExpencesController expencesController = Get.put<ExpencesController>(ExpencesController());

  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    FindAdminStatus();
  }

  FindAdminStatus() async {
    isAdmin = await AuthStorage().getAdminStatus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List pages = isAdmin
        ? [
            HomeView(isAdmin: isAdmin),
            OrderView(isAdmin: isAdmin),
            SearchView(selectableProducts: false, isAdmin: isAdmin),
            PurchasesView(isAdmin: isAdmin),
            FourInOnePageView(isAdmin: isAdmin),
            ExpencesView(isAdmin: isAdmin),
            ClientsView(isAdmin: isAdmin),
            EnteringAppView(isAdmin: isAdmin),
            LogsView(),
            Container()
          ]
        : [
            HomeView(isAdmin: isAdmin),
            OrderView(isAdmin: isAdmin),
            SearchView(selectableProducts: false, isAdmin: isAdmin),
            PurchasesView(isAdmin: isAdmin),
            FourInOnePageView(isAdmin: isAdmin),
            ExpencesView(isAdmin: isAdmin),
            ClientsView(isAdmin: isAdmin),
            Container(),
          ];

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          drawer(width, pages, context),
          Expanded(
            flex: 6,
            //  child: Container(color: Colors.white, child: OrderView(isAdmin: isAdmin))
            //  ),

            child: Container(
              color: Colors.white,
              child: pages[selecedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Expanded drawer(double width, List pages, BuildContext context) {
    return Expanded(
        flex: 1,
        child: Column(
          children: [
            header(),
            Padding(
              padding: context.padding.low,
              child: Divider(color: Colors.amber.withOpacity(0.2), thickness: 2),
            ),
            Expanded(
              flex: 17,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(pages.length, (index) {
                    String title = isAdmin == false ? StringConstants.adminTitles[index] : StringConstants.titles[index];
                    IconData selectedIcon = isAdmin == false ? StringConstants.selectedAdminIcons[index] : StringConstants.selectedIcons[index];
                    IconData icon = isAdmin == false ? StringConstants.adminIcons[index] : StringConstants.icons[index];

                    return DrawerButtonMine(
                      onTap: () async {
                        setState(() {
                          selecedIndex = index;
                        });
                        int logOutIndex = isAdmin == false ? 7 : 9;
                        if (selecedIndex == logOutIndex) {
                          await SignInService().logOut(context);
                        }
                      },
                      index: index,
                      selectedIndex: selecedIndex,
                      showIconOnly: width > 1000.0 ? false : true,
                      icon: selecedIndex == index ? selectedIcon : icon,
                      title: title,
                    );
                  }),
                ),
              ),
            ),
            LanguageButton(),
          ],
        ));
  }

  Widget header() {
    return const Expanded(
      flex: 2,
      child: Center(
        child: Text(
          StringConstants.appName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
    );
  }
}
