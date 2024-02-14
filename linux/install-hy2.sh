#!/usr/bin/env bash

if command -v hysteria &> /dev/null; then
    echo "hysteria 已安装"
    exit 0
fi

port=${1:-443}
password=$(openssl rand -hex 16)

cat <<EOF > /etc/hysteria/config.yaml
listen: :$port

tls:
  cert: /home/volume/nginx/ssl/diy.crt
  key: /home/volume/nginx/ssl/diy.key

auth:
  type: password
  password: $password

masquerade:
  type: proxy
  proxy:
    url: https://maimai.sega.jp/
    rewriteHost: true
EOF

bash <(curl -fsSL https://get.hy2.sh/)

systemctl enable --now hysteria-server && \
systemctl status hysteria-server

echo "安装完成，password：$password，端口：$port。由于使用自签证书，请设置insecure为true"