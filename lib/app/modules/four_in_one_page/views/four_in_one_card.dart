import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class FourInOneCard extends StatelessWidget {
  FourInOneCard({
    required this.fourInOneModel,
    super.key,
    required this.count,
  });
  final int count;
  final FourInOneModel fourInOneModel;

  @override
  Widget build(BuildContext context) {
    final textStyle = context.general.textTheme.titleMedium!;
    final fadedTextStyle = textStyle.copyWith(
      fontSize: 17.sp,
      fontWeight: FontWeight.w500,
      color: ColorConstants.greyColor,
    );

    return Padding(
      padding: EdgeInsets.only(top: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              count.toString(),
              style: textStyle.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    fourInOneModel.name,
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: fadedTextStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    fourInOneModel.notes,
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: fadedTextStyle,
                  ),
                ),
                _buildDeleteButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: IconButton(
            onPressed: () async {
              // await ExpencesService().deleteExpence(model: fourInOneModel);
              // CustomWidgets.showSnackBar("deleted", "${fourInOneModel.name} " + "Expence deleted".tr, ColorConstants.redColor);
            },
            icon: const Icon(
              IconlyLight.delete,
              color: Colors.red,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            // showDialog(
            //   context: context,
            //   builder: (context) => EditAddExpencesDialog(model: fourInOneModel),
            // );
          },
          icon: const Icon(
            IconlyLight.edit,
            color: ColorConstants.blackColor,
          ),
        ),
      ],
    );
  }
}
