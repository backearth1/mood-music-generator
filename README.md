# 心情音乐生成器 🎵

基于 MiniMax AI 的心情音乐生成应用。支持 Web 网页版和 Android 移动端，用户输入当前心情和 API Key，系统会自动生成一首符合心情的原创音乐，包含歌词和音频，可用于分享和收藏。

## 📱 快速下载 Android 应用

### 方式 1：直接下载最新版本（推荐）

访问 [Releases 页面](https://github.com/MiniMax-OpenPlatform/mood-music-generator/releases/latest) 下载最新的 APK 安装包：

- **app-arm64-v8a-release.apk** - 适用于大多数新设备（推荐）
- **app-armeabi-v7a-release.apk** - 适用于较旧的设备
- **app-x86_64-release.apk** - 适用于模拟器

### 方式 2：查看所有版本

访问 [所有 Releases](https://github.com/MiniMax-OpenPlatform/mood-music-generator/releases) 查看历史版本

### Android 安装步骤

1. 下载适合你设备的 APK 文件
2. 在手机设置中允许"安装未知来源的应用"
3. 打开下载的 APK 文件进行安装
4. 安装完成后打开应用
5. 输入 MiniMax API Key 开始使用

## ✨ 功能特性

### 共同特性
- 🎭 **智能心情分析**：使用 MiniMax LLM 理解用户心情
- 🎼 **自动音乐创作**：根据心情生成音乐风格提示词
- 📝 **歌词创作**：自动生成符合心情的诗意歌词
- 🎵 **音乐生成**：调用 MiniMax Music API 生成高质量音频
- 🔒 **前端输入 API Key**：无需配置文件，直接在界面输入
- 📥 **下载功能**：支持下载生成的音乐
- 📤 **社交分享**：一键分享你的专属音乐

### Web 版特性
- 🌐 **跨平台访问**：支持所有现代浏览器
- 📱 **响应式设计**：完美支持手机和电脑访问
- 🎨 **粉红色主题**：现代化渐变设计

### Android 版特性
- 📱 **原生体验**：流畅的移动端操作
- 🎨 **粉红色主题**：美观的渐变界面设计
- 🎵 **内置播放器**：支持暂停、进度控制
- ⚡ **快速启动**：随时随地生成音乐
- 🔄 **实时进度**：可视化创作步骤

## 🚀 Web 版快速开始

### 1. 环境要求

- Python 3.8+
- MiniMax API Key（从 [MiniMax 平台](https://platform.minimaxi.com/user-center/basic-information/interface-key) 获取）

### 2. 安装依赖

```bash
pip install -r requirements.txt
```

### 3. 运行服务

**无需配置 .env 文件**，直接启动：

```bash
python3 main.py
```

或使用启动脚本：

```bash
./start.sh
```

或使用 uvicorn（开发模式）：

```bash
uvicorn main:app --host 0.0.0.0 --port 5111 --reload
```

### 4. 访问应用

在浏览器中打开：

```
http://localhost:5111
```

如果是远程服务器：

```
http://服务器IP:5111
```

## 🎯 使用方法

### Web 版

1. 在浏览器中打开应用
2. **输入你的 MiniMax API Key**（在第一个输入框）
3. 在文本框中输入你当前的心情描述
4. 或点击快速选择按钮选择预设心情
5. 点击"生成我的专属音乐"按钮
6. 等待 AI 生成（通常需要 30-120 秒）
7. 播放、下载或分享你的专属音乐

### Android 版

1. 打开心情音乐生成器应用
2. **输入你的 MiniMax API Key**
3. 描述你的心情，或选择快捷心情标签（开心、难过、平静等）
4. 点击"🎵 生成我的音乐"按钮
5. 等待创作过程（分析心情 → 创作歌词 → 生成音乐 → 处理音频）
6. 播放、分享或重新生成

## 🔑 获取 API Key

1. 访问 [MiniMax 用户中心](https://platform.minimaxi.com/user-center/basic-information/interface-key)
2. 注册/登录账号
3. 在控制台创建 API Key
4. 确保账户有足够的余额
5. 在应用中输入 API Key 即可使用

## 🏗️ 项目结构

```
mood-music-generator/
├── main.py                     # FastAPI Web 服务
├── requirements.txt            # Python 依赖
├── templates/                  # Web 模板
│   └── index.html             # Web 主页面
├── static/                     # Web 静态资源
│   ├── css/style.css          # 样式文件
│   └── js/app.js              # 前端逻辑
├── temp_sessions/              # 临时音频文件存储
├── mood_music_app/             # Flutter Android 应用
│   ├── lib/                   # Dart 源代码
│   │   ├── main.dart          # 应用入口
│   │   ├── screens/           # 界面页面
│   │   ├── widgets/           # UI 组件
│   │   ├── services/          # API 服务
│   │   └── models/            # 数据模型
│   ├── android/               # Android 原生配置
│   ├── assets/                # 应用资源
│   └── pubspec.yaml           # Flutter 依赖配置
└── .github/workflows/          # CI/CD 自动化
    ├── build-apk.yml          # Android APK 构建
    └── build-ios.yml          # iOS IPA 构建
```

## 🔧 技术栈

### Web 版
- **后端**：FastAPI + Python
- **前端**：HTML5 + CSS3 + Vanilla JavaScript

### Android 版
- **框架**：Flutter 3.19.0
- **语言**：Dart
- **UI 库**：Material Design 3
- **网络**：Dio (HTTP Client)
- **音频**：audioplayers
- **状态管理**：Provider
- **分享**：share_plus

### AI 服务
- **MiniMax LLM** (MiniMax-Text-01) - 心情分析和歌词生成
- **MiniMax Music API** (music-2.0) - 音乐生成

## 📋 API 接口

### 生成音乐

```
POST /generate
Content-Type: multipart/form-data

参数：
- api_key: MiniMax API Key（string）
- mood: 用户心情描述（string）

响应：
{
  "status": "success",
  "message": "音乐生成成功",
  "file_url": "/download/{session_id}/{filename}",
  "prompt": "音乐风格描述",
  "lyrics": "生成的歌词"
}
```

### 下载/播放音乐

```
GET /download/{session_id}/{filename}
```

### 健康检查

```
GET /health
```

## 🎨 界面特性

### Web 版
- 粉红色渐变主题设计
- 流畅的动画效果
- 现代化卡片式布局
- 移动端友好的响应式设计
- 密码输入框保护 API Key

### Android 版
- 粉红色主题（#FF6B9D, #FFC3E1, #FFE5F1）
- Material Design 3 设计语言
- 流畅的进度指示器
- 可视化步骤展示
- 内置音频播放器

## 🔒 安全说明

- API Key 在前端输入，不存储在服务器
- API Key 使用密码输入框类型，不会明文显示
- 生成的音乐文件临时保存在服务器
- 建议定期清理 `temp_sessions` 目录
- Android 版本地存储使用 shared_preferences 加密

## 📱 Android 开发

### 本地编译 APK

```bash
cd mood_music_app
flutter pub get
flutter build apk --release --split-per-abi
```

编译后的 APK 位于：
```
mood_music_app/build/app/outputs/flutter-apk/
```

### 自动化构建

项目使用 GitHub Actions 自动构建 APK：

- **触发条件**：推送到 master 分支且修改了 `mood_music_app/` 目录
- **手动触发**：在 GitHub Actions 页面点击 "Run workflow"
- **产物**：自动创建 Release 并上传 APK 文件

查看构建状态：[GitHub Actions](https://github.com/MiniMax-OpenPlatform/mood-music-generator/actions)

## 🐛 常见问题

### Q: API 调用失败怎么办？
A: 检查 API Key 是否正确，确认 MiniMax 账户有足够余额。查看 trace_id 进行问题诊断。

### Q: 音乐生成很慢？
A: 音乐生成通常需要 30-120 秒，这是正常现象。请耐心等待。

### Q: Android 版安装失败？
A:
1. 确认下载了正确架构的 APK（推荐 arm64-v8a）
2. 在设置中允许安装未知来源的应用
3. 检查是否有足够的存储空间

### Q: 如何部署到生产环境？
A: 建议使用 Nginx + Gunicorn/Uvicorn，并添加适当的限流和缓存策略。

### Q: 端口被占用？
A: 修改 `.env` 文件中的 PORT 值，或使用 `uvicorn main:app --port 其他端口`

### Q: 如何查看 API 调用的 trace_id？
A: Android 版会在结果页面底部显示 LLM 和 Music API 的 trace_id，可用于调试和客服咨询。

## 🚀 后台运行 Web 服务

### 使用 nohup

```bash
nohup python3 main.py > app.log 2>&1 &
```

### 使用 screen

```bash
screen -S music-app
python3 main.py
# 按 Ctrl+A 然后按 D 分离会话

# 恢复会话
screen -r music-app
```

### 停止服务

```bash
# 查找进程
ps aux | grep main.py

# 停止进程
kill <进程ID>

# 或使用 pkill
pkill -f "python3 main.py"
```

## 📊 生产环境建议

1. 使用反向代理（Nginx）
2. 添加 HTTPS 支持
3. 实现速率限制（防止 API 滥用）
4. 定期清理临时文件
5. 添加日志记录
6. 使用进程管理器（systemd 或 supervisor）
7. 添加用户认证（可选）

## 🔄 持续集成/部署

项目使用 GitHub Actions 实现自动化构建：

- **Android APK**：自动构建并发布到 Releases
- **iOS IPA**：自动构建（未签名，需要手动签名）

## 📄 许可证

MIT License

## 📞 支持与反馈

<div align="center">
  <img src="Qcode.png" alt="服务支持二维码" width="200"/>
</div>
