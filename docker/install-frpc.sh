#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

client_name=${1:-default}

if [ -f "/home/volume/frp/config/frpc-$client_name.ini" ]; then
    read -p "FRP客户端配置已存在于 /home/volume/frp/config/frpc-$client_name.ini ，是否继续安装？(y/n): " user_input

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

mkdir -p /home/volume/frp/config
touch /home/volume/frp/config/frpc-$client_name.ini

chown -R 1000:1000 /home/volume/frp

docker stop frps-$client_name && docker rm frps-$client_name

docker run -d \
  --name frpc-$client_name \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
  --network internalnet \
  -v /home/volume/nginx/ssl:/frp/ssl \
  -v /home/volume/frp/config/frpc-$client_name.ini:/frp/frpc.ini \
  stilleshan/frpc:0.51.3

echo "FRP客户端运行成功，请修改 /home/volume/frp/config/frpc-$client_name.ini 配置文件后，使用 docker restart frpc-$client_name 命令重启服务"