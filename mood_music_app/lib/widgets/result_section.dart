import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../models/music_response.dart';

class ResultSection extends StatefulWidget {
  final MusicResponse response;
  final VoidCallback onReset;

  const ResultSection({
    super.key,
    required this.response,
    required this.onReset,
  });

  @override
  State<ResultSection> createState() => _ResultSectionState();
}

class _ResultSectionState extends State<ResultSection> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Listen to player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to duration
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to position
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Auto-play on init
    _playAudio();
  }

  Future<void> _playAudio() async {
    try {
      // Check if URL is a network URL or local file
      if (widget.response.audioUrl.startsWith('http://') ||
          widget.response.audioUrl.startsWith('https://')) {
        // Network URL
        await _audioPlayer.play(UrlSource(widget.response.audioUrl));
      } else {
        // Local file path
        await _audioPlayer.play(DeviceFileSource(widget.response.audioUrl));
      }
    } catch (e) {
      print('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失败: $e')),
        );
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _pauseAudio();
    } else {
      await _playAudio();
    }
  }

  Future<void> _shareMusic() async {
    try {
      // Check if it's a URL or local file
      if (widget.response.audioUrl.startsWith('http://') ||
          widget.response.audioUrl.startsWith('https://')) {
        // Share URL directly
        await Share.share(
          '我的心情音乐\n\n${widget.response.lyrics}\n\n音频链接: ${widget.response.audioUrl}',
        );
      } else {
        // Share local file
        final file = File(widget.response.audioUrl);
        if (await file.exists()) {
          await Share.shareXFiles(
            [XFile(widget.response.audioUrl)],
            text: '我的心情音乐\n\n${widget.response.lyrics}',
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('音频文件不存在')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '你的音乐已生成',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),

          // Audio Player
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF91B3)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Play/Pause Button
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 56,
                  ),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                ),

                const SizedBox(height: 8),

                // Progress Bar
                Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white24,
                      ),
                      child: Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble(),
                        value: _position.inSeconds.toDouble().clamp(
                              0,
                              _duration.inSeconds.toDouble(),
                            ),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(position);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Music Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '音乐风格',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF666),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.response.prompt,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Text(
                  '歌词',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF666),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.response.lyrics,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF000000),
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                if (widget.response.llmTraceId != null || widget.response.musicTraceId != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 6),
                  const Text(
                    'API Trace IDs',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF999),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.response.llmTraceId != null)
                    SelectableText(
                      'LLM: ${widget.response.llmTraceId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666),
                        fontFamily: 'monospace',
                      ),
                    ),
                  if (widget.response.musicTraceId != null)
                    SelectableText(
                      'Music: ${widget.response.musicTraceId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666),
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareMusic,
                  icon: const Icon(Icons.share),
                  label: const Text('分享'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新生成'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
