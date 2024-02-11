#!/usr/bin/env bash

if command -v v2ray &> /dev/null; then
    echo "v2ray 已安装"
    exit 0
fi

port=${1:-10080}
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
            "listen": "0.0.0.0",
            "port": $port,
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
            "tag": "my-in-tag",
            "listen": "0.0.0.0",
            "port": $(($port+1)),
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

echo "安装完成，uuid：$uuid2，端口：$port"