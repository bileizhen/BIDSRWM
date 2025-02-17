import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bidsrwm/providers/app_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '1.0.0';
  String _buildNumber = '20240801';
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/bileizhen/BIDSRWM/releases/latest'),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    final latest = jsonDecode(response.body);
    final latestVersion = latest['tag_name'].toString().replaceFirst('v', '');
    
    setState(() {
      _version = latestVersion;
      _buildNumber = latest['name'].toString().split('(')[1].split(')')[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用设置'),
        centerTitle: true,
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return _buildSettingsContent(context, state);
        },
      ),
    );
  }


  Widget _buildSettingsContent(BuildContext context, AppState state) {
    final config = state.config;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceSection(context, state, config),
          const Divider(height: 40),
          _buildAppInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context, AppState state, TranslationConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '翻译服务设置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                ),
          ),
          const SizedBox(height: 16),
          SegmentedButton(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('DeepSeek'),
                icon: Icon(Icons.auto_awesome, size: 18),
              ),
              ButtonSegment(
                value: false,
                label: Text('百度翻译'),
                icon: Icon(Icons.translate, size: 18),
              ),
            ],
            selected: {config.useDeepSeek},
            onSelectionChanged: (newSelection) {
              state.toggleService(newSelection.first);
            },
            style: const ButtonStyle(
              visualDensity: VisualDensity.comfortable,
            ),
          ),
          if (config.useDeepSeek) ...[
            const SizedBox(height: 20),
            TextFormField(
              initialValue: config.apiKey,
              decoration: InputDecoration(
                labelText: 'API 密钥',
                hintText: '输入您的DeepSeek API密钥',
                prefixIcon: const Icon(Icons.key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => state.updateApiKey(value),
            ),
            TextButton(
              onPressed: () => _launchUrl('https://platform.deepseek.com/api-keys'),
              child: const Text('如何获取API密钥？'),
            ),
          ] else ...[
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.verified_user, color: Colors.green),
              title: const Text('安全服务'),
              subtitle: const Text('由开发者提供免费翻译服务'),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showServiceInfo(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '应用信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                ),
          ),
          const SizedBox(height: 16),
          _buildVersionInfo(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl('https://your-domain.com/privacy'),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('当前版本'),
      subtitle: Text('$_version (build $_buildNumber)'),
      trailing: _checkingUpdate 
          ? const CircularProgressIndicator(strokeWidth: 2)
          : IconButton(
              icon: const Icon(Icons.update),
              onPressed: _checkUpdate,
            ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('无法打开链接: $url');
    }
  }

  void _showServiceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('翻译服务说明'),
        content: const Text(
          '百度翻译服务由开发者统一提供API密钥\n'
          '每日免费限额：50,000字符\n'
          '超额使用将自动切换至备用服务',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate() async {
    setState(() => _checkingUpdate = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/bileizhen/BIDSRWM/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      final latest = jsonDecode(response.body);
      final latestVersion = latest['tag_name'].toString().replaceFirst('v', '');
      final current = Version.parse(_version);
      final newer = Version.parse(latestVersion);
      
      if (current < newer) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('发现新版本'),
            content: Text(latest['body'] ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => _launchUrl(latest['html_url']),
                child: const Text('前往下载'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前已是最新版本')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('检查更新失败: ${e.toString()}')),
      );
    } finally {
      setState(() => _checkingUpdate = false);
    }
  }
}
