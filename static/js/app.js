document.addEventListener("DOMContentLoaded", function() {
    const moodForm = document.getElementById("moodForm");
    const apiKeyInput = document.getElementById("apiKey");
    const moodInput = document.getElementById("mood");
    const generateBtn = document.getElementById("generateBtn");
    const btnText = generateBtn.querySelector(".btn-text");
    const btnLoading = generateBtn.querySelector(".btn-loading");
    const resultSection = document.getElementById("resultSection");
    const errorSection = document.getElementById("errorSection");
    const audioPlayer = document.getElementById("audioPlayer");
    const audioSource = document.getElementById("audioSource");
    const musicPrompt = document.getElementById("musicPrompt");
    const musicLyrics = document.getElementById("musicLyrics");
    const downloadBtn = document.getElementById("downloadBtn");
    const shareBtn = document.getElementById("shareBtn");
    const regenerateBtn = document.getElementById("regenerateBtn");
    const retryBtn = document.getElementById("retryBtn");
    const errorMessage = document.getElementById("errorMessage");
    const moodTags = document.querySelectorAll(".mood-tag");

    let currentMusicData = null;
    const progressSection = document.getElementById("progressSection");
    const progressFill = document.getElementById("progressFill");
    const progressMessage = document.getElementById("progressMessage");
    const loadingText = document.getElementById("loadingText");

    // 进度控制函数
    function updateProgress(step, message) {
        // 更新进度条
        const progress = (step / 4) * 100;
        progressFill.style.width = progress + "%";

        // 更新消息
        progressMessage.textContent = message;
        loadingText.textContent = message;

        // 更新步骤状态
        for (let i = 1; i <= 4; i++) {
            const stepElement = document.getElementById("step" + i);
            stepElement.classList.remove("active", "completed");

            if (i < step) {
                stepElement.classList.add("completed");
            } else if (i === step) {
                stepElement.classList.add("active");
            }
        }
    }

    function showProgress() {
        progressSection.style.display = "block";
        progressSection.scrollIntoView({ behavior: "smooth", block: "center" });
        updateProgress(1, "正在分析你的心情...");
    }

    function hideProgress() {
        progressSection.style.display = "none";
        progressFill.style.width = "0%";
    }

    // 快速选择心情
    moodTags.forEach(tag => {
        tag.addEventListener("click", function() {
            moodInput.value = this.getAttribute("data-mood");
            moodInput.focus();
        });
    });

    // 提交表单生成音乐
    moodForm.addEventListener("submit", async function(e) {
        e.preventDefault();

        const apiKey = apiKeyInput.value.trim();
        const mood = moodInput.value.trim();

        if (!apiKey) {
            alert("请输入你的 API Key");
            apiKeyInput.focus();
            return;
        }

        if (!mood) {
            alert("请输入你的心情");
            moodInput.focus();
            return;
        }

        // 显示加载状态和进度
        generateBtn.disabled = true;
        btnText.style.display = "none";
        btnLoading.style.display = "inline-block";
        resultSection.style.display = "none";
        errorSection.style.display = "none";
        showProgress();

        try {
            // 步骤 1: 开始分析
            updateProgress(1, "正在分析你的心情...");
            await new Promise(resolve => setTimeout(resolve, 500));

            // 步骤 2: 生成歌词
            updateProgress(2, "正在生成歌词...");

            const formData = new FormData();
            formData.append("api_key", apiKey);
            formData.append("mood", mood);

            const startTime = Date.now();
            const response = await fetch("/generate", {
                method: "POST",
                body: formData
            });

            // 步骤 3: 创作音乐
            const elapsed = Date.now() - startTime;
            if (elapsed < 2000) {
                await new Promise(resolve => setTimeout(resolve, 2000 - elapsed));
            }
            updateProgress(3, "正在创作音乐...");

            const data = await response.json();

            if (response.ok && data.status === "success") {
                // 步骤 4: 处理音频
                updateProgress(4, "正在处理音频...");
                await new Promise(resolve => setTimeout(resolve, 1000));

                // 保存音乐数据
                currentMusicData = data;

                // 显示结果
                musicPrompt.textContent = data.prompt;
                musicLyrics.textContent = data.lyrics;
                audioSource.src = data.file_url;
                audioPlayer.load();
                downloadBtn.href = data.file_url;

                // 完成
                updateProgress(4, "✨ 创作完成！");
                await new Promise(resolve => setTimeout(resolve, 800));

                hideProgress();
                resultSection.style.display = "block";

                // 滚动到结果区域
                resultSection.scrollIntoView({ behavior: "smooth", block: "start" });

            } else {
                throw new Error(data.detail || "生成失败");
            }

        } catch (error) {
            console.error("Error:", error);
            hideProgress();
            errorMessage.textContent = error.message || "网络错误，请稍后重试";
            errorSection.style.display = "block";
            errorSection.scrollIntoView({ behavior: "smooth", block: "start" });
        } finally {
            // 恢复按钮状态
            generateBtn.disabled = false;
            btnText.style.display = "inline-block";
            btnLoading.style.display = "none";
        }
    });

    // 分享到朋友圈
    shareBtn.addEventListener("click", function() {
        if (!currentMusicData) return;

        const shareText = `🎵 用音乐表达我的心情\n\n${currentMusicData.lyrics}\n\n由 AI 为我创作的专属音乐 ✨`;
        
        // 尝试使用 Web Share API
        if (navigator.share) {
            navigator.share({
                title: "我的心情音乐",
                text: shareText,
            }).then(() => {
                console.log("分享成功");
            }).catch((error) => {
                console.log("分享取消", error);
                fallbackShare(shareText);
            });
        } else {
            fallbackShare(shareText);
        }
    });

    function fallbackShare(text) {
        // 复制到剪贴板
        const textarea = document.createElement("textarea");
        textarea.value = text;
        textarea.style.position = "fixed";
        textarea.style.opacity = "0";
        document.body.appendChild(textarea);
        textarea.select();
        
        try {
            document.execCommand("copy");
            alert("分享文案已复制到剪贴板！\n\n你可以将音乐下载后，粘贴文案到朋友圈分享。");
        } catch (err) {
            alert("复制失败，请手动复制歌词分享");
        }
        
        document.body.removeChild(textarea);
    }

    // 重新生成
    regenerateBtn.addEventListener("click", function() {
        resultSection.style.display = "none";
        window.scrollTo({ top: 0, behavior: "smooth" });
        moodInput.focus();
    });

    // 重试
    retryBtn.addEventListener("click", function() {
        errorSection.style.display = "none";
        moodForm.dispatchEvent(new Event("submit"));
    });
});
