import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class DrawerButtonMine extends StatelessWidget {
  const DrawerButtonMine({required this.onTap, required this.index, required this.selectedIndex, required this.showIconOnly, required this.icon, required this.title});
  final bool showIconOnly;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(12),
        width: Get.size.width,
        child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), foregroundColor: Colors.white, backgroundColor: selectedIndex == index ? Colors.amber : Colors.black, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10)),
            child: showIconOnly
                ? Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Icon(
                      icon,
                      color: selectedIndex == index ? Colors.black : Colors.white,
                    ),
                  )
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Icon(
                          icon,
                          color: selectedIndex == index ? Colors.black : Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          child: Text(
                            title.tr,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: selectedIndex == index ? Colors.black : Colors.white, fontSize: 16.sp, fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  )));
  }
}
