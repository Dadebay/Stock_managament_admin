import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stock_managament_admin/app/modules/login/views/login_view.dart';
import 'package:stock_managament_admin/app/modules/nav_bar_page/views/nav_bar_page_view.dart';
import 'package:stock_managament_admin/constants/utils.dart';

import 'constants/customWidget/constants.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyBb-ONIbH2uZrBKaQQBfsgISqB2nzJCjxQ',
    appId: '1:808707795977:web:3201cc61a72d911a9a5cd8',
    messagingSenderId: '808707795977',
    projectId: 'stock-managament-4ab89',
    authDomain: 'stock-managament-4ab89.firebaseapp.com',
    storageBucket: 'stock-managament-4ab89.appspot.com',
    measurementId: 'G-8Y69HSE8M8',
  ));
  await GetStorage.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = GetStorage();
  bool loginValue = false;

  @override
  void initState() {
    super.initState();
    changeLoginData();
  }

  changeLoginData() async {
    loginValue = storage.read('login') ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: appName,
              theme: ThemeData(
                brightness: Brightness.light,
                fontFamily: gilroyRegular,
                colorSchemeSeed: kPrimaryColor,
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark),
                  titleTextStyle: TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 20),
                  elevation: 0,
                ),
                bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent.withOpacity(0)),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              fallbackLocale: const Locale('tm'),
              locale: storage.read('langCode') != null ? Locale(storage.read('langCode')) : const Locale('tm'),
              translations: MyTranslations(),
              defaultTransition: Transition.fade,
              home: loginValue == false ? LoginView() : const NavBarPageView());
          // home: const NavBarPageView());
          // home: const NavBarPageView());
        });
  }
}
