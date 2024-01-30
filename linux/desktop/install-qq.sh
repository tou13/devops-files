#!/usr/bin/env bash

$app_name='linuxqq'

if dpkg -l | grep -q "$app_name"; then
    echo "LinuxQQ 已经安装，跳过安装"
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "脚本未以root用户执行，请切换到root用户或使用sudo"
    exit 1
fi

wget -O /tmp/$app_name.deb https://dldir1.qq.com/qqfile/qq/QQNT/feb78c41/linuxqq_3.2.5-21159_amd64.deb
apt install /tmp/$app_name.deb

echo "LinuxQQ安装成功"
