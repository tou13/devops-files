#!/usr/bin/env bash

if command -v nginx &> /dev/null; then
    echo "nginx 已安装"
    exit 0
fi

apt update
apt install nginx -y

bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/add-diy-https-cert.sh)

sed -i 's|/etc/nginx/sites-enabled/*;|/home/site/*;|' /etc/nginx/nginx.conf
mkdir -p /home/volume/nginx/site

http_port=${1:-80}
https_port=${1:-443}

cat <<EOF > /home/volume/nginx/site/default
server {
    listen $http_port default_server;
    listen [::]:$http_port default_server;

    listen $https_port ssl default_server;
    listen [::]:$https_port ssl default_server;
    ssl_certificate /home/volume/nginx/ssl/diy.crt;
    ssl_certificate_key /home/volume/nginx/ssl/diy.key;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;

    location / {
        default_type application/json;
        return 200 '{"detail": "the service is successfully installed and working"}';
    }
}
EOF

echo "nginx安装成功，使用 http://host:$http_port 或 https://host:$https_port 访问" 