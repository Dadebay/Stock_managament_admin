import 'package:stock_managament_admin/app/product/init/packages.dart';

class HttpOverridesCustom extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

@immutable
class AppStartInit {
  final storage = GetStorage();

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
    HttpOverrides.global = HttpOverridesCustom();
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBpIrCA8v5_JFWoSkKRdRTM0sEVGj4YecM",
            authDomain: "stock-managament-new.firebaseapp.com",
            projectId: "stock-managament-new",
            storageBucket: "stock-managament-new.firebasestorage.app",
            messagingSenderId: "645642131883",
            appId: "1:645642131883:web:5d0d6343aabe97291f9aee",
            measurementId: "G-NGFYKF85MP"));
    await GetStorage.init();
  }
}
