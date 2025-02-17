## BIDSRWM - 铁锈战争模组翻译工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.22-blue)](https://flutter.dev)
[![DeepSeek Powered](https://img.shields.io/badge/Powered%20By-DeepSeek-2B7FFF)](https://deepseek.com)

专业的《铁锈战争(Rusted Warfare)》模组汉化工具，基于DeepSeek大模型实现高质量翻译。

## 🎮 支持特性
- 自动解析mod文件结构
- 保留原版JSON/XML格式
- 上下文关联翻译
- 术语表一致性维护
- 批量处理多个模组

## 🔧 技术栈
- Flutter 3.22 (跨平台支持)
- DeepSeek API (默认翻译引擎)
- JSON解析引擎
- ZIP压缩处理

## ✨ 主要功能
- 一键式模组文件处理
- 支持百度翻译/DeepSeek双引擎
- 智能配置文件解析
- 自动生成中文语言包
- 实时翻译进度显示

## 📦 安装步骤


```bash
git clone https://github.com/bileizhen/BIDSRWM.git
cd BIDSRWM
flutter pub get
```

## 🚀 使用方法
1. 打开应用选择.rwmod模组文件
2. 选择翻译服务（需要DeepSeek API密钥）
3. 等待处理完成
4. 保存生成的汉化模组

## ⚙️ 配置说明
在`设置`页面可以：
- 切换翻译服务提供商
- 设置API密钥
- 开启调试模式
- 查看版本更新

## 🤝 参与贡献
欢迎提交Pull Request，请遵循以下步骤：
1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/新功能`)
3. 提交修改 (`git commit -am '添加新功能'`)
4. 推送分支 (`git push origin feature/新功能`)
5. 发起Pull Request

## 📄 许可证
MIT License - 详情见 [LICENSE](LICENSE) 文件

## 📬 联系方式
作者：bileizhen  
邮箱：lei3140014249@163.com
问题反馈：https://github.com/bileizhen/BIDSRWM/issues
