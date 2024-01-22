#!/usr/bin/env bash

if command -v docker &> /dev/null; then
    echo "Docker 已安装"
    exit 0
fi

# write mirror to daemon.json
write_docker_config() {
cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://docker.nju.edu.cn"
    ]
}
EOF
}

apt update && apt upgrade -y
if ! command -v wget &> /dev/null || ! command -v curl &> /dev/null; then
    apt install wget curl -y
fi

if [ $(curl -Ls http://ipip.rehi.org/country_code) == "CN" ]; then
    bash <(curl -Ls https://get.docker.com) --mirror Aliyun
    write_docker_config
    systemctl restart docker
else
    bash <(curl -Ls https://get.docker.com)
fi

docker network create internalnet