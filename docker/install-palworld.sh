#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

if [ -d "/home/volume/palworld/saved" ]; then
    echo "幻兽帕鲁palworld配置已存在于 /home/volume/palworld ，跳过安装。如需重新安装，请删除此目录后再次运行。"
    exit 0
fi

mkdir -p /home/volume/palworld/saved
chown -R 1000:1000 /home/volume/palworld

docker run -d \
  --name palworld-$USER \
  --restart unless-stopped \
  --cpus 8 \
  --memory 16384M \
  --network internalnet \
  -p 8211:8211/udp \
  -v /home/volume/palworld/saved:/opt/palworld/Pal/Saved \
  kagurazakanyaa/palworld:latest

echo "幻兽帕鲁palworld联机服务器部署成功，启动游戏后选择加入多人游戏（专用服务器），输入 公网IP:8211 加入服务器进行游戏"