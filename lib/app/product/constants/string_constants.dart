import 'package:flutter/cupertino.dart';
import 'package:stock_managament_admin/app/modules/clients/views/clients_view.dart';
import 'package:stock_managament_admin/app/modules/expences/views/expences_view.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_page_view.dart';
import 'package:stock_managament_admin/app/modules/home/views/home_view.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchases_view.dart';
import 'package:stock_managament_admin/app/modules/sales/views/index.dart';
import 'package:stock_managament_admin/app/modules/search/views/search_view.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/views/entering_app_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

enum ColumnSize { small, medium, large }

@immutable
class StringConstants {
  static const String appName = 'Kümüş Online Platforma ';
  static List<Map<String, String>> four_in_one_names = [
    {'name': 'brands', 'pageView': "Brands", "countName": 'brends', "id": "1", 'size': ColumnSize.small.toString(), "url": ApiConstants.brends},
    {'name': 'categories', 'pageView': "Categories", "countName": 'category', "id": "2", 'size': ColumnSize.small.toString(), "url": ApiConstants.categories},
    {'name': 'locations', 'pageView': "Locations", "countName": 'location', "id": "3", 'size': ColumnSize.small.toString(), "url": ApiConstants.locations},
    {'name': 'materials', 'pageView': "Materials", "countName": 'materials', "id": "4", 'size': ColumnSize.small.toString(), "url": ApiConstants.materials},
  ];
  static List<Map<String, String>> statusList = [
    {'name': 'Shipped', 'statusName': 'shipped'},
    {'name': 'Canceled', 'statusName': 'canceled'},
    {'name': 'Refund', 'statusName': 'refund'},
    {'name': 'Preparing', 'statusName': 'preparing'},
    {'name': 'Ready to ship', 'statusName': 'ready to ship'},
  ];
  static List<Map<String, String>> orderNamesList = [
    {
      'name': 'Order Name',
      'sortName': "name",
      'size': ColumnSize.large.toString(),
    },
    {
      'name': 'Date',
      'sortName': "date",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'Product count',
      'sortName': "count",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'Sum Price',
      'sortName': "totalsum",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'Sum Cost',
      'sortName': "totalchykdajy",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'Status',
      'sortName': "status",
      'size': ColumnSize.small.toString(),
    },
  ];
  static List<Map<String, String>> clientNames = [
    {'name': 'Client Name', 'sortName': "name", 'size': ColumnSize.medium.toString()},
    {'name': 'Address', 'sortName': "address", 'size': ColumnSize.medium.toString()},
    {'name': 'Client number', 'sortName': "number", 'size': ColumnSize.small.toString()},
    {'name': 'Order count', 'sortName': "order_count", 'size': ColumnSize.small.toString()},
    {'name': 'Sum price', 'sortName': "sum_price", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> userNames = [
    {'name': 'Username', 'sortName': "username", 'size': ColumnSize.small.toString()},
    {'name': 'Password', 'sortName': "password", 'size': ColumnSize.small.toString()},
    {'name': 'Admin', 'sortName': "isSuperUser", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> expencesNames = [
    {'name': 'Expences Name', 'sortName': "name", 'size': ColumnSize.medium.toString()},
    {'name': 'Date', 'sortName': "date", 'size': ColumnSize.medium.toString()},
    {'name': 'Cost', 'sortName': "cost", 'size': ColumnSize.medium.toString()},
    {'name': 'Note', 'sortName': "notes", 'size': ColumnSize.medium.toString()},
  ];
  static List<Map<String, String>> topPartNamesPurchases = [
    {'name': 'Purchase Title', 'sortName': "title", 'size': ColumnSize.small.toString()},
    {'name': 'Date', 'sortName': "date", 'size': ColumnSize.small.toString()},
    {'name': 'Source', 'sortName': "source", 'size': ColumnSize.small.toString()},
    {'name': 'Product count', 'sortName': "count", 'size': ColumnSize.small.toString()},
    {'name': 'Sum Cost', 'sortName': "cost", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> searchViewFilters = [
    {'name': 'Brands', 'searchName': 'brends'},
    {'name': 'Categories', 'searchName': 'category'},
    {'name': 'Locations', 'searchName': 'location'},
    {'name': 'Materials', 'searchName': 'material'}
  ];
  static List<Map<String, String>> searchViewtopPartNames = [
    {'name': 'Product Name', 'sortName': "count", 'size': ColumnSize.large.toString()},
    {'name': 'Cost', 'sortName': "cost", 'size': ColumnSize.small.toString()},
    {'name': 'Sell Price', 'sortName': "price", 'size': ColumnSize.small.toString()},
    {'name': 'Brand', 'sortName': "brends", 'size': ColumnSize.small.toString()},
    {'name': 'Category', 'sortName': "category", 'size': ColumnSize.small.toString()},
    {'name': 'Location', 'sortName': "location", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> salesTopText = [
    {'name': 'Product Name', 'sortName': "count", 'size': ColumnSize.large.toString()},
    {'name': 'Cost', 'sortName': "cost", 'size': ColumnSize.small.toString()},
    {'name': 'Sell Price', 'sortName': "price", 'size': ColumnSize.small.toString()},
    {'name': 'Brand', 'sortName': "brends", 'size': ColumnSize.small.toString()},
    {'name': 'Category', 'sortName': "category", 'size': ColumnSize.small.toString()},
    {'name': 'Location', 'sortName': "location", 'size': ColumnSize.small.toString()},
    {'name': 'Count', 'sortName': "count", 'size': ColumnSize.small.toString()},
  ];
  static final List<String> fieldLabels = [
    'Name',
    'Sell price',
    "Date",
    'Category',
    'Brand',
    'Location',
    'Material',
    'Gram',
    'Count',
    'Description',
    'Package (Gaplama)',
    'Cost',
  ];

  static final List<String> apiFieldNames = [
    'name',
    'price',
    'created_at',
    'category',
    'brends',
    'location',
    'materials',
    'gram',
    'count',
    'description',
    'gaplama',
    'cost',
  ];

  static List<Map<String, dynamic>> statusMapping = [
    {'name': 'Preparing', 'sortName': "0", 'size': ColumnSize.small.toString(), 'color': ColorConstants.kPrimaryColor2},
    {'name': 'Preparing', 'sortName': "1", 'size': ColumnSize.small.toString(), 'color': ColorConstants.kPrimaryColor2},
    {'name': 'Shipped', 'sortName': "2", 'size': ColumnSize.small.toString(), 'color': Colors.green},
    {'name': 'Canceled', 'sortName': "3", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'Refund', 'sortName': "4", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'Ready to ship', 'sortName': "5", 'size': ColumnSize.small.toString(), 'color': Colors.purple},
  ];
  static List<Map<String, dynamic>> statusMapping2 = [
    {'name': 'Preparing', 'sortName': "1", 'size': ColumnSize.small.toString(), 'color': ColorConstants.kPrimaryColor2},
    {'name': 'Ready to ship', 'sortName': "5", 'size': ColumnSize.small.toString(), 'color': Colors.purple},
    {'name': 'Shipped', 'sortName': "2", 'size': ColumnSize.small.toString(), 'color': Colors.green},
    {'name': 'Canceled', 'sortName': "3", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'Refund', 'sortName': "4", 'size': ColumnSize.small.toString(), 'color': Colors.red},
  ];
  static List pages = [HomeView(), OrderView(), SearchView(selectableProducts: false), const PurchasesView(), FourInOnePageView(), ExpencesView(), ClientsView(), EnteringAppView()];
  static List icons = [IconlyLight.chart, IconlyLight.paper, IconlyLight.search, CupertinoIcons.cart_badge_plus, IconlyLight.category, IconlyLight.wallet, IconlyLight.user3, IconlyLight.setting];
  static List selectedIcons = [IconlyBold.chart, IconlyBold.paper, IconlyBold.search, CupertinoIcons.cart_fill_badge_plus, IconlyBold.category, IconlyBold.wallet, IconlyBold.user3, IconlyBold.setting];
  static List titles = ['home', 'Sales', 'Search', 'Purchases', 'Four in One page', 'Expences', 'Clients', 'Users'];
}
