#!/usr/bin/env python3
"""测试配置是否正确"""

import os
import sys
from dotenv import load_dotenv

def test_setup():
    print("🔍 检查项目配置...\n")
    
    # 检查 .env 文件
    if not os.path.exists(".env"):
        print("❌ 未找到 .env 文件")
        print("   请运行: cp .env.example .env")
        print("   然后编辑 .env 文件，添加你的 MINIMAX_API_KEY")
        return False
    else:
        print("✅ .env 文件存在")
    
    # 加载环境变量
    load_dotenv()
    api_key = os.getenv("MINIMAX_API_KEY", "")
    
    if not api_key or api_key == "your_minimax_api_key_here":
        print("❌ MINIMAX_API_KEY 未配置或使用默认值")
        print("   请在 .env 文件中设置正确的 API Key")
        return False
    else:
        print(f"✅ MINIMAX_API_KEY 已配置 ({api_key[:10]}...)")
    
    # 检查依赖
    try:
        import fastapi
        import uvicorn
        import requests
        print("✅ 所有 Python 依赖已安装")
    except ImportError as e:
        print(f"❌ 缺少依赖: {e}")
        print("   请运行: pip install -r requirements.txt")
        return False
    
    # 检查目录
    if not os.path.exists("temp_sessions"):
        os.makedirs("temp_sessions")
        print("✅ 创建 temp_sessions 目录")
    else:
        print("✅ temp_sessions 目录存在")
    
    print("\n🎉 配置检查完成！")
    print("\n📝 下一步:")
    print("   运行: python main.py")
    print("   或者: ./start.sh")
    print("   然后访问: http://localhost:8000")
    
    return True

if __name__ == "__main__":
    success = test_setup()
    sys.exit(0 if success else 1)
