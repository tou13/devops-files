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

db_host=${1:-}
db_port=${2:-3306}
db_name=${3:-dujiaoka}
db_user=${4:-dujiaoka}
db_pass=${5:-pass@word}
redis_host=${6:-}
redis_port=${7:-6379}
redis_pass=${8:-pass@word}
app_name=${9:-MyShop}
app_key=${10:-pass@word}
app_url=${11:-https://127.0.0.1}

if [ -z "$db_host" ] || [ -z "$redis_host" ] || [ -z "$app_name" ]; then
    echo "缺少必要的参数，请使用 install-dujiaoka.sh db_host db_port db_name db_user db_pass redis_host redis_port redis_pass app_name app_url app_key 的方式传入必要参数"
    exit 1
fi

mkdir -p /home/volume/dujiaoka/config/
cat <<EOF > /home/volume/dujiaoka/config/env.conf
APP_NAME=$app_name
APP_ENV=local
APP_KEY=$app_key
APP_DEBUG=false
APP_URL=$app_url
ADMIN_HTTPS=false

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=$db_host
DB_PORT=$db_port
DB_DATABASE=$db_name
DB_USERNAME=$db_user
DB_PASSWORD=$db_pass

REDIS_HOST=$redis_host
REDIS_PASSWORD=$redis_pass
REDIS_PORT=$redis_port

BROADCAST_DRIVER=log
SESSION_DRIVER=file
SESSION_LIFETIME=120

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
DUJIAO_ADMIN_LANGUAGE=zh_CN

ADMIN_ROUTE_PREFIX=/admin
EOF

chown -R 1000:1000 /home/volume/dujiaoka

docker run -d \
  --name dujiaoka-$USER \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
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