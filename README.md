# 心情音乐生成器 🎵

基于 MiniMax AI 的心情音乐生成网站。用户输入当前心情和 API Key，系统会自动生成一首符合心情的原创音乐，包含歌词和音频，可用于发朋友圈分享。

## ✨ 功能特性

- 🎭 **智能心情分析**：使用 MiniMax LLM 理解用户心情
- 🎼 **自动音乐创作**：根据心情生成音乐风格提示词
- 📝 **歌词创作**：自动生成符合心情的诗意歌词
- 🎵 **音乐生成**：调用 MiniMax Music API 生成高质量音频
- 🔒 **前端输入 API Key**：无需配置文件，直接在网页输入
- 📥 **下载功能**：支持下载生成的音乐
- 📤 **社交分享**：一键分享到朋友圈
- 📱 **响应式设计**：完美支持手机和电脑访问

## 🚀 快速开始

### 1. 环境要求

- Python 3.8+
- MiniMax API Key（从 [MiniMax 官网](https://api.minimaxi.com) 获取）

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

1. 在浏览器中打开应用
2. **输入你的 MiniMax API Key**（在第一个输入框）
3. 在文本框中输入你当前的心情描述
4. 或点击快速选择按钮选择预设心情
5. 点击"生成我的专属音乐"按钮
6. 等待 AI 生成（通常需要 10-30 秒）
7. 播放、下载或分享你的专属音乐

## 🔑 获取 API Key

1. 访问 https://api.minimaxi.com
2. 注册账号
3. 在控制台创建 API Key
4. 确保账户有足够的余额
5. 在网页中输入 API Key 即可使用

## 🏗️ 项目结构

```
test_yiyun/
├── main.py                 # FastAPI 主应用
├── requirements.txt        # Python 依赖
├── .env                    # 环境变量配置（可选）
├── .env.example           # 环境变量示例
├── templates/             # HTML 模板
│   └── index.html        # 主页面
├── static/               # 静态资源
│   ├── css/
│   │   └── style.css    # 样式文件
│   └── js/
│       └── app.js       # 前端逻辑
└── temp_sessions/        # 临时音频文件存储
```

## 🔧 技术栈

- **后端**：FastAPI + Python
- **前端**：HTML5 + CSS3 + Vanilla JavaScript
- **AI 服务**：
  - MiniMax LLM (MiniMax-Text-01) - 心情分析和歌词生成
  - MiniMax Music API (music-2.0) - 音乐生成

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

- 渐变紫色主题设计
- 流畅的动画效果
- 现代化卡片式布局
- 移动端友好的响应式设计
- 密码输入框保护 API Key

## 🔒 安全说明

- API Key 在前端输入，不存储在服务器
- API Key 使用密码输入框类型，不会明文显示
- 生成的音乐文件临时保存在服务器
- 建议定期清理 `temp_sessions` 目录

## 📝 配置说明

### 端口配置

默认端口为 **5111**。如需修改，可以：

1. 编辑 `.env` 文件：
```
PORT=8080  # 改为你想要的端口
```

2. 或直接修改 `main.py` 第 185 行的默认值

### 修改音乐生成参数

在 `main.py` 的 `generate_music` 函数中修改：

```python
"audio_setting": {
    "sample_rate": 44100,  # 采样率
    "bitrate": 256000,     # 比特率
    "format": "mp3"        # 格式
}
```

### 修改 LLM 提示词

在 `main.py` 的 `generate_music_prompt_with_llm` 函数中修改系统提示词。

## 🐛 常见问题

### Q: API 调用失败怎么办？
A: 检查 API Key 是否正确，确认 MiniMax 账户有足够余额。

### Q: 音乐生成很慢？
A: 音乐生成通常需要 10-30 秒，这是正常现象。

### Q: 如何部署到生产环境？
A: 建议使用 Nginx + Gunicorn/Uvicorn，并添加适当的限流和缓存策略。

### Q: 端口被占用？
A: 修改 `.env` 文件中的 PORT 值，或使用 `uvicorn main:app --port 其他端口`

## 🚀 后台运行

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

## 📄 许可证

MIT License

## 🙏 致谢

- [MiniMax AI](https://api.minimaxi.com) - 提供强大的 AI 能力
- FastAPI - 现代化的 Python Web 框架
