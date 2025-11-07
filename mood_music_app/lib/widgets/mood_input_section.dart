import 'package:flutter/material.dart';

class MoodInputSection extends StatelessWidget {
  final TextEditingController moodController;
  final TextEditingController apiKeyController;
  final List<String> quickMoods;
  final Function(String) onQuickMoodSelected;
  final VoidCallback onGenerate;
  final bool isLoading;

  const MoodInputSection({
    super.key,
    required this.moodController,
    required this.apiKeyController,
    required this.quickMoods,
    required this.onQuickMoodSelected,
    required this.onGenerate,
    required this.isLoading,
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
          // API Key Input
          const Text(
            'MiniMax API Key',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: apiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '请输入你的 MiniMax API Key',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFddd)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
            ),
          ),
          const SizedBox(height: 8),
          const SelectableText(
            '没有 API Key？请访问:\nhttps://platform.minimaxi.com/user-center/basic-information/interface-key',
            style: TextStyle(fontSize: 11, color: Color(0xFF000000), height: 1.4),
          ),

          const SizedBox(height: 20),

          // Mood Input
          const Text(
            '描述你的心情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: moodController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '例如：今天阳光明媚，心情很愉快...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFddd)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Mood Buttons
          const Text(
            '或选择快捷心情:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickMoods.map((mood) {
              return InkWell(
                onTap: () => onQuickMoodSelected(mood),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: moodController.text == mood
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B9D), Color(0xFFFF91B3)],
                          )
                        : null,
                    color: moodController.text == mood
                        ? null
                        : const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: moodController.text == mood
                          ? const Color(0xFFFF6B9D)
                          : const Color(0xFFCCCCCC),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    mood,
                    style: TextStyle(
                      color: moodController.text == mood
                          ? Colors.white
                          : const Color(0xFF333333),
                      fontSize: 14,
                      fontWeight: moodController.text == mood
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Generate Button
          ElevatedButton(
            onPressed: isLoading ? null : onGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '生成我的音乐',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
