#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

if [ -d "/home/volume/duplicati/data" ]; then
    read -p "Duplicati配置已存在于 /home/volume/duplicati/data ，是否继续安装？(y/n): " user_input

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

web_port=${1:-8200}

mkdir -p /home/volume/duplicati/data
chown -R 1000:1000 /home/volume/duplicati

docker stop duplicati-$USER && docker rm duplicati-$USER

docker run -d \
  --name duplicati-$USER \
  --restart unless-stopped \
  --cpus 0.12 \
  --memory 256M \
  --network internalnet \
  -u 1000:1000 \
  -p $web_port:8200 \
  -v /home/volume/duplicati/data:/data \
  -v /home/volume:/home/volume:ro \
  -v /tmp/duplicati_tempdata:/home/tempdata \
  duplicati/duplicati:2.0.7.1_beta_2023-05-25

echo "Duplicati服务端运行成功，请使用 http://host:$web_port 访问"