#!/usr/bin/env bash

if command -v hysteria &> /dev/null; then
    echo "hysteria 已安装"
    exit 0
fi

port=${1:-443}
masquerade_host=${2:-maimai.sega.jp}
password=$(openssl rand -hex 16)

mkdir -p /etc/hysteria/

openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/hysteria/$masquerade_host.key -out /etc/hysteria/$masquerade_host.crt -subj "/CN=$masquerade_host" -days 36500

cat <<EOF > /etc/hysteria/config.yaml
listen: :$port

tls:
  cert: /etc/hysteria/$masquerade_host.crt
  key: /etc/hysteria/$masquerade_host.key

auth:
  type: password
  password: $password

masquerade:
  type: proxy
  proxy:
    url: https://$masquerade_host/
    rewriteHost: true
EOF

bash <(curl -fsSL https://get.hy2.sh/)

systemctl enable --now hysteria-server && \
systemctl status hysteria-server

echo "安装完成，password：$password，端口：$port。由于使用自签证书，请设置insecure为true"