import tempfile
from pathlib import Path

import edge_tts

from .base import AudioFileTTS
from xiaomusic.utils import find_key_by_partial_string


EDGE_TTS_DICT = {
    "用英语": "en-US-AriaNeural",
    "用日语": "ja-JP-NanamiNeural",
    "用法语": "fr-BE-CharlineNeural",
    "用韩语": "ko-KR-SunHiNeural",
    "用德语": "de-AT-JonasNeural",
    # add more here
}

class EdgeTTS(AudioFileTTS):
    default_voice = "zh-CN-XiaoxiaoNeural"

    async def make_audio_file(self, query: str, text: str) -> tuple[Path, float]:
        voice = (
            find_key_by_partial_string(EDGE_TTS_DICT, query)
            or self.config.tts_voice
            or self.default_voice
        )
        communicate = edge_tts.Communicate(text, voice, proxy=self.config.proxy)
        duration = 0
        with tempfile.NamedTemporaryFile(
            suffix=".mp3", mode="wb", delete=False, dir=self.dirname.name
        ) as f:
            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    f.write(chunk["data"])
                elif chunk["type"] == "WordBoundary":
                    duration = (chunk["offset"] + chunk["duration"]) / 1e7
            if duration == 0:
                raise RuntimeError(f"Failed to get tts from edge with voice={voice}")
        return (Path(f.name), duration)
