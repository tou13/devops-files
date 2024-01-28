#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "请先安装docker。"
    exit 1
fi

if [ -f "/home/volume/clash/config/config.json" ]; then
    echo "clash客户端配置已存在于 /home/volume/clash/config/config.json ，跳过安装"
    exit 0
fi

mkdir -p /home/volume/clash/config

cat <<EOF > /home/volume/clash/config/config.json
port: 7890
socks-port: 7891
allow-lan: true
mode: Rule
log-level: info
ipv6: true
dns:
  enable: true
  listen: 0.0.0.0:53
  ipv6: true
  default-nameserver:
    - 119.29.29.29
    - 223.5.5.5
  nameserver:
    - 94.140.14.14
    - 94.140.14.15
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - "*.lan"
    - "*.localdomain"
    - "*.example"
    - "*.invalid"
    - "*.localhost"
    - "*.test"
    - "*.local"
    - "*.home.arpa"
    - router.asus.com
    - localhost.sec.qq.com
    - localhost.ptlogin2.qq.com
    - "+.msftconnecttest.com"

proxies:
  - name: "HELLO"
    type: vmess
    server: 127.0.0.1
    port: 443
    uuid: 12345678-1234-1234-1234-123456789012
    alterId: 0
    cipher: auto
    tls: false

proxy-providers:
  myairport:
    type: http
    url: https://api.sublink.dev/sub?target=clash&insert=false&emoji=true&list=true&tfo=false&scv=false&fdn=false&sort=false&new_name=true&url=https%3A%2F%2Fraw.githubusercontent.com%2FPawdroid%2FFree-servers%2Fmain%2Fsub
    path: ./proxyset/myairport.yaml
    interval: 86400
    health-check:
      enable: true
      interval: 300
      url: https://www.gstatic.com/generate_204

proxy-groups:
  - name: "PROXY"
    type: url-test
    use:
      - myairport
    url: "http://www.gstatic.com/generate_204"
    interval: 1800

  - name: "MATCH"
    type: select
    proxies:
      - DIRECT
      - PROXY

rule-providers:
  gfw:
    type: http
    behavior: domain
    url: "https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/gfw.txt"
    path: ./ruleset/gfw.yaml
    interval: 86400

rules:
  - GEOIP,PRIVATE,DIRECT
  - GEOIP,LAN,DIRECT
  - RULE-SET,gfw,PROXY
  - GEOIP,CN,DIRECT
  - MATCH,MATCH
EOF

chown -R 1000:1000 /home/volume/clash

docker run -d \
  --name clash-$USER \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
  --network internalnet \
  -p 7890:7890 \
  -p 7891:7891 \
  -v /home/volume/clash/config:/root/.config/clash \
  metacubex/clash-meta:v1.16.0

echo "安装成功，使用 http://127.0.0.1:7890 或 socks5://127.0.0.1:7891 代理"