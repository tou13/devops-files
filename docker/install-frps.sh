#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

if [ -f "/home/volume/frp/config/frps.ini" ]; then
    echo "FRP服务端配置已存在于 /home/volume/frp/config/frps.ini ，跳过安装"
    exit 0
fi

server_token=${1:-pass@word}
server_port=${2:-7000}
https_port=${3:-443}
range_port_start=${4:-20000}
range_port_end=${5:-30000}

server_public_ip=服务器公网IP
if ! command -v curl &> /dev/null; then
    server_public_ip=`curl -sSL http://ipv4.rehi.org/ip`
fi

mkdir -p /home/volume/frp/config

cat <<EOF > /home/volume/frp/config/frps.ini
[common]
bind_port = $server_port
kcp_bind_port = $server_port
vhost_https_port = $https_port
tls_enable = true
token = $server_token
allow_ports = $range_port_start-$range_port_end
EOF

chown -R 1000:1000 /home/volume/frp

docker run -d \
  --name frps-$USER \
  --restart unless-stopped \
  --cpus 0.5 \
  --memory 512M \
  --network internalnet \
  -p $server_port:$server_port \
  -p $https_port:$https_port \
  -p $range_port_start-$range_port_end:$range_port_start-$range_port_end \
  -v /home/volume/frp/config/frps.ini:/frp/frps.ini \
  stilleshan/frps:0.51.3

echo "FRP服务端运行成功。客户端配置示例如下："
cat << EOF
[common]
server_addr = $server_public_ip
server_port = $server_port
tls_enable = true
token = $server_token

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = $range_port_start
use_compression = true

[https-example.com]
type = https
custom_domains = example.com
use_compression = true
plugin = https2http
plugin_local_addr = 127.0.0.1:10000
plugin_host_header_rewrite = 127.0.0.1
plugin_header_X-From-Where = frp
plugin_crt_path = /frp/ssl/diy.crt
plugin_key_path = /frp/ssl/diy.key
EOF