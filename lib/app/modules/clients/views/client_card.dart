import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/clients/components/client_add_button.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/client_model.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_controller.dart';
import 'package:stock_managament_admin/app/modules/clients/controllers/clients_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class ClientCard extends StatelessWidget {
  const ClientCard(
      {super.key,
      required this.client,
      required this.count,
      required this.isAdmin,
      required this.onChanged});
  final ClientModel client;
  final int count;
  final bool isAdmin;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: const Color(0xFFF8FAFC),
          onTap: () => showDialog(
                  context: context, builder: (_) => ClientAddButton(model: client))
              .then((_) => onChanged()),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCEBFF))),
            child: Row(children: [
              Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('$count',
                      style: TextStyle(
                          color: const Color(0xFF2563EB),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700))),
              const SizedBox(width: 14),
              _cell(client.name.isEmpty ? '—' : client.name,
                  flex: 3, emphasis: true),
              _cell(client.address.isEmpty ? '—' : client.address,
                  flex: 3, muted: true),
              _cell(client.phone, flex: 2),
              _cell((client.orderCount ?? 0).toString(),
                  flex: 1, alignment: TextAlign.right),
              _cell('${client.sumPrice ?? '0'} \$',
                  flex: 2, emphasis: true, alignment: TextAlign.right),
              if (isAdmin) _actions(context),
            ]),
          ),
        ),
      );

  Widget _cell(String text,
          {required int flex,
          bool emphasis = false,
          bool muted = false,
          TextAlign alignment = TextAlign.left}) =>
      Expanded(
          flex: flex,
          child: Text(text,
              textAlign: alignment,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color:
                      muted ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontSize: (emphasis ? 14.5 : 13.5).sp,
                  fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500)));

  Widget _actions(BuildContext context) => SizedBox(
      width: 92,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _button(
            icon: IconlyLight.delete,
            color: const Color(0xFFDC2626),
            background: const Color(0xFFFEF2F2),
            onTap: () async {
              final russian = Get.locale?.languageCode == 'ru';
              final confirmed = await ConfirmDialog.show(
                  title: russian ? 'Удалить клиента' : 'Müşderini pozmak',
                  message: russian
                      ? 'Подтвердите удаление этого клиента.'
                      : 'Soňkyra dowam etmek isleseňiz, bu müşderini pozuň.');
              if (confirmed == true) {
                await ClientsService().deleteClient(id: client.id!);
                Get.find<ClientsController>().deleteClient(client.id!);
                CustomWidgets.showSnackBar('deleted'.tr,
                    '${client.name} ${'clientDeleted'.tr}', Colors.red);
                onChanged();
              }
            }),
        const SizedBox(width: 8),
        _button(
            icon: IconlyLight.editSquare,
            color: const Color(0xFF475569),
            background: const Color(0xFFF1F5F9),
            onTap: () => showDialog(
                    context: context,
                    builder: (_) => ClientAddButton(model: client))
                .then((_) => onChanged())),
      ]));

  Widget _button(
          {required IconData icon,
          required Color color,
          required Color background,
          required VoidCallback onTap}) =>
      SizedBox(
          width: 34,
          height: 34,
          child: Material(
              color: background,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(9),
                  child: Icon(icon, color: color, size: 18))));
}
