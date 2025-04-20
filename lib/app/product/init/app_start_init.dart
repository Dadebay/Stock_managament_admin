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
      apiKey: 'AIzaSyBb-ONIbH2uZrBKaQQBfsgISqB2nzJCjxQ',
      appId: '1:808707795977:web:3201cc61a72d911a9a5cd8',
      messagingSenderId: '808707795977',
      projectId: 'stock-managament-4ab89',
      authDomain: 'stock-managament-4ab89.firebaseapp.com',
      storageBucket: 'stock-managament-4ab89.appspot.com',
      measurementId: 'G-8Y69HSE8M8',
    ));
    await GetStorage.init();
  }
}
