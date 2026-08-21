import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/components/enter_add_button.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_controller.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_model.dart';
import 'package:stock_managament_admin/app/modules/user_entering_app/controllers/enter_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class EnterCard extends StatelessWidget {
  const EnterCard(
      {super.key,
      required this.client,
      required this.count,
      required this.isAdmin});
  final EnterModel client;
  final int count;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final admin = client.isSuperUser ?? false;
    return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: const Color(0xFFFFFBEB),
          onTap: () => showDialog(
              context: context, builder: (_) => EnterAddButton(model: client)),
          child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: admin
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFFE2E8F0))),
              child: Row(children: [
                Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: admin
                            ? const Color(0xFFFFF7ED)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('$count',
                        style: TextStyle(
                            color: admin
                                ? const Color(0xFFD97706)
                                : const Color(0xFF475569),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700))),
                const SizedBox(width: 14),
                _cell(client.username ?? '—', flex: 3, bold: true),
                _cell(client.password ?? '—', flex: 3),
                Expanded(
                    flex: 2,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: admin
                                    ? const Color(0xFFFFF3CD)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(admin ? 'Admin' : 'User',
                                style: TextStyle(
                                    color: admin
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF475569),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700))))),
                if (isAdmin) _actions(context),
              ])),
        ));
  }

  Widget _cell(String text, {required int flex, bool bold = false}) => Expanded(
      flex: flex,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 14.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500)));
  Widget _actions(BuildContext context) => SizedBox(
      width: 92,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _button(IconlyLight.delete, const Color(0xFFDC2626),
            const Color(0xFFFEF2F2), () async {
          final russian = Get.locale?.languageCode == 'ru';
          final ok = await ConfirmDialog.show(
              title: russian ? 'Удалить пользователя' : 'Ulanyjyny pozmak',
              message: russian
                  ? 'Подтвердите удаление этого пользователя.'
                  : 'Soňkyra dowam etmek isleseňiz, bu ulanyjyny pozuň.');
          if (ok == true) {
            await EnterService().deleteClient(id: client.id!);
            Get.find<EnterController>().deleteClient(client.id!);
          }
        }),
        const SizedBox(width: 8),
        _button(
            IconlyLight.editSquare,
            const Color(0xFF475569),
            const Color(0xFFF1F5F9),
            () => showDialog(
                context: context,
                builder: (_) => EnterAddButton(model: client))),
      ]));
  Widget _button(
          IconData icon, Color color, Color background, VoidCallback onTap) =>
      SizedBox(
          width: 34,
          height: 34,
          child: Material(
              color: background,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(9),
                  child: Icon(icon, size: 18, color: color))));
}
