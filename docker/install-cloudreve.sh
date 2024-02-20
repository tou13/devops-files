#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

client_name=${1:-default}

if [ -f "/home/volume/cloudreve/config/conf.ini" ]; then
    echo "cloudreve配置已存在于 /home/volume/cloudreve/config/conf.ini ，跳过安装"
    exit 0
fi

mkdir -p /home/volume/cloudreve/config
mkdir -p /home/volume/cloudreve/db

cat <<EOF > /home/volume/cloudreve/config/conf.ini
[Database]
DBFile = /cloudreve/db/cloudreve.db
EOF

chown -R 1000:1000 /home/volume/cloudreve

docker run -d \
  --name cloudreve-$USER \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
  --network internalnet \
  -u 1000:1000 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -p 5212:5212 \
  -v /home/volume/cloudreve/uploads:/cloudreve/uploads \
  -v /home/volume/cloudreve/avatar:/cloudreve/avatar \
  -v /home/volume/cloudreve/config:/cloudreve/config \
  -v /home/volume/cloudreve/db:/cloudreve/db \
  xavierniu/cloudreve:3.5.1

echo "cloudreve运行成功，请使用 http://host:5212 访问"