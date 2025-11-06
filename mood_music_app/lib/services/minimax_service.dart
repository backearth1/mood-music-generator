import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/music_response.dart';

class MinimaxService {
  static const String llmApiUrl =
      'https://api.minimaxi.com/v1/text/chatcompletion_v2';
  static const String musicApiUrl =
      'https://api.minimaxi.com/v1/music_generation';
  static const String llmModel = 'MiniMax-Text-01';
  static const String musicModel = 'music-2.0';

  final String apiKey;
  late final Dio _dio;

  MinimaxService({required this.apiKey}) {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),  // 2 minutes for music generation
    ));
  }

  /// Generate music prompt and lyrics using LLM based on user mood
  Future<Map<String, String>> generatePromptAndLyrics(String mood) async {
    try {
      final response = await _dio.post(
        llmApiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': llmModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  '你是一位专业的音乐制作人和作词人。你的任务是根据用户的心情描述，生成合适的音乐风格描述和歌词。'
                  '请严格按照以下 JSON 格式返回结果，不要包含其他内容：\n'
                  '{"prompt": "音乐风格描述", "lyrics": "歌词内容"}\n\n'
                  '要求：\n'
                  '1. prompt: 中文描述，50-200字，包含风格、情绪、场景。例如："流行音乐, 难过, 适合在下雨的晚上"\n'
                  '2. lyrics: 中文歌词，100-500字，使用\\n分隔每行。必须包含歌曲结构标签：[Intro], [Verse], [Chorus], [Bridge], [Outro]'
            },
            {
              'role': 'user',
              'content': '我现在的心情是：$mood\n\n请为我创作音乐和歌词。'
            }
          ],
          'max_tokens': 4096,
          'temperature': 0.7,
        },
      );

      // Print Trace-ID from response headers
      final llmTraceId = response.headers.value('trace-id') ??
                         response.headers.value('Trace-ID') ??
                         'N/A';
      print('LLM API Trace-ID: $llmTraceId');

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'] as String;

        // Try to parse JSON from content
        try {
          // Find JSON object in content
          final jsonStart = content.indexOf('{');
          final jsonEnd = content.lastIndexOf('}') + 1;
          if (jsonStart != -1 && jsonEnd > jsonStart) {
            final jsonStr = content.substring(jsonStart, jsonEnd);
            final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
            return {
              'prompt': parsed['prompt'] as String,
              'lyrics': parsed['lyrics'] as String,
              'llm_trace_id': llmTraceId,
            };
          }
        } catch (e) {
          print('Failed to parse LLM response as JSON: $e');
        }

        // Fallback: Use default prompt and lyrics
        return {
          'prompt': '流行音乐, 温柔, 适合在午后聆听',
          'lyrics':
              '[Intro]\n轻轻的\n微风吹过\n\n[Verse]\n心情如同云朵\n飘荡在天空\n\n[Chorus]\n让音乐带走烦恼\n让旋律治愈心灵\n\n[Bridge]\n每一个音符\n都是温柔的拥抱\n\n[Outro]\n慢慢地\n找回宁静',
          'llm_trace_id': llmTraceId,
        };
      } else {
        throw Exception(
            'LLM API failed: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error calling LLM API: $e');
      // Return default values on error
      return {
        'prompt': '流行音乐, 温柔, 适合在午后聆听',
        'lyrics':
            '[Intro]\n轻轻的\n微风吹过\n\n[Verse]\n心情如同云朵\n飘荡在天空\n\n[Chorus]\n让音乐带走烦恼\n让旋律治愈心灵\n\n[Bridge]\n每一个音符\n都是温柔的拥抱\n\n[Outro]\n慢慢地\n找回宁静',
        'llm_trace_id': 'Error: $e',
      };
    }
  }

  /// Generate music using MiniMax Music API
  /// Returns a map with 'url' and 'trace_id'
  Future<Map<String, String>> generateMusic(String prompt, String lyrics) async {
    print('=== Music API Request ===');
    print('URL: $musicApiUrl');
    print('Model: $musicModel');
    print('Prompt: $prompt');
    print('Lyrics length: ${lyrics.length} chars');
    print('========================');

    try {
      final response = await _dio.post(
        musicApiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': musicModel,
          'prompt': prompt,
          'lyrics': lyrics,
          'audio_setting': {
            'sample_rate': 44100,
            'bitrate': 256000,
            'format': 'mp3',
            'output_format': 'url',  // Return URL instead of hex data
          },
        },
      );

      // Print Trace-ID from response headers
      final musicTraceId = response.headers.value('trace-id') ??
                           response.headers.value('Trace-ID') ??
                           'N/A';
      print('Music API Trace-ID: $musicTraceId');
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Print full response for debugging
        print('Music API Response type: ${data.runtimeType}');
        print('Music API Response data keys: ${data?.keys}');

        if (data != null && data['data'] != null) {
          print('Music API data.data type: ${data['data'].runtimeType}');
          print('Music API data.data keys: ${data['data'].keys}');
          print('Music API full data.data content: ${data['data']}');
        } else {
          print('WARNING: data or data["data"] is null!');
          print('Full response: $data');
        }

        // Check for audio URL
        if (data['data'] != null && data['data']['audio_url'] != null) {
          final audioUrl = data['data']['audio_url'] as String;
          print('✅ Music API returned URL: $audioUrl');
          return {
            'url': audioUrl,
            'trace_id': musicTraceId,
          };
        } else {
          // Maybe the API returns 'audio' field instead of 'audio_url'?
          if (data['data'] != null && data['data']['audio'] != null) {
            print('⚠️ Found "audio" field instead of "audio_url"');
            final audioData = data['data']['audio'];
            print('Audio data type: ${audioData.runtimeType}');
            print('Audio data: $audioData');
          }

          throw Exception('No audio URL in response. Trace-ID: $musicTraceId. Full response: $data');
        }
      } else {
        throw Exception(
            'Music API failed: ${response.statusCode} - ${response.data}. Trace-ID: $musicTraceId');
      }
    } catch (e) {
      print('❌ Music API Error: $e');
      rethrow;
    }
  }

  /// Convert hex string to audio file and save it
  Future<String> saveAudioFile(String audioHex, String sessionId) async {
    // Convert hex to bytes
    final bytes = _hexToBytes(audioHex);

    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final sessionDir = Directory(path.join(directory.path, sessionId));
    if (!await sessionDir.exists()) {
      await sessionDir.create(recursive: true);
    }

    // Save file
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = path.join(sessionDir.path, 'music_$timestamp.mp3');
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// Helper function to convert hex string to bytes
  Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      final byteString = hex.substring(i * 2, i * 2 + 2);
      result[i] = int.parse(byteString, radix: 16);
    }
    return result;
  }

  /// Generate complete music from mood (combines all steps)
  Future<MusicResponse> generateFromMood(
    String mood,
    String sessionId, {
    Function(String)? onProgress,
  }) async {
    try {
      // Step 1: Generate prompt and lyrics
      onProgress?.call('正在分析你的心情...');
      final promptAndLyrics = await generatePromptAndLyrics(mood);
      final prompt = promptAndLyrics['prompt']!;
      final lyrics = promptAndLyrics['lyrics']!;
      final llmTraceId = promptAndLyrics['llm_trace_id'];

      // Step 2: Generate music (now returns URL directly)
      onProgress?.call('正在生成音乐...');
      final musicResult = await generateMusic(prompt, lyrics);
      final audioUrl = musicResult['url']!;
      final musicTraceId = musicResult['trace_id'];

      onProgress?.call('创作完成！');

      return MusicResponse(
        audioUrl: audioUrl,
        prompt: prompt,
        lyrics: lyrics,
        sessionId: sessionId,
        llmTraceId: llmTraceId,
        musicTraceId: musicTraceId,
      );
    } catch (e) {
      throw Exception('Failed to generate music: $e');
    }
  }
}
