import 'package:flutter/cupertino.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

enum ColumnSize { small, medium, large }

@immutable
class StringConstants {
  static const String appName = 'Kümüş Online Platforma ';
  static List<Map<String, String>> four_in_one_names = [
    {'name': 'addBrend', 'pageView': "brands", "countName": 'brends', "id": "1", 'size': ColumnSize.small.toString(), "url": ApiConstants.brends},
    {'name': 'addCategory', 'pageView': "category", "countName": 'category', "id": "2", 'size': ColumnSize.small.toString(), "url": ApiConstants.categories},
    {'name': 'addLocation', 'pageView': "places", "countName": 'location', "id": "3", 'size': ColumnSize.small.toString(), "url": ApiConstants.locations},
    {'name': 'addMaterial', 'pageView': "material", "countName": 'materials', "id": "4", 'size': ColumnSize.small.toString(), "url": ApiConstants.materials},
  ];
  static List<Map<String, String>> statusList = [
    {'name': 'shipped', 'statusName': 'shipped'},
    {'name': 'canceled', 'statusName': 'canceled'},
    {'name': 'refund', 'statusName': 'refund'},
    {'name': 'preparing', 'statusName': 'preparing'},
    {'name': 'readyToShip', 'statusName': 'ready to ship'},
  ];
  static List<Map<String, String>> orderNamesList = [
    {
      'name': 'orderName',
      'sortName': "name",
      'size': ColumnSize.large.toString(),
    },
    {
      'name': 'date',
      'sortName': "date",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'count',
      'sortName': "count",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'sellPrice',
      'sortName': "totalsum",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'cost',
      'sortName': "totalchykdajy",
      'size': ColumnSize.small.toString(),
    },
    {
      'name': 'status',
      'sortName': "status",
      'size': ColumnSize.small.toString(),
    },
  ];
  static List<Map<String, String>> clientNames = [
    {'name': 'clientName', 'sortName': "name", 'size': ColumnSize.medium.toString()},
    {'name': 'address', 'sortName': "address", 'size': ColumnSize.medium.toString()},
    {'name': 'phone', 'sortName': "number", 'size': ColumnSize.small.toString()},
    {'name': 'orderCount', 'sortName': "order_count", 'size': ColumnSize.small.toString()},
    {'name': 'sumPrice', 'sortName': "sum_price", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> userNames = [
    {'name': 'client_name', 'sortName': "username", 'size': ColumnSize.small.toString()},
    {'name': 'userpassword', 'sortName': "password", 'size': ColumnSize.small.toString()},
    {'name': 'admin', 'sortName': "isSuperUser", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> expencesNames = [
    {'name': 'expences_name', 'sortName': "name", 'size': ColumnSize.medium.toString()},
    {'name': 'date', 'sortName': "date", 'size': ColumnSize.medium.toString()},
    {'name': 'cost', 'sortName': "cost", 'size': ColumnSize.medium.toString()},
    {'name': 'note', 'sortName': "notes", 'size': ColumnSize.medium.toString()},
  ];
  static List<Map<String, String>> topPartNamesPurchases = [
    {'name': 'purchases', 'sortName': "title", 'size': ColumnSize.small.toString()},
    {'name': 'date', 'sortName': "date", 'size': ColumnSize.small.toString()},
    {'name': 'description', 'sortName': "source", 'size': ColumnSize.small.toString()},
    {'name': 'count', 'sortName': "count", 'size': ColumnSize.small.toString()},
    {'name': 'cost', 'sortName': "cost", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> searchViewFilters = [
    {'name': 'brand', 'searchName': 'brends'},
    {'name': 'Categories', 'searchName': 'category'},
    {'name': 'Locations', 'searchName': 'location'},
    {'name': 'Materials', 'searchName': 'material'}
  ];
  static List<Map<String, String>> searchViewtopPartNames = [
    {'name': 'productName', 'sortName': "count", 'size': ColumnSize.medium.toString()},
    {'name': 'costPrice', 'sortName': "cost", 'size': ColumnSize.small.toString()},
    {'name': 'sellPrice', 'sortName': "price", 'size': ColumnSize.small.toString()},
    {'name': 'brand', 'sortName': "brends", 'size': ColumnSize.small.toString()},
    {'name': 'category', 'sortName': "category", 'size': ColumnSize.small.toString()},
    {'name': 'location', 'sortName': "location", 'size': ColumnSize.small.toString()},
  ];
  static List<Map<String, String>> salesTopText = [
    {'name': 'productName', 'sortName': "count", 'size': ColumnSize.large.toString()},
    {'name': 'costPrice', 'sortName': "cost", 'size': ColumnSize.small.toString()},
    {'name': 'sellPrice', 'sortName': "price", 'size': ColumnSize.small.toString()},
    {'name': 'brand', 'sortName': "brends", 'size': ColumnSize.small.toString()},
    {'name': 'category', 'sortName': "category", 'size': ColumnSize.small.toString()},
    {'name': 'location', 'sortName': "location", 'size': ColumnSize.small.toString()},
    {'name': 'count', 'sortName': "count", 'size': ColumnSize.small.toString()},
  ];
  static final List<String> fieldLabels = [
    'name',
    'sellPrice',
    "date",
    'category',
    'brand',
    'location',
    'material',
    'Gram',
    'count',
    'note',
    'Package (Gaplama)',
    'costPrice',
  ];

  static final List<String> apiFieldNames = [
    'name',
    'price',
    'date',
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
    {'name': 'preparing', 'sortName': "0", 'size': ColumnSize.small.toString(), 'color': ColorConstants.kPrimaryColor2},
    {'name': 'preparing', 'sortName': "1", 'size': ColumnSize.small.toString(), 'color': ColorConstants.kPrimaryColor2},
    {'name': 'shipped', 'sortName': "2", 'size': ColumnSize.small.toString(), 'color': Colors.green},
    {'name': 'canceled', 'sortName': "3", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'refund', 'sortName': "4", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'readyToShip', 'sortName': "5", 'size': ColumnSize.small.toString(), 'color': Colors.purple},
  ];
  static List<Map<String, dynamic>> statusMapping2 = [
    {'name': 'preparing', 'sortName': "1", 'size': ColumnSize.small.toString(), 'color': ColorConstants.kPrimaryColor2},
    {'name': 'readyToShip', 'sortName': "5", 'size': ColumnSize.small.toString(), 'color': Colors.purple},
    {'name': 'shipped', 'sortName': "2", 'size': ColumnSize.small.toString(), 'color': Colors.green},
    {'name': 'canceled', 'sortName': "3", 'size': ColumnSize.small.toString(), 'color': Colors.red},
    {'name': 'refund', 'sortName': "4", 'size': ColumnSize.small.toString(), 'color': Colors.red},
  ];
  static List icons = [
    IconlyLight.chart,
    IconlyLight.paper,
    IconlyLight.search,
    CupertinoIcons.cart_badge_plus,
    IconlyLight.category,
    IconlyLight.wallet,
    IconlyLight.user3,
    IconlyLight.setting,
    IconlyLight.document,
    IconlyLight.logout,
  ];
  static List adminIcons = [
    IconlyLight.chart,
    IconlyLight.paper,
    IconlyLight.search,
    CupertinoIcons.cart_badge_plus,
    IconlyLight.category,
    IconlyLight.wallet,
    IconlyLight.user3,
    IconlyLight.logout,
  ];
  static List selectedIcons = [
    IconlyBold.chart,
    IconlyBold.paper,
    IconlyBold.search,
    CupertinoIcons.cart_fill_badge_plus,
    IconlyBold.category,
    IconlyBold.wallet,
    IconlyBold.user3,
    IconlyBold.setting,
    IconlyBold.document,
    IconlyBold.logout,
  ];
  static List selectedAdminIcons = [
    IconlyBold.chart,
    IconlyBold.paper,
    IconlyBold.search,
    CupertinoIcons.cart_fill_badge_plus,
    IconlyBold.category,
    IconlyBold.wallet,
    IconlyBold.user3,
    IconlyBold.logout,
  ];
  static List adminTitles = ['home', 'sales', 'search', 'purchases', 'category', 'expences', 'clients', 'log_out'];
  static List titles = ['home', 'sales', 'search', 'purchases', 'category', 'expences', 'clients', 'users', 'logs', 'log_out'];
}
