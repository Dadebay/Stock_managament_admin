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

      await SignInService().login(username: textEditingController.text, password: textEditingController1.text).then((value) async {
        if (value != null) {
          await SignInService().getClients(textEditingController.text, textEditingController1.text);

          Get.offAll(() => const NavBarPageView());
        } else {
          textEditingController.clear();
          textEditingController1.clear();
        }
      });
      homeController.agreeButton.value = !homeController.agreeButton.value;
    } else {
      CustomWidgets.showSnackBar('errorTitle', 'loginErrorFillBlanks', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
              flex: 4,
              child: SizedBox(
                width: Get.size.width,
                height: Get.size.height,
                child: Image.asset(IconConstants.loginImage, fit: BoxFit.cover),
              )),
          Expanded(
            flex: 4,
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: context.padding.high,
                children: [
                  Text(
                    'login'.tr.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: context.general.textTheme.displayLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 30.sp),
                  ),
                  Padding(
                    padding: context.padding.verticalNormal,
                    child: Text(
                      'loginSubtitle'.tr,
                      textAlign: TextAlign.center,
                      style: context.general.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: 20.sp),
                    ),
                  ),
                  CustomTextField(
                    labelName: 'userName',
                    controller: textEditingController,
                    focusNode: focusNode,
                    requestfocusNode: focusNode1,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).requestFocus(focusNode1),
                  ),
                  Padding(
                    padding: context.padding.verticalNormal,
                    child: CustomTextField(
                      labelName: 'userpassword',
                      controller: textEditingController1,
                      focusNode: focusNode1,
                      requestfocusNode: focusNode,
                      textInputAction: TextInputAction.done, // “Done/Enter” tuşu
                      onSubmitted: (_) => loginButtonOnTap(),
                    ),
                  ),
                  Center(
                    child: AgreeButton(
                      onTap: () => loginButtonOnTap(),
                      text: "login",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
