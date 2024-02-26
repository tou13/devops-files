#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

if [ -f "/home/volume/mysql/config/my.cnf" ]; then
    read -p "MySQL配置已存在于 /home/volume/mysql/config/my.cnf ，是否继续安装？(y/n): " user_input

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

password=${1:-pass@word}
port=${2:-3306}

mkdir -p /home/volume/mysql/data
mkdir -p /home/volume/mysql/config
chown -R 1000:1000 /home/volume/mysql

docker stop mysql-$USER && docker rm mysql-$USER

docker run -d \
  --name mysql-$USER \
  --restart unless-stopped \
  --cpus 1 \
  --memory 1024M \
  --network internalnet \
  -u 1000:1000 \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=$password \
  -p $port:3306 \
  -v /home/volume/mysql/data:/var/lib/mysql \
  -v /home/volume/mysql/config:/etc/mysql/conf.d \
  mysql:5.7.44 \
  --lower_case_table_names=1 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_general_ci \
  --explicit_defaults_for_timestamp=true

chown -R 1000:1000 /home/volume/mysql

echo "mysql安装成功，使用root / $password 连接"