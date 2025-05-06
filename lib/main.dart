import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/login_view/views/login_view.dart';
import 'package:stock_managament_admin/app/modules/nav_bar_page/views/nav_bar_page_view.dart';
import 'package:stock_managament_admin/app/product/constants/string_constants.dart';
import 'package:stock_managament_admin/app/product/constants/theme_contants.dart';
import 'package:stock_managament_admin/app/product/init/app_start_init.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStartInit.init();
  runApp(_MyApp());
}

class _MyApp extends StatefulWidget {
  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  bool isLoginFuture = false;

  @override
  void initState() {
    super.initState();
    getLoginValue();
  }

  dynamic getLoginValue() async {
    final String? accessToken = await AuthStorage().getToken();
    if (accessToken != null) {
      isLoginFuture = true;
    } else {
      isLoginFuture = false;
    }
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
              title: StringConstants.appName,
              theme: AppThemes.lightTheme,
              fallbackLocale: const Locale('tm'),
              locale: AppStartInit().getLocale(),
              translations: MyTranslations(),
              defaultTransition: Transition.fadeIn,
              home: isLoginFuture == true ? NavBarPageView() : LoginView());
        });
  }
}
