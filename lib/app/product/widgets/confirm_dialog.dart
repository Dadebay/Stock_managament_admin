import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class ConfirmDialog {
  static Future<bool?> show(
      {required String title,
      required String message,
      String? confirmText,
      String? cancelText,
      Color? confirmColor}) {
    final color = confirmColor ?? const Color(0xFFDC2626);
    final isRussian = Get.locale?.languageCode == 'ru';
    final warning = isRussian
        ? 'Это действие нельзя отменить.'
        : 'Bu hereketi yzyna gaýtaryp bolmaz.';
    return Get.dialog<bool>(
      Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: Builder(
          builder: (dialogContext) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                  color: const Color(0xFFF8FAFC),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: color.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: FittedBox(
                                        child: HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedDelete02,
                                            color: color,
                                            size: 20))))),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(title,
                                  style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(warning,
                                  style: const TextStyle(
                                      color: Color(0xFF64748B), fontSize: 13)),
                            ])),
                        IconButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF94A3B8)),
                            splashRadius: 20),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(message,
                            style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 14,
                                height: 1.45)),
                        const SizedBox(height: 24),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: Text(
                                      cancelText ?? (isRussian ? 'Нет' : 'Ýok'),
                                      style: const TextStyle(
                                          color: Color(0xFF475569),
                                          fontWeight: FontWeight.w600))),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  icon: SizedBox(
                                      width: 13,
                                      height: 13,
                                      child: FittedBox(
                                          child: HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedDelete02,
                                              color: Colors.white,
                                              size: 20))),
                                  label: Text(confirmText ??
                                      (isRussian ? 'Да' : 'Hawa')),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: color,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 13),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)))),
                            ]),
                      ]),
                ),
              ]),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
