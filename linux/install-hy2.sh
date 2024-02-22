#!/usr/bin/env bash

if command -v hysteria &> /dev/null; then
    echo "hysteria 已安装"
    exit 0
fi

port=${1:-443}
password=$(openssl rand -hex 16)

if ! command -v netstat &> /dev/null; then
    echo "netstat 未安装，请先安装net-tools"
    exit 1
fi

if netstat -tuln | grep -q ":$port\s"; then
    echo "端口 $port 已被占用，请更换安装参数中的端口重新安装"
    exit 1
fi

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

echo "安装完成，password：$password，端口：$port，sni: www.bing.com。由于使用自签证书，请设置insecure为true。以下是clash配置示例："

server_public_ip=填写你的服务器公网ip
if ! command -v curl &> /dev/null; then
    server_public_ip=`curl -sSL http://ipv4.rehi.org/ip`
fi

cat <<EOF
mixed-port: 7890
external-controller: 127.0.0.1:9090
allow-lan: false
mode: rule
log-level: debug
ipv6: true
dns:
  enable: true
  listen: 0.0.0.0:53
  enhanced-mode: fake-ip
  nameserver:
    - 8.8.8.8
    - 1.1.1.1
    - 114.114.114.114
proxies:
  - name: myhy2
    type: hysteria2
    server: $server_public_ip
    port: $port
    password: $password
    sni: www.bing.com
    skip-cert-verify: true
    
proxy-groups:
  - name: Proxy
    type: select
    proxies:
      - myhy2
      
rules:
  - GEOIP,CN,DIRECT
  - MATCH,Proxy
EOF
