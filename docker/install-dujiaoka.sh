#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

if [ -f "/home/volume/dujiaoka/config/env.conf" ]; then
    echo "独角数卡配置已存在于 /home/volume/dujiaoka/config/env.conf ，跳过安装"
    exit 0
fi

mkdir -p /home/volume/dujiaoka/config/
cat <<EOF > /home/volume/dujiaoka/config/env.conf
APP_NAME=独角数卡
APP_ENV=local
APP_KEY=base64:hDVkYhfkUjaePiaI1tcBT7G8bh2A8RQxwWIGkq7BO18=
APP_DEBUG=true
APP_URL=http://dujiaoka.test
LOG_CHANNEL=stack
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=
REDIS_PORT=6379
BROADCAST_DRIVER=log
SESSION_DRIVER=file
SESSION_LIFETIME=120
CACHE_DRIVER=file
QUEUE_CONNECTION=redis
DUJIAO_ADMIN_LANGUAGE=zh_CN
ADMIN_ROUTE_PREFIX=/admin
EOF

chown -R 1000:1000 /home/volume/dujiaoka

docker run -d \
  --name dujiaoka-$USER \
  --restart unless-stopped \
  --cpus 1 \
  --memory 1024M \
  --network internalnet \
  -p 127.0.0.1:56789:80 \
  -v /home/volume/dujiaoka/config/env.conf:/dujiaoka/.env \
  -v /home/volume/dujiaoka/uploads:/dujiaoka/public/uploads \
  -v /home/volume/dujiaoka/storage:/dujiaoka/storage \
  ghcr.io/apocalypsor/dujiaoka:latest

chown -R 1000:1000 /home/volume/dujiaoka

echo "独角数卡安装成功，请使用nginx反代，nginx配置示例如下："
cat <<EOF
location ^~ /
{
    proxy_pass http://127.0.0.1:56789;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header REMOTE-HOST \$remote_addr;
    proxy_set_header X-Forwarded-Proto  \$scheme;

    add_header X-Cache \$upstream_cache_status;

    proxy_set_header Accept-Encoding "";
    sub_filter "http://" "https://";
    sub_filter_once off;
}
EOF