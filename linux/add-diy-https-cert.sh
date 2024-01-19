#!/usr/bin/env bash

ssl_path=${1:-/home/volume/nginx/ssl}
if [[ -f "$ssl_path/diy.crt" && -f "$ssl_path/diy.key" ]]; then
    echo "证书和私钥已存在于 $ssl_path，跳过证书生成。"
    exit 0
fi

if ! command -v openssl &> /dev/null; then
    apt update
    apt install openssl -y
fi
openssl genrsa -out diy.key 2048
openssl req -new -subj "/C=CN/ST=BEIJING/L=BEIJING/O=BEI/OU=CN/CN=diy" -key diy.key -out diy.csr
mv diy.key diy.origin.key
openssl rsa -in diy.origin.key -out diy.key
openssl x509 -req -days 36500 -in diy.csr -signkey diy.key -out diy.crt
mkdir -p "$ssl_path"
mv ./{diy.key,diy.crt} "$ssl_path"
rm -rf ./diy.*

echo "证书生成成功！证书地址：$ssl_path/diy.crt，私钥地址：$ssl_path/diy.key"