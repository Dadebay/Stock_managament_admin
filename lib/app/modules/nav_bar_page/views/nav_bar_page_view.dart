import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_controller.dart';
import 'package:stock_managament_admin/app/modules/sales/views/order_view.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/drawer_button.dart';

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
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          drawer(width),
          Expanded(flex: 6, child: Container(color: Colors.white, child: OrderView())),
          //   child: Container(
          //     color: Colors.white,
          //     child: StringConstants.pages[selecedIndex],
          //   ),
          // ),
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
              padding: context.padding.normal,
              child: Divider(color: Colors.amber.withOpacity(0.2), thickness: 2),
            ),
            Expanded(
                flex: 13,
                child: Column(
                    children: List.generate(
                        StringConstants.pages.length,
                        (index) => DrawerButtonMine(
                              onTap: () {
                                setState(() {
                                  selecedIndex = index;
                                });
                              },
                              index: index,
                              selectedIndex: selecedIndex,
                              showIconOnly: width > 1000.0 ? false : true,
                              icon: selecedIndex == index ? StringConstants.selectedIcons[index] : StringConstants.icons[index],
                              title: StringConstants.titles[index],
                            )))),
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
