import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bidsrwm/providers/app_state.dart';
import 'package:bidsrwm/pages/home_page.dart';
import 'package:bidsrwm/pages/settings_page.dart';
import 'package:bidsrwm/widgets/splash_screen.dart';

void main() {
  // 在应用启动时验证编码
  FlutterError.onError = (details) {
    if (details.exception is! String) return;
    if (details.exception.toString().contains('Invalid character')) {
      debugPrint('检测到编码异常，请检查所有文件操作是否使用UTF-8编码');
    }
  };
  
  runApp(
    ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '鲸雷铁锈汉化',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          primary: Colors.blueGrey[800],
          secondary: Colors.cyan[300],
        ),
        fontFamily: 'NotoSansSC',
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w400),
          displayMedium: TextStyle(fontWeight: FontWeight.w400),
          bodyLarge: TextStyle(fontWeight: FontWeight.w400),
          // 其他文本样式...
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
} 