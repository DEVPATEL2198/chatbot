import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'controllers/message_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final MessageController messageController = Get.put(MessageController());

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
          title: 'AI Chat Bot',
          theme: AppTheme.themeData,
          darkTheme: AppTheme.darkThemeData,
          themeMode:
              themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const ChatScreen(),
          debugShowCheckedModeBanner: false,
        ));
  }
}
