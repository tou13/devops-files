#!/usr/bin/env bash

if command -v ninja &> /dev/null; then
    echo "ninja 已安装，在线更新使用 ninja update 命令"
    exit 0
fi

ninja_port=${1:-7999}

wget -O ninja.tar.gz https://github.com/gngpp/ninja/releases/download/v0.9.12/ninja-0.9.12-x86_64-unknown-linux-musl.tar.gz
tar -xvzf ninja.tar.gz
mv ./ninja /usr/local/bin/

cat <<EOF > /etc/systemd/system/ninja.service
[Unit]
Description=Reverse engineered ChatGPT proxy
Documentation=https://github.com/gngpp/ninja/blob/main/README_zh.md
After=network.target

[Service]
ExecStart=/usr/local/bin/ninja run --bind 127.0.0.1:$ninja_port --disable-webui
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable --now ninja
systemctl status ninja

echo "ninja安装成功，使用 https://host:$ninja_port 访问" 