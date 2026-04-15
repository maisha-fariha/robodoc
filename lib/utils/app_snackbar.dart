import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void show(
    String title,
    String message, {
    bool isError = true,
  }) {
    final bg = isError ? const Color(0xFFB3261E) : const Color(0xFF1E6B45);
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderRadius: 12,
      backgroundColor: bg,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
