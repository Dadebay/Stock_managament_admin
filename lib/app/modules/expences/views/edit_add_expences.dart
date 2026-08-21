import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class EditAddExpencesDialog extends StatefulWidget {
  const EditAddExpencesDialog({super.key, this.model});
  final ExpencesModel? model;
  @override
  State<EditAddExpencesDialog> createState() => _EditAddExpencesDialogState();
}

class _EditAddExpencesDialogState extends State<EditAddExpencesDialog> {
  final name = TextEditingController(),
      cost = TextEditingController(),
      note = TextEditingController(),
      date = TextEditingController();
  final nameFocus = FocusNode(),
      costFocus = FocusNode(),
      noteFocus = FocusNode();
  DateTime? picked;
  bool get edit => widget.model != null;
  bool get ru => Get.locale?.languageCode == 'ru';
  @override
  void initState() {
    super.initState();
    final m = widget.model;
    if (m != null) {
      name.text = m.name;
      cost.text = m.cost;
      note.text = m.note;
      picked = DateTime.tryParse(m.date ?? '');
      date.text = m.date ?? '';
    }
  }

  @override
  void dispose() {
    name.dispose();
    cost.dispose();
    note.dispose();
    date.dispose();
    nameFocus.dispose();
    costFocus.dispose();
    noteFocus.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final result =
        await CustomWidgets.showDateTimePickerWidget(context: context);
    if (result != null)
      setState(() {
        picked = result;
        date.text = DateFormat('yyyy-MM-dd').format(result);
      });
  }

  Future<void> save() async {
    if (name.text.trim().isEmpty) {
      nameFocus.requestFocus();
      return;
    }
    final m = ExpencesModel(
        id: widget.model?.id ?? 0,
        name: name.text.trim(),
        cost: cost.text.trim(),
        note: note.text.trim(),
        date: (picked ?? DateTime.now()).toIso8601String().substring(0, 10));
    final service = ExpencesService();
    if (edit)
      await service.editExpence(model: m, context: context);
    else
      await service.addExpence(model: m, context: context);
    final c = Get.find<ExpencesController>();
    c.totalPrice.value += double.tryParse(m.cost) ?? 0;
  }

  @override
  Widget build(BuildContext context) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
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
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(14)),
                              child: Center(
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: FittedBox(
                                          child: HugeIcon(
                                              icon: edit
                                                  ? HugeIcons
                                                      .strokeRoundedEdit02
                                                  : HugeIcons
                                                      .strokeRoundedWallet03,
                                              color: const Color(0xFFEA580C),
                                              size: 20))))),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    edit
                                        ? (ru
                                            ? 'Изменить расход'
                                            : 'Çykdaýjyny üýtget')
                                        : (ru
                                            ? 'Добавить расход'
                                            : 'Çykdaýjy goş'),
                                    style: TextStyle(
                                        color: const Color(0xFF0F172A),
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                    ru
                                        ? 'Заполните данные расхода.'
                                        : 'Çykdaýjy maglumatlaryny dolduryň.',
                                    style: TextStyle(
                                        color: const Color(0xFF64748B),
                                        fontSize: 13.sp))
                              ])),
                          IconButton(
                              onPressed: Get.back,
                              icon: const Icon(Icons.close_rounded,
                                  color: Color(0xFF94A3B8)))
                        ])),
                Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      field(ru ? 'Название расхода' : 'Çykdaýjy ady', name,
                          nameFocus, HugeIcons.strokeRoundedFile02,
                          next: costFocus),
                      const SizedBox(height: 14),
                      field(ru ? 'Сумма' : 'Jemi çykdaýjy', cost, costFocus,
                          HugeIcons.strokeRoundedWallet03,
                          keyboard: TextInputType.number, next: noteFocus),
                      const SizedBox(height: 14),
                      field(ru ? 'Дата' : 'Sene', date, null,
                          HugeIcons.strokeRoundedCalendar03,
                          readOnly: true, onTap: selectDate),
                      const SizedBox(height: 14),
                      field(ru ? 'Примечание' : 'Bellik', note, noteFocus,
                          HugeIcons.strokeRoundedNote01,
                          lines: 3),
                      const SizedBox(height: 22),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                            onPressed: Get.back,
                            child: Text(ru ? 'Отмена' : 'Ýatyr',
                                style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                            onPressed: save,
                            icon: SizedBox(
                                width: 14,
                                height: 14,
                                child: FittedBox(
                                    child: HugeIcon(
                                        icon: edit
                                            ? HugeIcons.strokeRoundedEdit02
                                            : HugeIcons.strokeRoundedAdd01,
                                        color: Colors.white,
                                        size: 20))),
                            label: Text(edit
                                ? (ru ? 'Сохранить' : 'Üýtget')
                                : (ru ? 'Добавить' : 'Goş')),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))))
                      ])
                    ]))
              ]))));
  Widget field(String label, TextEditingController c, FocusNode? focus,
          List<List<dynamic>> icon,
          {FocusNode? next,
          TextInputType? keyboard,
          bool readOnly = false,
          VoidCallback? onTap,
          int lines = 1}) =>
      TextField(
          controller: c,
          focusNode: focus,
          keyboardType: keyboard,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: lines,
          textInputAction:
              next == null ? TextInputAction.done : TextInputAction.next,
          onSubmitted: (_) => next?.requestFocus(),
          decoration: InputDecoration(
              labelText: label,
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
                      const BorderSide(color: Color(0xFFEA580C), width: 2))));
}
