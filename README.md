# BIDSRWM - 铁锈战争模组汉化工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.22-blue)](https://flutter.dev)
[![DeepSeek Powered](https://img.shields.io/badge/Powered%20By-DeepSeek-2B7FFF)](https://deepseek.com)
[![GitHub Release](https://img.shields.io/github/v/release/bileizhen/BIDSRWM)](https://github.com/bileizhen/BIDSRWM/releases)

专业的《铁锈战争(Rusted Warfare)》模组汉化工具，基于Flutter构建的跨平台解决方案，集成DeepSeek大模型实现上下文感知翻译。

![应用截图](assets/screenshot.png) <!-- 需要添加实际截图 -->

## 🚀 核心特性

- 🧩 智能解析模组文件结构
- 🔄 支持百度翻译/DeepSeek双引擎
- 🚤 批量处理加速（最高4文件并行）
- 📦 自动生成标准中文字段（_zh后缀）
- 📊 实时进度显示与任务追踪
- 🔍 支持7类关键字段翻译：
  ```ini
  displayText, displayName, description
  displayDescription, isLockedMessage
  text, showMessageToPlayer
  ```

## 📦 安装指南

### 环境要求
- Flutter 3.22+
- Dart 3.4+
- Android Studio / Xcode (移动端构建)
```bash
git clone https://github.com/bileizhen/BIDSRWM.git
cd BIDSRWM
flutter pub get
```
## 🛠️ 使用说明

1. **选择模组文件**
   - 支持 `.rwmod` 格式文件
   - 自动识别有效配置文件（.ini/.template）

2. **配置翻译服务**
   ```text
   设置 → 翻译服务 → 选择引擎
   ```
   - DeepSeek（需API密钥）
   - 百度翻译（内置开发者密钥）

3. **批量处理模式**
   - 连续处理多个文件
   - 自动生成 `_CN` 后缀文件

4. **输出验证**
   - 保留原始文件结构
   - 生成标准化翻译字段

## ⚙️ 配置选项

| 功能                | 说明                          |
|---------------------|-----------------------------|
| 翻译引擎切换        | DeepSeek/百度翻译实时切换       |
| API密钥管理         | 安全存储用户自定义密钥          |
| 调试模式            | 显示详细处理日志                |
| 自动更新检查        | 每日首次启动检查GitHub更新       |

## 🌐 服务说明
```dart
每日免费翻译限额：
├─ 百度翻译: 50,000 字符
└─ DeepSeek: 根据API套餐
超额自动切换备用服务
```

## 📝 注意事项
- 请妥善保管API密钥
- 支持多平台构建
- 请勿滥用API服务


## 🤝 参与贡献

欢迎通过 [GitHub Issues](https://github.com/bileizhen/BIDSRWM/issues) 提交：  
- 新字段翻译规则  
- 文件解析逻辑改进  
- 界面优化建议  

遵循 [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) 分支策略：  
```
feature/ 新功能分支
hotfix/ 紧急修复分支
release/ 版本发布分支
```

## 📄 证书协议
MIT License © 2024 bileizhen  
完整条款见 [LICENSE](LICENSE) 文件

## 📬 联系作者

| 联系方式         | 信息                         |
|------------------|-----------------------------|
| GitHub           | [@bileizhen](https://github.com/bileizhen) |
| 邮箱             | lei3140014249@163.com        |
| 问题反馈         | [提交Issue](https://github.com/bileizhen/BIDSRWM/issues) |
