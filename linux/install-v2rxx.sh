#!/usr/bin/env bash

if command -v v2ray &> /dev/null; then
    echo "v2ray 已安装"
    exit 0
fi

domain=${1:-}
port=${2:-443}

if [ -z "$domain" ]; then
    echo "缺少域名参数"
    exit 1
fi

uuid=$(openssl rand -hex 16)
uuid2=${uuid:0:8}-${uuid:8:4}-${uuid:12:4}-${uuid:16:4}-${uuid:20:12}
mkdir -p /usr/local/etc/v2ray
cat <<EOF > /usr/local/etc/v2ray/config.json
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "block"
            },
            {
                "type": "field",
                "inboundTag": ["my-in-tag"],
                "outboundTag": "my-out-tag"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": 10080,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$uuid2",
                        "alterId": 0
                    }
                ],
                "disableInsecureEncryption": false
            },
            "streamSettings": {
                "network": "ws",
                "sniffing": {
                        "enabled": true,
                        "destOverride": [
                                "http",
                                "tls"
                        ]
                }
            }
        },
        {
            "listen": "127.0.0.1",
            "port": 10081,
            "protocol": "shadowsocks",
            "settings": {
                "method": "chacha20-ietf-poly1305",
                "password": "$uuid",
                "ota": true
            }
        },
        {
            "tag": "my-in-tag",
            "listen": "127.0.0.1",
            "port": 10082,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$uuid2",
                        "alterId": 0
                    }
                ],
                "disableInsecureEncryption": false
            },
            "streamSettings": {
                "network": "ws",
                "sniffing": {
                    "enabled": true,
                    "destOverride": [
                        "http",
                        "tls"
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        },
        {
            "protocol": "socks",
            "tag": "my-out-tag",
            "settings": {
                "servers": [
                    {
                        "address": "127.0.0.1",
                        "port": 12345
                    }
                ]
            }
        }
    ]
}
EOF

bash <(curl -Ls https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

systemctl enable --now v2ray && \
systemctl status v2ray

bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/add-nginx-proxy-pass-site.sh) $domain http://127.0.0.1:10080/ $port

echo "v2ray安装完成，"
echo "协议1：vmess + tls + ws，host: $host, uuid：$uuid2，端口：$port"
echo "协议2：shadowsocks，host: 127.0.0.1, password: $uuid，端口：10081"
echo "请记得重启nginx，使得nginx配置生效"