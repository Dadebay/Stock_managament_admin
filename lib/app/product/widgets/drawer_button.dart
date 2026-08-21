import 'package:get/get.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class DrawerButtonMine extends StatelessWidget {
  const DrawerButtonMine(
      {required this.onTap,
      required this.index,
      required this.selectedIndex,
      required this.showIconOnly,
      required this.icon,
      required this.title,
      this.isDanger = false,
      super.key});
  final bool showIconOnly;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final bool isDanger;

  static const Color accent = Color(0xFFFFC400);
  static const Color _dangerColor = Color(0xFFF87171);
  static const Color _idleColor = Color(0xFF94A3B8);
  static const Color _selectedSurface = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = !isDanger && selectedIndex == index;
    final Color activeColor = isDanger ? _dangerColor : accent;
    final Color foreground = isSelected || isDanger ? activeColor : _idleColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected ? _selectedSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 11,
                    bottom: 11,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: showIconOnly
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: showIconOnly ? 0 : 16),
                      child: Icon(icon, color: foreground, size: 19),
                    ),
                    if (!showIconOnly) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title.tr,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: foreground,
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small uppercase caption that groups the drawer items into sections.
/// Collapses to a short rule when the rail is in icon-only mode.
class NavSectionLabel extends StatelessWidget {
  const NavSectionLabel(
      {required this.title, required this.showIconOnly, super.key});

  final String title;
  final bool showIconOnly;

  @override
  Widget build(BuildContext context) {
    if (showIconOnly) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
        child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        title.tr.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF64748B),
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, required this.showIconOnly});

  final bool showIconOnly;

  @override
  Widget build(BuildContext context) {
    final bool isTurkmen = Get.locale?.languageCode != 'ru';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Material(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Get.updateLocale(
              isTurkmen ? const Locale('ru', 'RU') : const Locale('tm', 'TM')),
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          child: SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: showIconOnly
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: showIconOnly ? 0 : 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                        isTurkmen
                            ? 'assets/image/tm.png'
                            : 'assets/image/ru.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover),
                  ),
                ),
                if (!showIconOnly) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isTurkmen ? 'Türkmen dili' : 'Rus dili',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
