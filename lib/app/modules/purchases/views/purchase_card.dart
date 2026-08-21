import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_model.dart';
import 'package:stock_managament_admin/app/modules/purchases/controllers/purchases_service.dart';
import 'package:stock_managament_admin/app/modules/purchases/views/purchases_product_view.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';
import 'package:stock_managament_admin/app/product/widgets/confirm_dialog.dart';

class PurchaseCard extends StatelessWidget {
  const PurchaseCard(
      {super.key,
      required this.purchasesModel,
      required this.showInProductProfil,
      required this.index,
      required this.isAdmin,
      required this.onChanged});

  final PurchasesModel purchasesModel;
  final bool showInProductProfil;
  final int index;
  final bool isAdmin;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Get.to(() => PurchasesProductsView(
                purchasesModel: purchasesModel, isAdmin: isAdmin))
            ?.then((_) => onChanged()),
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFF8FAFC),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('$index',
                  style: TextStyle(
                      color: const Color(0xFF15803D),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 14),
            _cell(purchasesModel.title, flex: 3, emphasis: true),
            _cell(purchasesModel.date, flex: 2, muted: true),
            _cell(purchasesModel.source.isEmpty ? '—' : purchasesModel.source,
                flex: 2, muted: true),
            _cell(purchasesModel.count.toString(),
                flex: 1, alignment: TextAlign.right),
            if (!showInProductProfil)
              _cell('${purchasesModel.cost} \$',
                  flex: 2, alignment: TextAlign.right, emphasis: true),
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
      TextAlign alignment = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignment,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: muted ? const Color(0xFF64748B) : const Color(0xFF0F172A),
            fontSize: (emphasis ? 14.5 : 13.5).sp,
            fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _actionButton(
          icon: IconlyLight.delete,
          color: const Color(0xFFDC2626),
          background: const Color(0xFFFEF2F2),
          onPressed: () async {
            final isRussian = Get.locale?.languageCode == 'ru';
            final confirm = await ConfirmDialog.show(
              title: isRussian ? 'Удалить покупку' : 'Satyn almany pozmak',
              message: isRussian
                  ? 'Продолжить и удалить покупку «${purchasesModel.title}»?'
                  : 'Soňkyra dowam etmek isleseňiz, «${purchasesModel.title}» satyn almasyny pozuň.',
            );
            if (confirm == true) {
              await PurchasesService().deletePurchases(id: purchasesModel.id);
              onChanged();
            }
          },
        ),
        const SizedBox(width: 8),
        _actionButton(
          icon: IconlyLight.editSquare,
          color: const Color(0xFF475569),
          background: const Color(0xFFF1F5F9),
          onPressed: () => Get.to(() => PurchasesProductsView(
                  purchasesModel: purchasesModel, isAdmin: isAdmin))
              ?.then((_) => onChanged()),
        ),
      ]),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required Color color,
      required Color background,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: onPressed,
            child: Icon(icon, color: color, size: 18)),
      ),
    );
  }
}
