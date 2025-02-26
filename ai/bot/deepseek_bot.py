from __future__ import annotations

import dataclasses
from typing import ClassVar

import httpx
from rich import print

from .base_bot import BaseBot, ChatHistoryMixin
from xiaomusic.utils import split_sentences

from azure.ai.inference import ChatCompletionsClient
from azure.core.credentials import AzureKeyCredential

#gpt-4o (version:2024-08-06)
DEPLOYMENT_NAME = "DeepSeek-R1"
API_KEY = "fDZKz5jA3B1YozrixDFi8DTAic5XcdTW6pjwepPjXwrTL3PbfndLJQQJ99BBACi0881XJ3w3AAAAACOGDwd7"
AZURE_ENDPOINT = "https://jcqin-m7cp47wm-japaneast.services.ai.azure.com/models" 
API_VERSION = "2024-05-01-preview"

@dataclasses.dataclass
class DeepSeekBot(ChatHistoryMixin, BaseBot):
    name: ClassVar[str] = "DeepSeek"
    default_options: ClassVar[dict[str, str]] = {"model": "DeepSeek-R1"}
    key: str
    api_base: str | None = None
    proxy: str | None = None
    deployment_id: str | None = None
    history: list[tuple[str, str]] = dataclasses.field(default_factory=list, init=False)

    def _make_client(self, sess: httpx.AsyncClient) -> ChatCompletionsClient:
        if self.api_base and "azure.com" in self.api_base:
            client = ChatCompletionsClient(endpoint=AZURE_ENDPOINT, credential=AzureKeyCredential(API_KEY))
            return client
        else:
            return None

    @classmethod
    def from_config(cls, config):
        return cls(
            key=config.openai_key,
            api_base=config.api_base,
            proxy=config.proxy,
            deployment_id=config.deployment_id,
        )

    async def ask(self, query, **options):
        ms = self.get_messages()
        ms.append({"role": "user", "content": f"{query}"})
        kwargs = {**self.default_options, **options}
        httpx_kwargs = {}
        if self.proxy:
            httpx_kwargs["proxies"] = self.proxy
        async with httpx.AsyncClient(trust_env=True, **httpx_kwargs) as sess:
            client = self._make_client(sess)
            try:
                completion = client.complete(
                    messages=ms,
                    temperature=0.3,  # 降低随机性，输出更直接
                    max_tokens=100,   # 限制回答长度
                    top_p=0.9,         # 限制生成多样性
                    **kwargs
                    )
            except Exception as e:
                print(str(e))
                return ""

            message = completion.choices[0].message.content
            self.add_message(query, message)
            print(message)
            return message

    async def ask_stream(self, query, **options):
        ms = self.get_messages()
        ms.append({"role": "user", "content": f"{query}"})
        kwargs = {**self.default_options, **options}
        httpx_kwargs = {}
        if self.proxy:
            httpx_kwargs["proxies"] = self.proxy
        async with httpx.AsyncClient(trust_env=True, **httpx_kwargs) as sess:
            client = self._make_client(sess)
            try:
                completion = await client.complete(
                    messages=ms, 
                    model = DEPLOYMENT_NAME,
                    temperature=0.3,  # 降低随机性，输出更直接
                    max_tokens=100,   # 限制回答长度
                    top_p=0.9,         # 限制生成多样性
                    stream=True,
                    **kwargs
                    )
            except Exception as e:
                print(str(e))
                return

            async def text_gen():
                async for event in completion:
                    if not event.choices:
                        continue
                    chunk_message = event.choices[0].delta
                    if chunk_message.content is None:
                        continue
                    print(chunk_message.content, end="")
                    yield chunk_message.content

            message = ""
            try:
                async for sentence in split_sentences(text_gen()):
                    message += sentence
                    yield sentence
            finally:
                print()
                self.add_message(query, message)
