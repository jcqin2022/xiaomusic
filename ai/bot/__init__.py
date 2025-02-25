from __future__ import annotations

from ai.bot.base_bot import BaseBot
from ai.bot.chatgptapi_bot import ChatGPTBot
from ai.bot.newbing_bot import NewBingBot
from ai.bot.glm_bot import GLMBot
from ai.bot.gemini_bot import GeminiBot
from ai.bot.qwen_bot import QwenBot
# from ai.bot.langchain_bot import LangChainBot
from xiaomusic.config import Config

BOTS: dict[str, type[BaseBot]] = {
    "newbing": NewBingBot,
    "chatgptapi": ChatGPTBot,
    "glm": GLMBot,
    "gemini": GeminiBot,
    "qwen": QwenBot,
    # "langchain": LangChainBot,
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
]
