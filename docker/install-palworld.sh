#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

if [ -d "/home/volume/palworld/saved" ]; then
    echo "幻兽帕鲁palworld配置已存在于 /home/volume/palworld ，跳过安装。如需重新安装，请删除此目录后再次运行。"
    exit 0
fi

server_name=${1:-mypalworld}
admin_pass=${2:-pass@word}

mkdir -p /home/volume/palworld/saved
chown -R 1000:1000 /home/volume/palworld

docker run -d \
  --name palworld-$USER \
  --restart unless-stopped \
  --cpus 8 \
  --memory 16384M \
  --network internalnet \
  -e SERVER_NAME=$server_name \ 
  -e SERVER_DESC=$server_name \ 
  -e ADMIN_PASSWORD=$admin_pass \ 
  -p 8211:8211/udp \
  -v /etc/localtime:/etc/localtime:ro \
  -v /home/volume/palworld/saved:/opt/palworld/Pal/Saved \
  kagurazakanyaa/palworld:latest

echo "幻兽帕鲁palworld联机服务器 $server_name 部署成功，管理密码 $admin_pass 。"
echo "启动游戏后选择加入多人游戏（专用服务器），输入 服务器公网IP:8211 加入服务器进行游戏。"