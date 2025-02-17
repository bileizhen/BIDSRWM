import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:bidsrwm/services/file_service.dart';
import 'dart:typed_data';

class AppState extends ChangeNotifier {
  double _progress = 0;
  String? _status;
  TranslationConfig _config = TranslationConfig();
  bool _isProcessing = false;
  String _currentTask = '';

  AppState() {
    _loadConfig().catchError((e) {
      debugPrint('配置加载失败: $e');
      _config = TranslationConfig(); // 回退到默认配置
      notifyListeners();
    });
  }

  double get progress => _progress;
  String? get status => _status;
  TranslationConfig get config => _config;
  bool get isProcessing => _isProcessing;
  String get currentTask => _currentTask;

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _config = TranslationConfig(
        apiKey: prefs.getString('apiKey') ?? '',
        useDeepSeek: prefs.getBool('useDeepSeek') ?? true,
        promptTemplate: prefs.getString('promptTemplate') ?? '专业游戏术语翻译',
      );
    } catch (e) {
      debugPrint('配置加载异常: $e');
      _config = TranslationConfig(); // 重置为默认值
    } finally {
      notifyListeners(); // 确保通知监听者
    }
  }

  void updateConfig(TranslationConfig newConfig) async {
    _config = newConfig;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', newConfig.apiKey);
    await prefs.setBool('useDeepSeek', newConfig.useDeepSeek);
    await prefs.setString('promptTemplate', newConfig.promptTemplate);
    notifyListeners();
  }

  void updateProgress(double value, String task) {
    _progress = value;
    _currentTask = task;
    notifyListeners();
  }

  void updateStatus(String message) {
    _status = message;
    notifyListeners();
  }

  Future<void> startProcessing(File file, 
      {Function(Uint8List)? onSuccess, Function(String)? onError}) async {
    _isProcessing = true;
    _currentTask = '初始化处理流程...';
    notifyListeners();

    try {
      final bytes = await ModProcessor.processMod(
        modFile: file,
        state: this,
        onProgress: (progress, task) => updateProgress(progress, task),
      );
      onSuccess?.call(bytes);
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      _isProcessing = false;
      _currentTask = '';
      notifyListeners();
    }
  }

  void updateApiKey(String newKey) async {
    _config.apiKey = newKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', newKey);
    notifyListeners();
  }

  void toggleService(bool useDeepSeek) async {
    _config.useDeepSeek = useDeepSeek;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDeepSeek', useDeepSeek);
    notifyListeners();
  }

  void toggleDebugMode(bool value) async {
    _config.debugMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('debugMode', value);
    notifyListeners();
  }
}

class TranslationConfig {
  String apiKey;
  bool useDeepSeek;
  String promptTemplate;
  bool debugMode;

  TranslationConfig({
    this.apiKey = '',
    this.useDeepSeek = true,
    this.promptTemplate = '专业游戏术语翻译',
    this.debugMode = false,
  });
} 