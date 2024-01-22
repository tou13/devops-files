#!/usr/bin/env bash

if command -v ttyd &> /dev/null; then
    echo "ttyd 已安装"
    exit 0
fi

ttyd_user=${1:-admin}
ttyd_pass=${2:-pass@word}

wget -O /usr/local/sbin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 && \
chmod +x /usr/local/sbin/ttyd

bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/add-diy-https-cert.sh)

cat <<EOF > /etc/systemd/system/ttyd.service
[Unit]
Description=ttyd
After=network.target

[Service]
ExecStart=/usr/local/sbin/ttyd --writable --ipv6 --credential $ttyd_user:$ttyd_pass --port 2083 --ssl --ssl-cert /home/volume/nginx/ssl/diy.crt --ssl-key /home/volume/nginx/ssl/diy.key bash
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable --now ttyd
systemctl status ttyd

echo "ttyd安装成功，使用 https://host:2083 访问" 