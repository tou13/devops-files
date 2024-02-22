#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

password=${1:-pass@word}
port=${2:-6379}

mkdir -p /home/volume/redis
chown -R 1000:1000 /home/volume/redis

docker run -d \
  --name redis-$USER \
  --restart unless-stopped \
  --cpus 1 \
  --memory 1024M \
  --network internalnet \
  -u 1000:1000 \
  -p $port:6379 \
  -v /home/volume/redis/data:/data \
  redis:6.2.14 \
  redis-server --requirepass "$password"

chown -R 1000:1000 /home/volume/redis

echo "redis安装成功，使用密码 $password 连接"