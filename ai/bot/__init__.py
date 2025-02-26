from __future__ import annotations

from .base_bot import BaseBot
from .chatgptapi_bot import ChatGPTBot
from .newbing_bot import NewBingBot
from .glm_bot import GLMBot
from .gemini_bot import GeminiBot
from .qwen_bot import QwenBot
from .deepseek_bot import DeepSeekBot
# from ai.bot.langchain_bot import LangChainBot
from xiaomusic.config import Config

BOTS: dict[str, type[BaseBot]] = {
    "newbing": NewBingBot,
    "chatgptapi": ChatGPTBot,
    "glm": GLMBot,
    "gemini": GeminiBot,
    "qwen": QwenBot,
    # "langchain": LangChainBot,
    "deepseek": DeepSeekBot,
}


def get_bot(config: Config) -> BaseBot:
    try:
        return BOTS[config.bot].from_config(config)
    except KeyError:
        raise ValueError(f"Unsupported bot {config.bot}, must be one of {list(BOTS)}")


__all__ = [
    "ChatGPTBot",
    "NewBingBot",
    "GLMBot",
    "GeminiBot",
    "QwenBot",
    "get_bot",
    "LangChainBot",
    "DeepSeekBot",
]
