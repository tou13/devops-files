#!/usr/bin/env bash

$app_name='weixin'

if dpkg -l | grep -q "$app_name"; then
    echo "微信 已经安装，跳过安装"
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "脚本未以root用户执行，请切换到root用户或使用sudo"
    exit 1
fi

wget -O /tmp/$app_name.deb http://archive.ubuntukylin.com/software/pool/partner/weixin_2.1.1_amd64.deb
apt install /tmp/$app_name.deb

echo "微信 安装成功"