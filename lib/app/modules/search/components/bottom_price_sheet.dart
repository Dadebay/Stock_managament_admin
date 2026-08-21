import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class BottomPriceSheet extends StatelessWidget {
  BottomPriceSheet({
    this.productCount,
    this.stockCount,
    this.totalCost,
    this.totalSell,
    super.key,
  });
  final SearchViewController searchViewController = Get.find();
  final int? productCount;
  final int? stockCount;
  final double? totalCost;
  final double? totalSell;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            "countProducts".tr,
            (productCount ?? searchViewController.productsList.length)
                .toString(),
            Icons.inventory_2_rounded,
          ),
          _buildDivider(),
          _buildStatCard(
            "costPrice".tr,
            '${(totalCost ?? searchViewController.sumCost.value).toStringAsFixed(0)} \$',
            Icons.shopping_cart_rounded,
          ),
          _buildDivider(),
          _buildStatCard(
            "sellPrice".tr,
            '${(totalSell ?? searchViewController.sumSell.value).toStringAsFixed(0)} \$',
            Icons.attach_money_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 38.h,
      width: 1.5,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

/// Totals for whatever slice of purchases is currently on screen — the numbers
/// track the active year filter and search, not the whole data set.
class BottomPriceSheetPurchases extends StatelessWidget {
  const BottomPriceSheetPurchases({
    required this.totalCost,
    required this.purchaseCount,
    required this.productCount,
    required this.scopeLabel,
    super.key,
  });

  final double totalCost;
  final int purchaseCount;
  final int productCount;

  /// The year in view, or the translated "all years" label.
  final String scopeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF166534),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
              scopeLabel, purchaseCount.toString(), Icons.receipt_long_rounded),
          _buildDivider(),
          _buildStatCard(
              "count".tr, productCount.toString(), Icons.inventory_2_rounded),
          _buildDivider(),
          _buildStatCard("cost".tr, '${totalCost.toStringAsFixed(2)} \$',
              Icons.monetization_on_rounded),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36.h,
      width: 1.5,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class BottomPriceSheetSalesView extends StatelessWidget {
  BottomPriceSheetSalesView({super.key});
  final OrderController salesController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade300.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCardSales(
            "orderCount".tr + " x " + "count".tr,
            salesController.sumProductCount.value.toString(),
            Icons.shopping_bag_rounded,
          ),
          _buildDividerSales(),
          _buildStatCardSales(
            "cost".tr,
            '${salesController.sumCost.value.toStringAsFixed(0)} \$',
            Icons.monetization_on_rounded,
          ),
          _buildDividerSales(),
          _buildStatCardSales(
            "totalIncome".tr,
            '${salesController.sumPrice.toStringAsFixed(0)} \$',
            Icons.sell_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardSales(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDividerSales() {
    return Container(
      height: 60.h,
      width: 1.5,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
