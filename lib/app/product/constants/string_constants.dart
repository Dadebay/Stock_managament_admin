import 'package:flutter/cupertino.dart';
import 'package:stock_managament_admin/app/modules/clients/views/clients_view.dart';
import 'package:stock_managament_admin/app/modules/expences/views/expences_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

enum ColumnSize { small, medium, large }

@immutable
class StringConstants {
  static const String appName = 'Kümüş Online Platforma ';
  static List<Map<String, String>> four_in_one_names = [
    {'name': 'brands', 'pageView': "Brands", "countName": 'brand', "id": "1", 'size': ColumnSize.small.toString(), "url": ApiConstants.brends},
    {'name': 'categories', 'pageView': "Categories", "countName": 'category', "id": "2", 'size': ColumnSize.small.toString(), "url": ApiConstants.categories},
    {'name': 'locations', 'pageView': "Locations", "countName": 'location', "id": "3", 'size': ColumnSize.small.toString(), "url": ApiConstants.locations},
    {'name': 'materials', 'pageView': "Materials", "countName": 'material', "id": "4", 'size': ColumnSize.small.toString(), "url": ApiConstants.materials},
  ];
  static List<Map<String, String>> statusList = [
    {'name': 'Shipped', 'statusName': 'shipped'},
    {'name': 'Canceled', 'statusName': 'canceled'},
    {'name': 'Refund', 'statusName': 'refund'},
    {'name': 'Preparing', 'statusName': 'preparing'},
    {'name': 'Ready to ship', 'statusName': 'ready to ship'},
  ];
  static List<Map<String, String>> topPartNames = [
    {'name': 'Order Name', 'sortName': "client_number"},
    {'name': 'Date', 'sortName': "date"},
    {'name': 'Product count', 'sortName': "product_count"},
    {'name': '   Sum Price', 'sortName': "sum_price"},
    {'name': ' Sum Cost', 'sortName': "sum_cost"},
    {'name': 'Status', 'sortName': "status"},
  ];
  static List<Map<String, String>> clientNames = [
    {'name': 'Client Name', 'sortName': "name", 'size': ColumnSize.medium.toString()},
    {'name': 'Address', 'sortName': "address", 'size': ColumnSize.large.toString()},
    {'name': 'Client number', 'sortName': "number", 'size': ColumnSize.small.toString()},
    {'name': 'Order count', 'sortName': "order_count", 'size': ColumnSize.small.toString()},
    {'name': 'Sum price', 'sortName': "sum_price", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> expencesNames = [
    {'name': 'Expences Name', 'sortName': "name", 'size': ColumnSize.medium.toString()},
    {'name': 'Date', 'sortName': "date", 'size': ColumnSize.medium.toString()},
    {'name': 'Cost', 'sortName': "cost", 'size': ColumnSize.medium.toString()},
    {'name': 'Note', 'sortName': "notes", 'size': ColumnSize.medium.toString()},
  ];
  static List<Map<String, String>> topPartNamesPurchases = [
    {'name': 'Purchase Title', 'sortName': "client_number"},
    {'name': 'Date', 'sortName': "date"},
    {'name': 'Source', 'sortName': "source"},
    {'name': 'Product count', 'sortName': "product_count"},
    {'name': 'Sum Cost', 'sortName': "cost"},
  ];

  static List pages = [
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    // HomeView(),
    // const SalesView(),
    // const PurchasesView(),
    // const SearchView(),
    // const FourInOnePageView(),
    ExpencesView(),
    ClientsView(),
  ];
  static List icons = [IconlyLight.chart, IconlyLight.paper, CupertinoIcons.cart_badge_plus, IconlyLight.search, IconlyLight.category, IconlyLight.wallet, IconlyLight.user3, IconlyLight.setting];
  static List selectedIcons = [IconlyBold.chart, IconlyBold.paper, CupertinoIcons.cart_fill_badge_plus, IconlyBold.search, IconlyBold.category, IconlyBold.wallet, IconlyBold.user3, IconlyBold.setting];
  static List titles = ['home', 'Sales', 'Purchases', 'Search', 'Four in One page', 'Expences', 'Clients', 'Settings'];
}
