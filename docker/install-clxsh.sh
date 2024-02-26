#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

if [ -f "/home/volume/clash/config/config.yaml" ]; then
    read -p "clash客户端配置已存在于 /home/volume/clash/config/config.yaml ，是否继续安装？(y/n): " user_input

    if [ "$user_input" = "n" ]; then
        echo "安装被用户取消"
        exit 0
    elif [ "$user_input" = "y" ]; then
        echo "继续安装..."
    else
        echo "无效输入，安装被取消"
        exit 1
    fi
fi

mkdir -p /home/volume/clash/config

wget -O /home/volume/clash/config/geoip.metadb https://mirror.ghproxy.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb

if [ ! -f "/home/volume/clash/config/config.yaml" ]; then
    cat <<EOF > /home/volume/clash/config/config.yaml
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
  freeserver:
    type: http
    url: https://api.sublink.dev/sub?target=clash&insert=false&emoji=true&list=true&tfo=false&scv=false&fdn=false&sort=false&new_name=true&url=https%3A%2F%2Fraw.githubusercontent.com%2FPawdroid%2FFree-servers%2Fmain%2Fsub
    path: ./proxyset/freeserver.yaml
    interval: 86400
    health-check:
      enable: true
      interval: 300
      url: "http://connect.rom.miui.com/generate_204"

proxy-groups:
  - name: "PROXY"
    type: url-test
    use:
      - freeserver
    url: "http://connect.rom.miui.com/generate_204"
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

  telegramcidr:
    type: http
    behavior: ipcidr
    url: "https://mirror.ghproxy.com/https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/telegramcidr.txt"
    path: ./ruleset/telegramcidr.yaml
    interval: 86400

rules:
  - GEOIP,PRIVATE,DIRECT
  - GEOIP,LAN,DIRECT
  - RULE-SET,gfw,PROXY
  - RULE-SET,telegramcidr,PROXY
  - GEOIP,CN,DIRECT
  - MATCH,MATCH
EOF
fi

chown -R 1000:1000 /home/volume/clash

docker stop clash-$USER && docker rm clash-$USER

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