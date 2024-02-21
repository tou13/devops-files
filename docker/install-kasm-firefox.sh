#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
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
  -v /home/volume/firefox/vnc:/home/kasm-user/.vnc \
  -v /home/volume/firefox/config:/home/kasm-user/.mozilla \
  kasmweb/firefox:1.14.0

server_public_ip=host
if ! command -v curl &> /dev/null; then
    server_public_ip=`curl -sSL http://ipv4.rehi.org/ip`
fi
echo "firefox远程浏览器安装成功，访问 https://$server_public_ip:$web_port ，使用账号 kasm_user / $login_pass 登入"