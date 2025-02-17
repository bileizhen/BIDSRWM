import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';  // 用于 md5

class TranslationService {
  static Future<String> translate(String text, String apiKey, bool useDeepSeek) async {
    if (useDeepSeek) {
      if (apiKey.isEmpty) throw Exception('请先配置DeepSeek API密钥');
      return _deepSeekTranslate(text, apiKey);
    }
    return _baiduTranslate(text); // 使用内置百度密钥
  }

  static Future<String> _deepSeekTranslate(String text, String apiKey) async {
    const systemPrompt = "你是一个专业游戏本地化翻译助手，请直接输出翻译结果，不要任何解释和修饰";
    
    try {
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': '翻译为简体中文：$text'}
          ]
        }),
      ).timeout(const Duration(seconds: 30));

      final body = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(body);
      if (response.statusCode != 200) {
        throw Exception('DeepSeek错误: ${jsonResponse['error']['message']}');
      }
      return jsonResponse['choices'][0]['message']['content'].toString().trim();
    } on TimeoutException {
      throw Exception('请求超时，请检查网络连接');
    } on http.ClientException catch (e) {
      throw Exception('网络错误: ${e.message}');
    }
  }

  static Future<String> _baiduTranslate(String text) async {
    const appId = '20240724002106972';
    const appSecret = 'zjRiPSMbG0qzXf3QFBbR';
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final sign = md5.convert(utf8.encode('$appId$text$salt$appSecret')).toString();

    try {
      final response = await http.post(
        Uri.parse('https://api.fanyi.baidu.com/api/trans/vip/translate'),
        body: {
          'q': text,
          'from': 'en',
          'to': 'zh',
          'appid': appId,
          'salt': salt,
          'sign': sign
        },
      );

      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error_code'] != null) {
        throw Exception('百度错误 ${jsonResponse['error_code']}: ${jsonResponse['error_msg']}');
      }
      return jsonResponse['trans_result'][0]['dst'];
    } on FormatException {
      throw Exception('无效的API响应格式');
    }
  }

  static Future<List<String>> translateBatch(List<String> texts, String apiKey, bool useDeepSeek) async {
    if (useDeepSeek) {
      return _deepSeekTranslateBatch(texts, apiKey);
    }
    return _baiduTranslateBatch(texts);
  }

  static Future<List<String>> _deepSeekTranslateBatch(List<String> texts, String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/v1/batch_translate'),
        headers: {'Authorization': 'Bearer $apiKey'},
        body: jsonEncode({'texts': texts}),
      );
      
      final jsonResponse = jsonDecode(response.body);
      return (jsonResponse['translations'] as List).cast<String>();
      
    } catch (e) {
      throw Exception('批量翻译失败: ${e.toString()}');
    }
  }

  static Future<List<String>> _baiduTranslateBatch(List<String> texts) async {
    // 暂时使用单个翻译API模拟批量翻译
    final results = <String>[];
    for (final text in texts) {
      results.add(await _baiduTranslate(text));
      await Future.delayed(const Duration(milliseconds: 100)); // 避免请求过快
    }
    return results;
  }
}