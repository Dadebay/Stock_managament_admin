import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_add.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class FourInOneCard extends StatelessWidget {
  final int count;
  final String dataKey;
  final bool isAdmin;
  final String url;
  final FourInOneModel fourInOneModel;

  FourInOneCard({
    required this.count,
    required this.dataKey,
    required this.isAdmin,
    required this.fourInOneModel,
    super.key,
    required this.url,
  });

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
          CustomWidgets.counter(count),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    fourInOneModel.name + " - " + "${fourInOneModel.quantity.toString() == 'null' ? 0 : fourInOneModel.quantity.toString()} " + " count",
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                      color: ColorConstants.blackColor,
                    ),
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
                isAdmin ? _buildActionButtons(context) : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(IconlyLight.delete, color: Colors.red),
            onPressed: () async {
              await FourInOnePageService().deleteFourInOne(model: fourInOneModel, url: url, key: dataKey);
            },
          ),
          IconButton(
            icon: const Icon(IconlyLight.editSquare, color: ColorConstants.blackColor),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddEditFourInOneDialog(
                  model: fourInOneModel,
                  name: dataKey.contains('location') ? 'location' : '',
                  url: url,
                  editKey: dataKey,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
