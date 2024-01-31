#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

login_pass=${1:-pass@word}
web_port=${2:-6901}

if [ -d "/home/volume/ubuntu/config" ]; then
    echo "Ubuntu配置已经存在，跳过安装"
    exit 0
fi

mkdir -p /home/volume/ubuntu/config
mkdir -p /home/volume/ubuntu/local
mkdir -p /home/volume/ubuntu/uploads
mkdir -p /home/volume/ubuntu/vnc
cat <<EOF > /home/volume/ubuntu/vnc/kasmvnc.yaml
logging:
  log_writer_name: all
  log_dest: logfile
  level: 100

user_session:
  session_type: exclusive
  new_session_disconnects_existing_exclusive_session: true
EOF

chown -R 1000:1000 /home/volume/ubuntu

docker run -d \
  --name ubuntu-$USER \
  --restart unless-stopped \
  --shm-size 1000m \
  --network internalnet \
  --dns 94.140.14.14 \
  --dns 94.140.14.15 \
  -e LANG=zh_CN.UTF-8 \
  -e LANGUAGE=zh_CN:zh \
  -e LC_ALL=zh_CN.UTF-8 \
  -e TZ=Asia/Shanghai \
  -e HTTP_PROXY= \
  -e HTTPS_PROXY= \
  -e http_proxy= \
  -e https_proxy= \
  -e VNC_PW=$login_pass \
  -p $web_port:6901 \
  -v /home/volume/ubuntu/vnc:/home/kasm-user/.vnc \
  -v /home/volume/ubuntu/config:/home/kasm-user/.config \
  -v /home/volume/ubuntu/local:/home/kasm-user/.local \
  -v /home/volume/ubuntu/uploads:/home/kasm-user/Uploads \
  kasmweb/ubuntu-jammy-desktop:1.14.0

server_public_ip=host
if ! command -v curl &> /dev/null; then
    server_public_ip=`curl -sSL http://ipv4.rehi.org/ip`
fi
echo "Ubuntu安装成功，访问 https://$server_public_ip:$web_port ，使用账号 kasm_user / $login_pass 登入"