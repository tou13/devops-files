#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

if [ -f "/home/volume/frp/config/frpc.ini" ]; then
    echo "FRP客户端配置已存在于 /home/volume/frp/config/frpc.ini ，跳过安装"
    exit 0
fi

mkdir -p /home/volume/frp/config
touch /home/volume/frp/config/frpc.ini

chown -R 1000:1000 /home/volume/frp

docker run -d \
  --name frpc-$USER \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
  --network internalnet \
  -v /home/volume/frp/config/frpc.ini:/frp/frpc.ini \
  stilleshan/frpc:0.51.3

echo "FRP客户端运行成功，请修改 /home/volume/frp/config/frpc.ini 配置文件后，使用 docker restart frpc-$USER 命令重启服务"