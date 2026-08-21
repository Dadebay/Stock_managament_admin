import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/login_view/controllers/auth_service.dart';
import 'package:stock_managament_admin/app/modules/nav_bar_page/views/nav_bar_page_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

// ignore: must_be_immutable
class LoginView extends StatelessWidget {
  FocusNode focusNode = FocusNode();
  FocusNode focusNode1 = FocusNode();
  final HomeController homeController = Get.put(HomeController());

  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingController1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  dynamic loginButtonOnTap() async {
    if (_formKey.currentState!.validate()) {
      homeController.agreeButton.value = !homeController.agreeButton.value;

      await SignInService()
          .login(
              username: textEditingController.text,
              password: textEditingController1.text)
          .then((value) async {
        if (value != null) {
          await SignInService().getClients(
              textEditingController.text, textEditingController1.text);

          Get.offAll(() => const NavBarPageView());
        } else {
          textEditingController.clear();
          textEditingController1.clear();
        }
      });
      homeController.agreeButton.value = !homeController.agreeButton.value;
    } else {
      CustomWidgets.showSnackBar(
          'errorTitle', 'loginErrorFillBlanks', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        return Row(children: [
          if (!compact)
            Expanded(
              flex: 5,
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(IconConstants.loginImage, fit: BoxFit.cover),
                const DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xAA0F172A), Color(0x661E3A8A)]))),
                Positioned(top: 38, left: 38, child: _brandMark(light: true)),
              ]),
            ),
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0F0F172A),
                              blurRadius: 26,
                              offset: Offset(0, 10))
                        ]),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _brandMark(),
                              const SizedBox(height: 20),
                              Text('login'.tr,
                                  style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF172033))),
                              const SizedBox(height: 6),
                              Text('loginSubtitle'.tr,
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      height: 1.4,
                                      color: const Color(0xFF64748B))),
                              const SizedBox(height: 24),
                              _field(
                                  label: 'userName',
                                  controller: textEditingController,
                                  focus: focusNode,
                                  next: focusNode1,
                                  icon: Icons.person_outline,
                                  action: TextInputAction.next,
                                  onSubmitted: (_) => FocusScope.of(context)
                                      .requestFocus(focusNode1)),
                              const SizedBox(height: 14),
                              _field(
                                  label: 'userpassword',
                                  controller: textEditingController1,
                                  focus: focusNode1,
                                  next: focusNode,
                                  icon: Icons.lock_outline,
                                  obscure: true,
                                  action: TextInputAction.done,
                                  onSubmitted: (_) => loginButtonOnTap()),
                              const SizedBox(height: 22),
                              SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: FilledButton(
                                      onPressed: () => loginButtonOnTap(),
                                      style: FilledButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4F46E5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      child: Text('login'.tr,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700)))),
                            ])),
                  ),
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }

  Widget _brandMark({bool light = false}) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: light
                ? Colors.white.withValues(alpha: .15)
                : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
            border: light
                ? Border.all(color: Colors.white.withValues(alpha: .25))
                : null),
        alignment: Alignment.center,
        child: Icon(Icons.verified_user_outlined,
            size: 20, color: light ? Colors.white : const Color(0xFF4F46E5)),
      );

  Widget _field(
          {required String label,
          required TextEditingController controller,
          required FocusNode focus,
          required FocusNode next,
          required IconData icon,
          required TextInputAction action,
          required ValueChanged<String> onSubmitted,
          bool obscure = false}) =>
      TextFormField(
        controller: controller,
        focusNode: focus,
        obscureText: obscure,
        textInputAction: action,
        onFieldSubmitted: onSubmitted,
        validator: (value) => value == null || value.trim().isEmpty
            ? 'loginErrorFillBlanks'.tr
            : null,
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF172033)),
        decoration: InputDecoration(
            labelText: label.tr,
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE4EF))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE4EF))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF4F46E5), width: 1.3))),
      );
}
