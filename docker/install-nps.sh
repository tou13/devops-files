#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

if [ -d "/home/volume/nps" ]; then
    echo "NPS配置已存在于/home/volume/nps，跳过安装"
    exit 0
fi

web_user=${1:-admin}
web_pass=${2:-pass@word}

mkdir -p /home/volume/nps/conf/
bash <(curl -Ls https://cdn.jsdelivr.net/gh/tou13/somefiles/linux/install-docker.sh) /home/volume/nps/conf

touch /home/volume/nps/conf/clients.json
touch /home/volume/nps/conf/hosts.json
touch /home/volume/nps/conf/tasks.json

cat <<EOF > /home/volume/nps/conf/nps.conf
appname = nps
runmode = pro

bridge_type=tcp
bridge_port=22156
bridge_ip=0.0.0.0

flow_store_interval=1
log_level=6
log_path=nps.log

web_host=
web_username=$web_user
web_password=$web_pass
web_port=22150
web_ip=0.0.0.0
web_base_url=
web_open_ssl=true
web_cert_file=conf/diy.crt
web_key_file=conf/diy.key

auth_crypt_key=$web_pass

allow_user_login=false
allow_user_register=false
allow_user_change_username=false
allow_flow_limit=true
allow_rate_limit=true
allow_tunnel_num_limit=true
allow_local_proxy=false
allow_connection_num_limit=true
allow_multi_ip=true
system_info_display=true
http_add_origin_header=true
http_cache=false
http_cache_length=100
http_add_origin_header=false

disconnect_timeout=60
open_captcha=true
tls_enable=true
EOF

docker run -d \
  --name nps-$USER \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
  -p 22150-22159:22150-22159 \
  -v /home/volume/nps/conf:/conf \
  -v /etc/localtime:/etc/localtime:ro \
  yisier1/nps:v0.27.01

echo "NPS服务端运行成功，使用ip:22150访问web后台"