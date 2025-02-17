import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bidsrwm/providers/app_state.dart';
import 'package:path/path.dart' as p;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icons/app_icon.png', width: 36, height: 36),
            const SizedBox(width: 12),
            const Text('BIDSRWM｜鲸雷铁锈汉化'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFileSelector(context),
              const SizedBox(height: 30),
              _buildProgressIndicator(context),
              const SizedBox(height: 20),
              _buildStatusDisplay(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.settings),
        label: const Text('设置'),
        onPressed: () => Navigator.pushNamed(context, '/settings'),
      ),
    );
  }

  Widget _buildFileSelector(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return AbsorbPointer(
          absorbing: state.isProcessing, // 处理期间禁用交互
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: InkWell(
              onTap: state.isProcessing ? null : () => _pickFile(context),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 48,
                      color: state.isProcessing 
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 15),
                    _buildProcessingStatus(context, state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessingStatus(BuildContext context, AppState state) {
    if (!state.isProcessing) {
      return Text(
        '点击选择模组文件 (.rwmod)',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.grey[700],
        ),
      );
    }

    return Column(
      children: [
        CircularProgressIndicator(
          value: state.progress,
          strokeWidth: 2,
        ),
        const SizedBox(height: 10),
        Text(
          _getProgressPhase(state.progress),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        if (state.currentTask.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '正在处理: ${state.currentTask}',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    if (!mounted) return;
    final currentContext = context;
    context.read<AppState>();
    
    final inputFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['rwmod'],
    );
    
    if (!mounted) return;
    if (inputFile != null) {
      _handleFileProcessing(currentContext, File(inputFile.files.single.path!));
    }
  }

  Future<void> _handleFileProcessing(BuildContext context, File file) async {
    if (!mounted) return;
    final currentContext = context;
    final state = context.read<AppState>();
    
    state.startProcessing(
      file,
      onSuccess: (processedBytes) async {
        if (!mounted) return;
        
        final result = await showDialog<bool>(
          context: currentContext,
          builder: (context) => AlertDialog(
            title: const Text('处理完成'),
            content: const Text('请选择后续操作：'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('继续翻译下一个'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('返回主页'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        
        if (result == true) {
          _pickFile(currentContext);
        } else {
          final outputPath = await _saveFile(processedBytes, file);
          if (!mounted) return;
          if (outputPath != null) {
            state.updateStatus('保存成功！路径：$outputPath');
          }
        }
      },
      onError: (e) => state.updateStatus('处理失败：$e'),
    );
  }

  Future<String?> _saveFile(Uint8List bytes, File originFile) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '保存汉化模组',
      fileName: '${p.basenameWithoutExtension(originFile.path)}_CN.rwmod',
    );
    
    if (outputPath != null) {
      await File(outputPath).writeAsBytes(bytes);
      return outputPath;
    }
    return null;
  }

  String _getProgressPhase(double progress) {
    if (progress < 0.2) return '正在解压文件...';
    if (progress < 0.8) return '正在翻译内容 (包含6类关键词)...';
    return '正在重新打包...';
  }

  void _showAboutDialog(BuildContext context) {
    // Implementation of _showAboutDialog method
  }

  Widget _buildStatusDisplay(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: state.status != null
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.status!.contains('失败') 
                    ? Colors.red[50] 
                    : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.status!.contains('失败')
                        ? Colors.red[200]!
                        : Colors.green[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.status!.contains('失败') 
                        ? Icons.error_outline 
                        : Icons.check_circle,
                      color: state.status!.contains('失败')
                          ? Colors.red
                          : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.status!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) => state.progress > 0
          ? Column(
              children: [
                LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '当前阶段: ${_getProgressPhase(state.progress)}\n'
                  '已完成: ${(state.progress * 100).toStringAsFixed(1)}%',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
} 