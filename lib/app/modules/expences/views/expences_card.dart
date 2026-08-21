import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_service.dart';
import 'package:stock_managament_admin/app/modules/expences/views/edit_add_expences.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class ExpencesCard extends StatelessWidget {
  const ExpencesCard(
      {super.key,
      required this.expencesModel,
      required this.count,
      required this.isAdmin});

  final ExpencesModel expencesModel;
  final int count;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFFFFBEB),
        onTap: () => showDialog(
            context: context,
            builder: (_) => EditAddExpencesDialog(model: expencesModel)),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE7C2))),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$count',
                    style: TextStyle(
                        color: const Color(0xFFC2410C),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700))),
            const SizedBox(width: 14),
            _cell(expencesModel.name, flex: 3, emphasis: true),
            _cell(expencesModel.date ?? '—', flex: 2, muted: true),
            _cell('${expencesModel.cost} \$',
                flex: 2, alignment: TextAlign.right, emphasis: true),
            _cell(expencesModel.note.isEmpty ? '—' : expencesModel.note,
                flex: 4, muted: true),
            if (isAdmin) _actions(context),
          ]),
        ),
      ),
    );
  }

  Widget _cell(String text,
          {required int flex,
          bool emphasis = false,
          bool muted = false,
          TextAlign alignment = TextAlign.left}) =>
      Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(text,
              textAlign: alignment,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color:
                      muted ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontSize: (emphasis ? 14.5 : 13.5).sp,
                  fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500)),
        ),
      );

  Widget _actions(BuildContext context) => SizedBox(
        width: 92,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _action(
              icon: IconlyLight.delete,
              color: const Color(0xFFDC2626),
              background: const Color(0xFFFEF2F2),
              onTap: () async {
                final russian = Get.locale?.languageCode == 'ru';
                final confirmed = await ConfirmDialog.show(
                    title: russian ? 'Удалить расход' : 'Çykdaýjyny pozmak',
                    message: russian
                        ? 'Подтвердите удаление этого расхода.'
                        : 'Soňkyra dowam etmek isleseňiz, bu çykdaýjyny pozuň.');
                if (confirmed == true) {
                  await ExpencesService().deleteExpence(model: expencesModel);
                  final controller = Get.find<ExpencesController>();
                  controller.totalPrice.value -=
                      double.tryParse(expencesModel.cost) ?? 0;
                }
              }),
          const SizedBox(width: 8),
          _action(
              icon: IconlyLight.editSquare,
              color: const Color(0xFF475569),
              background: const Color(0xFFF1F5F9),
              onTap: () => showDialog(
                  context: context,
                  builder: (_) => EditAddExpencesDialog(model: expencesModel))),
        ]),
      );

  Widget _action(
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
