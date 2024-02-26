#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

is_install=false

if [ -f "/home/volume/dujiaoka/config/dujiaoka.conf" ]; then
    read -p "独角数卡配置已存在于 /home/volume/dujiaoka/config/env.conf ，是否继续安装？(y/n): " user_input

    if [ "$user_input" = "n" ]; then
        echo "安装被用户取消"
        exit 0
    elif [ "$user_input" = "y" ]; then
        echo "继续安装..."
        is_install=true
    else
        echo "无效输入，安装被取消"
        exit 1
    fi
fi

mkdir -p /home/volume/dujiaoka/config/

if [ ! -f "/home/volume/dujiaoka/config/env.conf" ]; then
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
fi

if [ ! -f "/home/volume/dujiaoka/config/usdt.conf" ]; then
    cat <<EOF > /home/volume/dujiaoka/config/usdt.conf
app_name=epusdt
app_uri=https://upay.dujiaoka.com
app_debug=false
http_listen=:8000
static_path=/static
runtime_root_path=/runtime
log_save_path=/logs
log_max_size=32
log_max_age=7
max_backups=3
mysql_host=127.0.0.1
mysql_port=3306
mysql_user=mysql账号
mysql_passwd=mysql密码
mysql_database=数据库
mysql_table_prefix=
mysql_max_idle_conns=10
mysql_max_open_conns=100
mysql_max_life_time=6
redis_host=127.0.0.1
redis_port=6379
redis_passwd=
redis_db=5
redis_pool_size=5
redis_max_retries=3
redis_idle_timeout=1000
queue_concurrency=10
queue_level_critical=6
queue_level_default=3
queue_level_low=1
tg_bot_token=
tg_proxy=
tg_manage=
api_auth_token=
order_expiration_time=10
forced_usdt_rate=
EOF
fi

chown -R 1000:1000 /home/volume/dujiaoka

docker stop dujiaoka-$USER && docker rm dujiaoka-$USER

docker run -d \
  --name dujiaoka-$USER \
  --restart unless-stopped \
  --cpus 1 \
  --memory 1024M \
  --network internalnet \
  -e INSTALL=$is_install \
  -p 127.0.0.1:56789:80 \
  -v /home/volume/dujiaoka/config/dujiaoka.conf:/dujiaoka/.env \
  -v /home/volume/dujiaoka/uploads:/dujiaoka/public/uploads \
  -v /home/volume/dujiaoka/storage:/dujiaoka/storage \
  ghcr.io/apocalypsor/dujiaoka:latest

docker stop epusdt-$USER && docker rm epusdt-$USER

docker run -d \
  --name epusdt-$USER \
  --restart unless-stopped \
  --cpus 1 \
  --memory 1024M \
  --network internalnet \
  -e INSTALL=$is_install \
  -p 127.0.0.1:51293:8000 \
  -v /home/volume/dujiaoka/config/epusdt.conf:/usdt/.env \
  ghcr.io/apocalypsor/dujiaoka:usdt

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

以下是epusdt的配置：
location ^~ /
{
    proxy_pass http://127.0.0.1:51293;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header REMOTE-HOST \$remote_addr;
    proxy_set_header X-Forwarded-Proto  \$scheme;
}
EOF