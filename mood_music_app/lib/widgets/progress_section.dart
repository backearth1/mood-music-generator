import 'package:flutter/material.dart';
import '../models/generation_state.dart';

class ProgressSection extends StatelessWidget {
  final GenerationState state;

  const ProgressSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            '🎼 创作进度',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFf0f0f0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Step Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStepIndicator(
                '1',
                '分析心情',
                '理解情绪',
                state.step.index >= GenerationStep.analyzingMood.index,
                state.step == GenerationStep.analyzingMood,
              ),
              _buildStepIndicator(
                '2',
                '创作歌词',
                '诗意表达',
                state.step.index >= GenerationStep.generatingLyrics.index,
                state.step == GenerationStep.generatingLyrics,
              ),
              _buildStepIndicator(
                '3',
                '生成音乐',
                'AI作曲',
                state.step.index >= GenerationStep.creatingMusic.index,
                state.step == GenerationStep.creatingMusic,
              ),
              _buildStepIndicator(
                '4',
                '处理音频',
                '完成制作',
                state.step.index >= GenerationStep.processingAudio.index,
                state.step == GenerationStep.processingAudio,
              ),
            ],
          ),

          // Error Message
          if (state.hasError) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage ?? '生成失败',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success Message
          if (state.isCompleted) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '音乐创作完成！请在下方播放',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    String number,
    String label,
    String description,
    bool isCompleted,
    bool isActive,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? const Color(0xFFFF6B9D)
                  : const Color(0xFFf0f0f0),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFFF6B9D)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      number,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFFFF6B9D)
                            : const Color(0xFF999),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isCompleted || isActive
                  ? const Color(0xFF333)
                  : const Color(0xFF999),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isCompleted || isActive
                  ? const Color(0xFF666)
                  : const Color(0xFF999),
            ),
          ),
        ],
      ),
    );
  }
}
