#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

login_pass=${1:-pass@word}
web_port=${2:-6901}

if [ -d "/home/volume/firefox/config" ]; then
    echo "Firefox配置已经存在，跳过安装"
    exit 0
fi

mkdir -p /home/volume/firefox/config
mkdir -p /home/volume/firefox/vnc
cat <<EOF > /home/volume/firefox/vnc/kasmvnc.yaml
logging:
  log_writer_name: all
  log_dest: logfile
  level: 100

user_session:
  session_type: exclusive
  new_session_disconnects_existing_exclusive_session: true
EOF

chown -R 1000:1000 /home/volume/firefox

docker run -d \
  --name firefox-$USER \
  --restart unless-stopped \
  --cpus 1 \
  --memory 1000M \
  --shm-size 512m \
  --network internalnet \
  --dns 119.29.29.29 \
  --dns 223.5.5.5 \
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
  -v /home/volume/firefox/vnc:/home/kasm-user/.vnc \
  -v /home/volume/firefox/config:/home/kasm-user/.mozilla \
  kasmweb/firefox:1.14.0

echo "firefox远程浏览器安装成功，访问 https://host:$web_port ，使用账号 kasm_user / $login_pass 登入"