import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class EnterAddButton extends StatefulWidget {
  const EnterAddButton({super.key, this.model});
  final EnterModel? model;
  @override
  State<EnterAddButton> createState() => _EnterAddButtonState();
}

class _EnterAddButtonState extends State<EnterAddButton> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameFocus = FocusNode();
  final passwordFocus = FocusNode();
  bool isSuperUser = false;
  bool obscurePassword = true;
  bool get isEdit => widget.model != null;
  bool get isRussian => Get.locale?.languageCode == 'ru';
  String get passwordLabel => isRussian ? 'Пароль' : 'Parol';
  String get superUserLabel =>
      isRussian ? 'Супер пользователь' : 'Super ulanyjy';
  String get superUserHint => isRussian
      ? 'Полный доступ ко всем разделам'
      : 'Ähli bölümlere doly rugsat';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.model?.username ?? '';
    passwordController.text = widget.model?.password ?? '';
    isSuperUser = widget.model?.isSuperUser ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    nameFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      nameFocus.requestFocus();
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      passwordFocus.requestFocus();
      return;
    }
    final user = EnterModel(
        id: widget.model?.id ?? 0,
        username: nameController.text.trim(),
        password: passwordController.text,
        isSuperUser: isSuperUser);
    if (isEdit)
      await EnterService().editClients(model: user);
    else
      await EnterService().addClient(model: user);
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 22, 16, 22),
                      color: const Color(0xFFF8FAFC),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(14)),
                                child: Icon(
                                    isEdit
                                        ? IconlyLight.editSquare
                                        : IconlyLight.addUser,
                                    color: const Color(0xFF4F46E5),
                                    size: 22)),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      (isEdit ? 'editClient' : 'add_client').tr,
                                      style: TextStyle(
                                          color: const Color(0xFF0F172A),
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(
                                      (isEdit
                                              ? 'editClientSubtitle'
                                              : 'addClientSubtitle')
                                          .tr,
                                      style: TextStyle(
                                          color: const Color(0xFF64748B),
                                          fontSize: 13.sp)),
                                ])),
                            IconButton(
                                onPressed: Get.back,
                                splashRadius: 20,
                                icon: const Icon(Icons.close_rounded,
                                    color: Color(0xFF94A3B8))),
                          ])),
                  Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        _field(
                            label: 'client_name'.tr,
                            controller: nameController,
                            focus: nameFocus,
                            icon: IconlyLight.profile,
                            next: passwordFocus),
                        const SizedBox(height: 16),
                        _field(
                            label: passwordLabel,
                            controller: passwordController,
                            focus: passwordFocus,
                            icon: IconlyLight.lock,
                            obscure: obscurePassword,
                            onSuffix: () => setState(
                                () => obscurePassword = !obscurePassword)),
                        const SizedBox(height: 16),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(IconlyLight.shieldDone,
                                      color: Color(0xFF4F46E5), size: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(superUserLabel,
                                        style: TextStyle(
                                            color: const Color(0xFF0F172A),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700)),
                                    Text(superUserHint,
                                        style: TextStyle(
                                            color: const Color(0xFF64748B),
                                            fontSize: 12.sp))
                                  ])),
                              Switch(
                                  value: isSuperUser,
                                  activeThumbColor: const Color(0xFF4F46E5),
                                  onChanged: (value) =>
                                      setState(() => isSuperUser = value)),
                            ])),
                        const SizedBox(height: 24),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: Get.back,
                                  child: Text('cancel'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF475569),
                                          fontWeight: FontWeight.w600))),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                  onPressed: _save,
                                  icon: HugeIcon(
                                      icon: isEdit
                                          ? HugeIcons.strokeRoundedEdit02
                                          : HugeIcons.strokeRoundedUserAdd01,
                                      color: Colors.white,
                                      size: 14),
                                  label: Text(
                                      (isEdit ? 'editClient' : 'add_client')
                                          .tr),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)))),
                            ]),
                      ])),
                ]))),
      );

  Widget _field(
          {required String label,
          required TextEditingController controller,
          required FocusNode focus,
          required IconData icon,
          FocusNode? next,
          bool obscure = false,
          VoidCallback? onSuffix}) =>
      TextField(
          controller: controller,
          focusNode: focus,
          obscureText: obscure,
          textInputAction:
              next == null ? TextInputAction.done : TextInputAction.next,
          onSubmitted: (_) => next?.requestFocus(),
          style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 15.sp,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xFF64748B)),
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
              suffixIcon: onSuffix == null
                  ? null
                  : IconButton(
                      onPressed: onSuffix,
                      icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF64748B),
                          size: 20)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2))));
}
