#!/usr/bin/env bash

if command -v hysteria &> /dev/null; then
    echo "hysteria 已安装"
    exit 0
fi

port=${1:-443}
password=$(openssl rand -hex 16)

mkdir -p /etc/hysteria/

openssl ecparam -genkey -name prime256v1 -out /etc/hysteria/private.key
openssl req -new -x509 -days 36500 -key /etc/hysteria/private.key -out /etc/hysteria/cert.crt -subj "/CN=www.bing.com"
chmod 777 /etc/hysteria/cert.crt
chmod 777 /etc/hysteria/private.key

cat <<EOF > /etc/hysteria/config.yaml
listen: :$port

tls:
  cert: /etc/hysteria/cert.crt
  key: /etc/hysteria/private.key

auth:
  type: password
  password: $password

masquerade:
  type: proxy
  proxy:
    url: https://maimai.sega.jp
    rewriteHost: true
EOF

bash <(curl -fsSL https://get.hy2.sh/)

systemctl enable --now hysteria-server && \
systemctl status hysteria-server

echo "安装完成，password：$password，端口：$port，sni: www.bing.com。由于使用自签证书，请设置insecure为true"
echo "-------clash配置示例---------"
echo "- name: hy2"
echo "  type: hysteria2"
echo "  server: 填写你的服务器ip"
echo "  port: $port"
echo "  password: $password"
echo "  sni: www.bing.com"
echo "  skip-cert-verify: true"