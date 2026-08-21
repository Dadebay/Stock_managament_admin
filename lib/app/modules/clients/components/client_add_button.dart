import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ClientAddButton extends StatefulWidget {
  const ClientAddButton({super.key, this.model});
  final ClientModel? model;
  @override
  State<ClientAddButton> createState() => _ClientAddButtonState();
}

class _ClientAddButtonState extends State<ClientAddButton> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final nameFocus = FocusNode();
  final addressFocus = FocusNode();
  final phoneFocus = FocusNode();
  bool get isEdit => widget.model != null;
  bool get isRussian => Get.locale?.languageCode == 'ru';
  String get nameLabel => isRussian ? 'Имя клиента' : 'Müşderiniň ady';
  String get addressLabel => isRussian ? 'Адрес' : 'Öý salgyňyz';
  String get phoneLabel => isRussian ? 'Номер телефона' : 'Telefon belgisi';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.model?.name ?? '';
    addressController.text = widget.model?.address ?? '';
    phoneController.text = widget.model?.phone ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    nameFocus.dispose();
    addressFocus.dispose();
    phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      nameFocus.requestFocus();
      return;
    }
    final client = ClientModel(
        id: widget.model?.id ?? 0,
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        orderCount: widget.model?.orderCount ?? 0,
        sumPrice: widget.model?.sumPrice ?? '');
    if (isEdit)
      await ClientsService().editClients(model: client);
    else
      await ClientsService().addClient(model: client);
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
                                child: Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: FittedBox(
                                            child: HugeIcon(
                                                icon: isEdit
                                                    ? HugeIcons
                                                        .strokeRoundedEdit02
                                                    : HugeIcons
                                                        .strokeRoundedUserAdd01,
                                                color: const Color(0xFF4F46E5),
                                                size: 20))))),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      isEdit
                                          ? (isRussian
                                              ? 'Изменить клиента'
                                              : 'Müşderini üýtget')
                                          : (isRussian
                                              ? 'Добавить клиента'
                                              : 'Müşderi goş'),
                                      style: TextStyle(
                                          color: const Color(0xFF0F172A),
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(
                                      isRussian
                                          ? 'Заполните данные клиента.'
                                          : 'Müşderiniň maglumatlaryny dolduryň.',
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
                            label: nameLabel,
                            controller: nameController,
                            focus: nameFocus,
                            next: addressFocus,
                            icon: HugeIcons.strokeRoundedUser),
                        const SizedBox(height: 16),
                        _field(
                            label: addressLabel,
                            controller: addressController,
                            focus: addressFocus,
                            next: phoneFocus,
                            icon: HugeIcons.strokeRoundedHome01),
                        const SizedBox(height: 16),
                        _field(
                            label: phoneLabel,
                            controller: phoneController,
                            focus: phoneFocus,
                            icon: HugeIcons.strokeRoundedCall02,
                            keyboard: TextInputType.phone,
                            prefix: '+993'),
                        const SizedBox(height: 24),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: Get.back,
                                  child: Text(isRussian ? 'Отмена' : 'Ýatyr',
                                      style: const TextStyle(
                                          color: Color(0xFF475569),
                                          fontWeight: FontWeight.w600))),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                  onPressed: _save,
                                  icon: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: FittedBox(
                                          child: HugeIcon(
                                              icon: isEdit
                                                  ? HugeIcons
                                                      .strokeRoundedEdit02
                                                  : HugeIcons
                                                      .strokeRoundedUserAdd01,
                                              color: Colors.white,
                                              size: 20))),
                                  label: Text(isEdit
                                      ? (isRussian ? 'Сохранить' : 'Üýtget')
                                      : (isRussian ? 'Добавить' : 'Goş')),
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
          required List<List<dynamic>> icon,
          FocusNode? next,
          TextInputType? keyboard,
          String? prefix}) =>
      TextField(
          controller: controller,
          focusNode: focus,
          keyboardType: keyboard,
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
              prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: FittedBox(
                          child: HugeIcon(
                              icon: icon,
                              color: const Color(0xFF64748B),
                              size: 20)))),
              prefixIconConstraints: const BoxConstraints(
                  minWidth: 48, maxWidth: 48, minHeight: 0),
              prefixText: prefix == null ? null : '$prefix  ',
              prefixStyle:
                  const TextStyle(color: Color(0xFF64748B), fontSize: 15),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF4F46E5), width: 2))));
}
