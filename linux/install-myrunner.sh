#!/usr/bin/env bash

if command -v myrunner &> /dev/null; then
    echo "My Runner 已安装"
    exit 0
fi

host_url=${1:-https://codeberg.org/}
host_token=${2:-}
host_name=${3:-$(hostname -f)}

if [ -z "$host_url" ] || [ -z "$host_token" ] || [ -z "$host_name" ]; then
    echo "缺少必要的参数，请使用 script.sh host_url host_token host_name 的方式传入必要参数"
    exit 1
fi

wget -O myrunner https://gitea.com/gitea/act_runner/releases/download/v0.2.6/act_runner-0.2.6-linux-amd64
chmod +x myrunner
mv myrunner /usr/local/bin/
myrunner register --no-interactive \
    --instance $(host_url) \
    --token $(host_token) \
    --name $(host_name) \
    --labels $(host_name):host

cat <<EOF > /etc/systemd/system/myrunner.service
[Unit]
After=network.target

[Service]
ExecStart=/usr/local/bin/myrunner daemon
ExecReload=/bin/kill -s HUP $MAINPID
WorkingDirectory=/root
TimeoutSec=0
RestartSec=10
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable --now myrunner
systemctl status myrunner