import 'package:stock_managament_admin/app/product/init/packages.dart';

@immutable
class AppStartInit {
  final storage = AppStorage();

  Locale getLocale() {
    final String? langCode = storage.read('langCode');
    if (langCode != null) {
      return Locale(langCode);
    } else {
      return const Locale('tm');
    }
  }

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await AppStorage.init();
  }
}
