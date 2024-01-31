#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

if [ -d "/home/volume/duplicati/data" ]; then
    echo "Duplicati配置已存在于 /home/volume/duplicati/data ，跳过安装"
    exit 0
fi

web_port=${1:-8200}

mkdir -p /home/volume/duplicati/data
chown -R 1000:1000 /home/volume/duplicati

docker run -d \
  --name duplicati-$USER \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
  --network internalnet \
  -u 1000:1000 \
  -p $web_port:8200 \
  -v /home/volume/duplicati/data:/data \
  -v /home/volume:/home/volume:ro \
  -v /tmp/duplicati_tempdata:/home/tempdata \
  duplicati/duplicati:2.0.7.1_beta_2023-05-25

echo "Duplicati服务端运行成功，请使用 http://host:$web_port 访问"