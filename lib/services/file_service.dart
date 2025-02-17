import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:bidsrwm/services/translation_service.dart';
import 'package:bidsrwm/providers/app_state.dart';

class ModProcessor {
  static Future<Uint8List> processMod({
    required File modFile,
    required AppState state,
    required void Function(double progress, String task) onProgress,
  }) async {
    final tempDir = await _unpackMod(modFile);
    onProgress(0.1, '正在解压文件...');
    
    final iniFiles = await _findIniFiles(tempDir);
    onProgress(0.2, '找到${iniFiles.length}个配置文件');


    // 并行处理文件
    await Future.wait(
      iniFiles.map((file) => _processIniFile(file, state.config.apiKey, state.config.useDeepSeek)),
      eagerError: true,
    );

    onProgress(0.9, '正在重新打包...');
    final archive = await _repackMod(tempDir, modFile);
    
    final archiveBytes = ZipEncoder().encode(archive)!;
    await tempDir.delete(recursive: true);
    return Uint8List.fromList(archiveBytes);
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
    final translationBuffer = <String>[];
    
    for (var line in lines) {
      output.add(line);
      
      final match = RegExp(
        r'^(displayText|displayName|description|displayDescription|isLockedMessage|text|showMessageToPlayer):\s*(.+)$'
      ).firstMatch(line);
      if (match != null) {
        translationBuffer.add(match.group(2)!);
      }
    }

    // 批量翻译
    final translated = await TranslationService.translateBatch(translationBuffer, apiKey, useDeepSeek);
    
    // 重新遍历插入翻译结果
    var transIndex = 0;
    for (var line in lines) {
      if (RegExp(r'^(displayText|displayName|description):').hasMatch(line)) {
        output.insert(output.indexOf(line) + 1, '${_getKey(line)}_zh: ${translated[transIndex++]}');
      }
    }
    
    await file.writeAsString(output.join('\n'));
  }

  static String _getKey(String line) => '${line.split(':').first.trim()}_zh';

  static Future<Archive> _repackMod(Directory dir, File originalFile) async {
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
    return archive;
  }
} 