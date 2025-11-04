# 🚀 快速启动指南

## 当前状态

✅ 项目已完全配置好
✅ 依赖已安装
✅ 服务器正在运行在端口 **5111**

## 访问应用

### 本地访问
```
http://localhost:5111
```

### 远程访问
```
http://你的服务器IP:5111
```

## 使用步骤

1. **在浏览器中打开上述地址**

2. **输入你的 MiniMax API Key**
   - 在第一个输入框中输入
   - 如果没有 API Key，点击链接去注册：https://api.minimaxi.com

3. **输入你的心情**
   - 在文本框中描述你当前的心情
   - 或点击快速选择按钮（开心、忧伤、平静等）

4. **点击"生成我的专属音乐"**
   - 等待 10-30 秒
   - AI 会分析你的心情并生成音乐

5. **享受你的音乐**
   - 在线播放
   - 下载到本地
   - 分享到朋友圈

## 服务器管理

### 查看服务器状态
```bash
# 检查进程
ps aux | grep main.py

# 查看端口占用
netstat -tlnp | grep 5111
# 或
lsof -i:5111
```

### 停止服务器
```bash
# 方法 1：找到进程 ID 并停止
ps aux | grep main.py
kill <PID>

# 方法 2：直接停止
pkill -f "python3 main.py"
```

### 重启服务器
```bash
# 停止服务
pkill -f "python3 main.py"

# 启动服务
python3 main.py &

# 或使用 nohup 后台运行
nohup python3 main.py > app.log 2>&1 &
```

### 查看日志
```bash
# 如果使用 nohup 启动
tail -f app.log

# 实时查看服务器输出
# （如果在前台运行）
```

## 故障排查

### 问题：无法访问网页
**检查：**
- 服务器是否正在运行？`ps aux | grep main.py`
- 端口是否被占用？`netstat -tlnp | grep 5111`
- 防火墙是否开放 5111 端口？

**解决：**
```bash
# 重启服务器
python3 main.py

# 检查防火墙（如果使用 ufw）
sudo ufw allow 5111

# 检查防火墙（如果使用 firewalld）
sudo firewall-cmd --add-port=5111/tcp --permanent
sudo firewall-cmd --reload
```

### 问题：API 调用失败
**检查：**
- API Key 是否正确？
- MiniMax 账户是否有余额？
- 网络是否能访问 api.minimaxi.com？

**解决：**
```bash
# 测试网络连接
curl https://api.minimaxi.com

# 检查 API Key（在浏览器中重新输入）
```

### 问题：音乐生成很慢
这是正常现象，音乐生成通常需要 10-30 秒。请耐心等待。

## 文件清理

### 清理临时音频文件
```bash
# 清理所有临时文件
rm -rf temp_sessions/*

# 清理 7 天前的文件
find temp_sessions/ -type f -mtime +7 -delete
```

## 高级配置

### 修改端口
编辑 `.env` 文件：
```bash
PORT=8080  # 改为你想要的端口
```

然后重启服务器。

### 在后台永久运行

使用 systemd（推荐）：

1. 创建服务文件：
```bash
sudo nano /etc/systemd/system/music-generator.service
```

2. 添加以下内容：
```ini
[Unit]
Description=Mood Music Generator
After=network.target

[Service]
Type=simple
User=你的用户名
WorkingDirectory=/data1/devin/test_yiyun
ExecStart=/usr/bin/python3 /data1/devin/test_yiyun/main.py
Restart=always

[Install]
WantedBy=multi-user.target
```

3. 启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl start music-generator
sudo systemctl enable music-generator  # 开机自启
sudo systemctl status music-generator  # 查看状态
```

## 技术支持

如有问题，请查看：
- README.md - 完整文档
- CLAUDE.md - 开发指南
- 或提交 Issue

---

**当前服务器已启动并运行在端口 5111！**

现在就可以访问 http://localhost:5111 开始使用了！🎵
