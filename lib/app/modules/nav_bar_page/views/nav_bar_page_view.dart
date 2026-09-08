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
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_controller.dart';
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
  final SearchViewController seacrhViewController =
      Get.put(SearchViewController());
  final ClientsController clientsController = Get.put(ClientsController());
  final FourInOnePageController fourInOnePageController =
      Get.put(FourInOnePageController());
  final PurchasesController purchasesController =
      Get.put(PurchasesController());
  final ExpencesController expencesController = Get.put(ExpencesController());
  final OrderController orderController = Get.put(OrderController());
  final HomeController homeController = Get.put(HomeController());
  final EnterController enterController = Get.put(EnterController());

  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    findAdminStatus(); // Metod isimleri genellikle küçük harfle başlar (Dart konvansiyonu)
  }

  void findAdminStatus() async {
    isAdmin = await AuthStorage().getAdminStatus();
    if (mounted) {
      // initState'de async işlem sonrası setState için kontrol
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List pages = isAdmin
        ? [
            HomeView(isAdmin: isAdmin),
            OrderView(isAdmin: isAdmin),
            SearchView(
                selectableProducts: false,
                addCounterWidget: false,
                isAdmin: isAdmin,
                hideAppBar: true),
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
            SearchView(
                selectableProducts: false,
                addCounterWidget: false,
                isAdmin: isAdmin,
                hideAppBar: true),
            PurchasesView(isAdmin: isAdmin),
            FourInOnePageView(isAdmin: isAdmin),
            ExpencesView(isAdmin: isAdmin),
            ClientsView(isAdmin: isAdmin),
            Container(),
          ];

    double width = MediaQuery.of(context).size.width;
    final bool compactNavigation = width < 1100;
    final String pageTitle = isAdmin == false
        ? StringConstants.adminTitles[selecedIndex]
        : StringConstants.titles[selecedIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          drawer(compactNavigation, pages, context),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  if (selecedIndex != _homePageIndex &&
                      selecedIndex != _expencesPageIndex &&
                      selecedIndex != _purchasesPageIndex &&
                      selecedIndex != _searchPageIndex &&
                      selecedIndex != _salesPageIndex &&
                      selecedIndex != _clientsPageIndex)
                    contentAppBar(pageTitle),
                  Expanded(child: pages[selecedIndex]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget contentAppBar(String pageTitle) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Text(
        pageTitle.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Index where the admin-only entries ('users', 'logs') begin; everything
  /// before it is the shared main menu, everything after is the log out row.
  static const int _adminSectionStart = 7;

  /// These pages render their own page bar (years + title + search), so the
  /// generic [contentAppBar] is skipped for them to avoid a duplicated bar.
  static const int _homePageIndex = 0;
  static const int _purchasesPageIndex = 3;
  static const int _expencesPageIndex = 5;
  static const int _searchPageIndex = 2;
  static const int _salesPageIndex = 1;
  static const int _clientsPageIndex = 6;

  List<Widget> buildNavItems(int start, int end, bool compactNavigation) {
    return List.generate(end - start, (offset) {
      final int index = start + offset;
      return DrawerButtonMine(
        onTap: () => setState(() {
          selecedIndex = index;
        }),
        index: index,
        selectedIndex: selecedIndex,
        showIconOnly: compactNavigation,
        icon: selecedIndex == index
            ? (isAdmin == false
                ? StringConstants.selectedAdminIcons[index]
                : StringConstants.selectedIcons[index])
            : (isAdmin == false
                ? StringConstants.adminIcons[index]
                : StringConstants.icons[index]),
        title: isAdmin == false
            ? StringConstants.adminTitles[index]
            : StringConstants.titles[index],
      );
    });
  }

  Widget drawer(bool compactNavigation, List pages, BuildContext context) {
    final int logOutIndex = pages.length - 1;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: compactNavigation ? 84 : 280,
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          border: Border(right: BorderSide(color: Color(0xFF1F2937))),
        ),
        child: SafeArea(
            right: false,
            child: Column(
              children: [
                header(compactNavigation),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                      color: Colors.white.withValues(alpha: 0.08), height: 1),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NavSectionLabel(
                            title: 'navMain', showIconOnly: compactNavigation),
                        ...buildNavItems(
                            0, _adminSectionStart, compactNavigation),
                        if (logOutIndex > _adminSectionStart) ...[
                          NavSectionLabel(
                              title: 'navAdmin',
                              showIconOnly: compactNavigation),
                          ...buildNavItems(_adminSectionStart, logOutIndex,
                              compactNavigation),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                      color: Colors.white.withValues(alpha: 0.08), height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: DrawerButtonMine(
                    onTap: () async => SignInService().logOut(context),
                    index: logOutIndex,
                    selectedIndex: selecedIndex,
                    showIconOnly: compactNavigation,
                    icon: isAdmin == false
                        ? StringConstants.adminIcons[logOutIndex]
                        : StringConstants.icons[logOutIndex],
                    title: isAdmin == false
                        ? StringConstants.adminTitles[logOutIndex]
                        : StringConstants.titles[logOutIndex],
                    isDanger: true,
                  ),
                ),
                LanguageButton(showIconOnly: compactNavigation),
              ],
            )));
  }

  Widget header(bool compactNavigation) {
    final Widget mark = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DrawerButtonMine.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'K',
        style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            height: 1),
      ),
    );

    return Container(
      height: 84,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: compactNavigation ? 22 : 18),
      // While the rail animates between 84 and 280 px the expanded header is
      // briefly wider than its parent, so clip instead of overflowing.
      child: compactNavigation
          ? mark
          : ClipRect(
              child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: 0,
              maxWidth: 280,
              child: Row(
                children: [
                  mark,
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kümüş',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              height: 1.1),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'ONLINE PLATFORMA',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                              letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
    );
  }
}
