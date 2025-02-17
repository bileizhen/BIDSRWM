import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:bidsrwm/services/translation_service.dart';
import 'package:bidsrwm/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModProcessor {
  static Future<String> processMod({
    required File modFile,
    required BuildContext context,
    required void Function(double progress, String task) onProgress,
  }) async {
    final tempDir = await _unpackMod(modFile);
    onProgress(0.1, '正在解压文件...');
    
    final iniFiles = await _findIniFiles(tempDir);
    onProgress(0.2, '找到${iniFiles.length}个配置文件');

    final state = Provider.of<AppState>(context, listen: false);
    final total = iniFiles.length;
    double progress = 0;

    for (int i = 0; i < iniFiles.length; i++) {
      onProgress(0.2 + (i/total)*0.6, '处理文件: ${p.basename(iniFiles[i].path)}');
      await _processIniFile(iniFiles[i], state.config.apiKey, state.config.useDeepSeek);
      progress = (i + 1) / total;
      onProgress(0.2 + progress*0.6, '已处理 ${i+1}/$total 个文件');
    }

    onProgress(0.9, '正在重新打包...');
    final outputFile = await _repackMod(tempDir, modFile);
    
    return outputFile.path;
  }

  static Future<Directory> _unpackMod(File modFile) async {
    final tempDir = await Directory.systemTemp.createTemp();
    final bytes = await modFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    
    for (final file in archive) {
      if (file.isFile) {
        final outputFile = File(p.join(tempDir.path, file.name));
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(file.content as List<int>);
      }
    }
    return tempDir;
  }

  static Future<List<File>> _findIniFiles(Directory dir) async {
    return dir.list(recursive: true)
      .where((f) => f is File && (p.extension(f.path) == '.ini' || p.extension(f.path) == '.template'))
      .cast<File>()
      .toList();
  }

  static Future<void> _processIniFile(File file, String apiKey, bool useDeepSeek) async {
    final lines = await file.readAsLines(encoding: utf8);
    final output = <String>[];
    
    for (var line in lines) {
      output.add(line);
      
      // 匹配需要翻译的键
      final textMatch = RegExp(r'^(displayText|showQuickWarLogToPlayer|displayName):\s*(.+)$').firstMatch(line);
      if (textMatch != null) {
        final key = textMatch.group(1)!;
        final original = textMatch.group(2)!;
        final cleanText = _preprocessText(original);
        final translated = await _translateWithRetry(cleanText, apiKey, useDeepSeek);
        output.add('${key}_zh: $translated');
        continue;
      }
      
      // 匹配描述类字段
      final descMatch = RegExp(r'^(description|displayDescription):\s*(.+)$').firstMatch(line);
      if (descMatch != null) {
        final key = descMatch.group(1)!;
        final original = descMatch.group(2)!;
        final cleanText = _preprocessText(original);
        final translated = await _translateWithRetry(cleanText, apiKey, useDeepSeek);
        output.add('${key}_zh: $translated');
      }
    }
    
    await file.writeAsString(output.join('\n'), encoding: utf8);
  }

  static String _preprocessText(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
        .replaceAll(RegExp(r'[<>{}]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
        
    return cleaned.substring(0, cleaned.length.clamp(0, 2000));
  }

  static Future<String> _translateWithRetry(String text, String apiKey, bool useDeepSeek) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        return await TranslationService.translate(text, apiKey, useDeepSeek);
      } catch (e) {
        if (e.toString().contains('20005')) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('翻译失败: 达到最大重试次数');
  }

  static Future<File> _repackMod(Directory dir, File originalFile) async {
    final archive = Archive();
    await for (var file in dir.list(recursive: true)) {
      if (file is File) {
        final data = await file.readAsBytes();
        archive.addFile(ArchiveFile(
          p.relative(file.path, from: dir.path),
          data.length,
          data,
        ));
      }
    }
    final bytes = Uint8List.fromList(ZipEncoder().encode(archive)!);
    return File.fromRawPath(bytes);
  }
} 