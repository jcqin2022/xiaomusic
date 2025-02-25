#!/usr/bin/env python3
import asyncio
import datetime

async def print_every_second():
    while True:
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print("Every second task: ", current_time)
        await asyncio.sleep(1)  # 等待1秒

async def print_every_ten_seconds():
    while True:
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print("Every 10 seconds task", current_time)
        await asyncio.sleep(10)  # 等待10秒

async def main():
    # 创建任务
    task1 = asyncio.create_task(print_every_second())
    task2 = asyncio.create_task(print_every_ten_seconds())

    # 等待任务完成，这里使用 await 等待它们运行一段时间，实际应用中可能需要其他逻辑
    await asyncio.sleep(30)  # 例如，这里等待30秒
    # 取消任务
    task1.cancel()
    task2.cancel()

# 运行事件循环
asyncio.run(main())