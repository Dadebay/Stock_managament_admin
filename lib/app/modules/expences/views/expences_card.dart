import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_controller.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_model.dart';
import 'package:stock_managament_admin/app/modules/expences/controllers/expences_service.dart';
import 'package:stock_managament_admin/app/modules/expences/views/edit_add_expences.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class ExpencesCard extends StatelessWidget {
  ExpencesCard({
    required this.expencesModel,
    required this.count,
    required this.topTextColumnSize,
    super.key,
  });

  final ExpencesModel expencesModel;
  final int count;
  final List<Map<String, dynamic>> topTextColumnSize;

  final ExpencesController expencesController = Get.find();

  @override
  Widget build(BuildContext context) {
    final textStyle = context.general.textTheme.titleMedium!;
    final fadedTextStyle = textStyle.copyWith(
      fontSize: 17.sp,
      fontWeight: FontWeight.w500,
      color: ColorConstants.greyColor,
    );

    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.counter(count),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._buildDynamicTextWidgets(fadedTextStyle),
                _buildDeleteButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicTextWidgets(TextStyle faded) {
    return topTextColumnSize.map<Widget>((column) {
      final flex = CustomWidgets().getFlexForSize(column['size'].toString());
      final value = _getClientFieldBySortName(column['sortName']);
      if (column['name'] == '') {
        return SizedBox.shrink();
      } else {
        return Expanded(
          flex: flex,
          child: Text(
            value ?? '',
            maxLines: 3,
            textAlign: flex == 1 ? TextAlign.center : TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: faded,
          ),
        );
      }
    }).toList();
  }

  String? _getClientFieldBySortName(String key) {
    switch (key) {
      case 'name':
        return expencesModel.name;
      case 'date':
        return expencesModel.date!;
      case 'cost':
        return expencesModel.cost.toString();
      case 'notes':
        return expencesModel.note.toString();
      default:
        return '';
    }
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: IconButton(
            onPressed: () async {
              await ExpencesService().deleteExpence(model: expencesModel);
            },
            icon: const Icon(
              IconlyLight.delete,
              color: Colors.red,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => EditAddExpencesDialog(model: expencesModel),
            );
          },
          icon: const Icon(
            IconlyLight.editSquare,
            color: ColorConstants.blackColor,
          ),
        ),
      ],
    );
  }
}
