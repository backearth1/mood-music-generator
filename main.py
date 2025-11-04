from fastapi import FastAPI, Request, Form, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, FileResponse
import requests
import json
import time
import os
import uuid
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="心情音乐生成器", version="1.0.0")

# 静态文件和模板
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

TEMP_DIR = "temp_sessions"

def generate_music_prompt_with_llm(mood: str, api_key: str) -> dict:
    """使用 LLM 根据心情生成音乐提示词和歌词"""
    url = "https://api.minimaxi.com/v1/text/chatcompletion_v2"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "MiniMax-Text-01",
        "max_tokens": 4096,
        "messages": [
            {
                "role": "system",
                "content": "你是一个专业的音乐制作人和词曲创作者，精通各种音乐风格，擅长将情感转化为音乐和歌词。"
            },
            {
                "role": "user",
                "content": f"""用户当前的心情是：{mood}

请为这个心情创作完整的音乐方案：

1. **音乐描述 (prompt)**：
   - 用中文描述，包含：音乐风格、情绪、适合的场景
   - 格式示例："流行音乐, 温暖舒适, 适合在阳光明媚的午后"
   - 要求：描述具体、情感丰富、场景感强
   - 长度：50-200字

2. **歌词 (lyrics)**：
   - 使用中文创作完整歌曲结构
   - 必须包含结构标签：[Intro], [Verse], [Chorus], [Bridge], [Outro]
   - 每个部分要有诗意和情感深度
   - 适合发朋友圈分享
   - 使用换行符分隔每行歌词
   - 长度：100-500字

请严格按照以下JSON格式返回：
{{
  "prompt": "音乐风格描述，情绪描述，场景描述",
  "lyrics": "[Intro]\\n开场歌词\\n\\n[Verse]\\n主歌歌词1\\n主歌歌词2\\n\\n[Chorus]\\n副歌歌词1\\n副歌歌词2\\n\\n[Bridge]\\n桥段歌词\\n\\n[Outro]\\n尾声歌词"
}}

注意：
- prompt 要体现音乐的氛围和情感
- lyrics 必须有完整的歌曲结构
- 歌词要押韵、有节奏感"""
            }
        ]
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code != 200:
            raise Exception(f"LLM API 调用失败: {response.status_code}")
        
        result = response.json()
        content = result["choices"][0]["message"]["content"]
        
        # 尝试解析 JSON
        try:
            # 提取 JSON 部分
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()
            
            data = json.loads(content)
            return {
                "prompt": data.get("prompt", "Emotional, melodic pop music"),
                "lyrics": data.get("lyrics", "")
            }
        except:
            # 如果解析失败，返回默认值
            return {
                "prompt": f"Emotional music expressing {mood}",
                "lyrics": content[:200] if content else ""
            }
            
    except Exception as e:
        print(f"LLM 调用错误: {str(e)}")
        return {
            "prompt": f"Emotional music expressing {mood}",
            "lyrics": f"此刻的心情\n{mood}\n愿音乐与你相伴"
        }

def generate_music(prompt: str, lyrics: str, api_key: str) -> str:
    """调用音乐生成 API"""
    url = "https://api.minimaxi.com/v1/music_generation"

    payload = {
        "model": "music-2.0",
        "prompt": prompt,
        "lyrics": lyrics,
        "audio_setting": {
            "sample_rate": 44100,
            "bitrate": 256000,
            "format": "mp3"
        }
    }

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    response = requests.post(url, headers=headers, json=payload)
    
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="音乐生成失败")
    
    result = response.json()
    
    if "data" not in result or "audio" not in result["data"]:
        raise HTTPException(status_code=400, detail="API返回数据格式错误")
    
    # 保存音频文件
    audio_hex = result["data"]["audio"]
    audio_bytes = bytes.fromhex(audio_hex)
    
    session_id = str(uuid.uuid4())
    session_dir = os.path.join(TEMP_DIR, session_id)
    os.makedirs(session_dir, exist_ok=True)
    
    timestamp = int(time.time())
    file_name = f"music_{timestamp}.mp3"
    file_path = os.path.join(session_dir, file_name)
    
    with open(file_path, "wb") as f:
        f.write(audio_bytes)
    
    return f"/download/{session_id}/{file_name}"

@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/generate")
async def generate(mood: str = Form(...), api_key: str = Form(...)):
    try:
        # 验证 API Key
        if not api_key or api_key.strip() == "":
            raise HTTPException(status_code=400, detail="请提供有效的 API Key")

        # 第一步：使用 LLM 生成音乐提示词和歌词
        music_data = generate_music_prompt_with_llm(mood, api_key)

        # 第二步：生成音乐
        file_url = generate_music(music_data["prompt"], music_data["lyrics"], api_key)

        return {
            "status": "success",
            "message": "音乐生成成功",
            "file_url": file_url,
            "prompt": music_data["prompt"],
            "lyrics": music_data["lyrics"]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/download/{session_id}/{filename}")
async def download(session_id: str, filename: str):
    file_path = os.path.join(TEMP_DIR, session_id, filename)
    if os.path.exists(file_path):
        return FileResponse(
            file_path,
            media_type="audio/mpeg",
            headers={
                "Accept-Ranges": "bytes",
                "Content-Disposition": "inline"
            }
        )
    else:
        raise HTTPException(status_code=404, detail="文件不存在")

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 5111))
    uvicorn.run(app, host="0.0.0.0", port=port)
