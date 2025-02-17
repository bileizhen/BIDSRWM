import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 添加资源预加载验证
    precacheImage(const AssetImage('assets/icons/app_icon.png'), context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    });

    return Scaffold(
      body: FutureBuilder(
        future: _checkResources(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error!);
          }
          return _buildMainView();
        },
      ),
    );
  }

  Future<void> _checkResources() async {
    try {
      await rootBundle.load('assets/icons/app_icon.png');
    } catch (e) {
      throw Exception('启动图标加载失败: $e');
    }
  }

  Widget _buildErrorView(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text('资源加载错误: $error', style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/translation_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/app_icon.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            const Text(
              '鲸雷铁锈汉化',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              '正在初始化...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 