import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_model.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/controllers/four_in_one_page_service.dart';
import 'package:stock_managament_admin/app/modules/four_in_one_page/views/four_in_one_add.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class FourInOneCard extends StatelessWidget {
  final int count;
  final String dataKey;
  final String url;
  final FourInOneModel fourInOneModel;

  FourInOneCard({
    required this.count,
    required this.dataKey,
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
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(IconlyLight.delete, color: Colors.red),
          onPressed: () async {
            await FourInOnePageService().deleteFourInOne(model: fourInOneModel, url: url, key: dataKey);
          },
        ),
        IconButton(
          icon: const Icon(IconlyLight.edit, color: ColorConstants.blackColor),
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
    );
  }
}
