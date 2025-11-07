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
                  '你是音乐制作人。根据用户心情，生成音乐风格和歌词。'
                  '请严格按照 JSON 格式返回：\n'
                  '{"prompt": "音乐风格描述", "lyrics": "歌词内容"}\n\n'
                  '要求：\n'
                  '1. prompt: 30-60字，用逗号分隔。必须包含：曲风（如爵士/流行/摇滚）、人声类型（男声/女声）、乐器（如钢琴/吉他）、情绪、氛围。例如："爵士,男声,钢琴伴奏,忧郁,深夜酒吧"\n'
                  '2. lyrics: 80-150字。结构完整但精炼，使用\\n分隔。必须包含：[Intro], [Verse], [Pre-Chorus], [Chorus], [Outro]。每个部分2-4行即可'
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
          'prompt': '流行,女声,吉他伴奏,温柔,午后阳光',
          'lyrics':
              '[Intro]\n轻轻的\n微风吹过\n[Verse]\n心情如云朵\n飘荡在天空\n[Chorus]\n音乐带走烦恼\n旋律治愈心灵\n[Outro]\n慢慢地\n找回宁静',
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
        'prompt': '流行,女声,吉他伴奏,温柔,午后阳光',
        'lyrics':
            '[Intro]\n轻轻的\n微风吹过\n[Verse]\n心情如云朵\n飘荡在天空\n[Chorus]\n音乐带走烦恼\n旋律治愈心灵\n[Outro]\n慢慢地\n找回宁静',
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
          },
          'output_format': 'url',  // Top-level parameter, not inside audio_setting
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Get trace_id from response body (not headers!)
        final musicTraceId = data['trace_id'] ?? 'N/A';
        print('Music API Trace-ID: $musicTraceId');
        print('Response Status Code: ${response.statusCode}');

        // Print full response for debugging
        print('Music API Response type: ${data.runtimeType}');
        print('Music API Response data keys: ${data?.keys}');

        if (data != null && data['data'] != null) {
          print('Music API data.data type: ${data['data'].runtimeType}');
          print('Music API data.data keys: ${data['data'].keys}');
          print('Music API data.data content: ${data['data']}');
        } else {
          print('WARNING: data or data["data"] is null!');
          print('Full response: $data');
        }

        // Check for audio URL (correct field name is 'audio', not 'audio_url')
        if (data['data'] != null && data['data']['audio'] != null) {
          final audioUrl = data['data']['audio'] as String;
          print('✅ Music API returned URL: $audioUrl');

          // Also log status
          final status = data['data']['status'];
          print('Music generation status: $status');

          return {
            'url': audioUrl,
            'trace_id': musicTraceId,
          };
        } else {
          throw Exception('No audio URL in response. Trace-ID: $musicTraceId. Full response: $data');
        }
      } else {
        // Get trace_id even on error
        final data = response.data;
        final musicTraceId = data?['trace_id'] ?? 'N/A';
        throw Exception(
            'Music API failed: ${response.statusCode} - ${response.data}. Trace-ID: $musicTraceId');
      }
    } catch (e) {
      print('❌ Music API Error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        print('⚠️ Network or timeout issue - check internet connection');
      }
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
