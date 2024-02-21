#!/usr/bin/env bash

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/docker-init-check.sh))
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

password=${1:-pass@word}
port=${2:-3306}

mkdir -p /home/volume/mysql
chown -R 1000:1000 /home/volume/mysql

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