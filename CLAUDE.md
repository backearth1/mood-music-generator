# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a mood-based music generation web application that uses MiniMax AI APIs. Users input their current mood, and the system generates custom music with lyrics that can be shared on social media.

**Tech Stack:**
- Backend: Python + FastAPI
- Frontend: HTML5 + CSS3 + Vanilla JavaScript
- AI Services: MiniMax LLM (text generation) + MiniMax Music API (music generation)

## Common Commands

### Development

```bash
# Install dependencies
pip install -r requirements.txt

# Start development server (with auto-reload)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Start production server
python main.py

# Or use the startup script
./start.sh
```

### Configuration

```bash
# Setup environment variables
cp .env.example .env
# Then edit .env to add your MINIMAX_API_KEY
```

## Architecture

### Request Flow

1. **User Input** → User enters mood description in frontend
2. **Mood Analysis** → Backend calls MiniMax LLM API (`generate_music_prompt_with_llm`)
   - Analyzes mood
   - Generates music style prompt (English)
   - Creates lyrics (Chinese, 4-8 lines)
3. **Music Generation** → Backend calls MiniMax Music API (`generate_music`)
   - Uses prompt and lyrics from step 2
   - Returns audio data in hex format
4. **Audio Processing** → Convert hex to binary and save as MP3
5. **Response** → Return audio URL, prompt, and lyrics to frontend
6. **Playback** → Frontend displays lyrics and plays audio with HTML5 audio player

### Key Components

**Backend (`main.py`):**
- `generate_music_prompt_with_llm()` - LLM integration for mood analysis
- `generate_music()` - Music generation API integration
- `/generate` endpoint - Main API for music generation
- `/download/{session_id}/{filename}` - Audio file serving

**Frontend:**
- `templates/index.html` - Main UI with mood input form
- `static/js/app.js` - Handles form submission, audio playback, sharing
- `static/css/style.css` - Modern gradient design with animations

### API Integration Details

**MiniMax LLM API:**
- Endpoint: `https://api.minimaxi.com/v1/text/chatcompletion_v2`
- Model: `MiniMax-Text-01`
- Auth: Bearer token in `Authorization` header
- Reference: See `/data1/devin/test_yiyun/trans.py` for example usage

**MiniMax Music API:**
- Endpoint: `https://api.minimaxi.com/v1/music_generation`
- Model: `music-2.0`
- Returns audio as hex string in `data.audio` field
- Reference: See `/data1/devin/minimax-tools/app/routes/music.py`

### File Storage

- Generated audio files stored in `temp_sessions/{session_id}/`
- Format: `music_{timestamp}.mp3`
- Files should be periodically cleaned up (not implemented yet)

## Development Notes

### Testing API Integration

Before running the app, ensure:
1. Valid MiniMax API key in `.env`
2. Sufficient API credits
3. Network access to `api.minimaxi.com`

### Error Handling

The app handles several error cases:
- Invalid/missing API key
- LLM API failures (falls back to default prompt/lyrics)
- Music API failures (returns HTTP error to frontend)
- Missing audio files (404 response)

### Frontend Features

- Quick mood selection buttons for common moods
- Real-time loading states with spinner
- Audio player with controls
- Download button for saving music
- Share functionality (uses Web Share API or clipboard fallback)

### Known Limitations

- No rate limiting implemented
- No user authentication
- Temporary files not auto-cleaned
- LLM response parsing may fail if JSON format is incorrect (has fallback)

## Customization

### Modify Music Generation Parameters

Edit `main.py`, function `generate_music()`:

```python
"audio_setting": {
    "sample_rate": 44100,  # Sample rate
    "bitrate": 256000,     # Bitrate
    "format": "mp3"        # Format (mp3/wav)
}
```

### Modify LLM Prompts

Edit `main.py`, function `generate_music_prompt_with_llm()`, in the `messages` array.

### Modify UI Themes

Edit `static/css/style.css`, change gradient colors in:
- `body` background
- `.btn-primary` background
