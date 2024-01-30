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

target_user=${1:-ubuntu}
target_user_home=$(getent passwd $target_user | cut -d: -f6)
if [ -z "$target_user_home" ]; then
    echo "用户 '$target_user' 不存在，跳过安装"
    exit 1
fi

wget -O /tmp/$app_name.deb http://archive.ubuntukylin.com/software/pool/partner/weixin_2.1.1_amd64.deb
apt install /tmp/$app_name.deb

echo "微信 安装成功"

cat <<EOF > $target_user_home/Desktop/$app_name.desktop
[Desktop Entry]
Name[tr]=weixin
Name[zh_CN]=微信
Exec=/opt/weixin/weixin --no-sandbox %U
Terminal=false
Type=Application
Icon=weixin
StartupWMClass=weixin
Comment=微信桌面版
Categories=Utility;
EOF

chmod +x "$target_user_home/Desktop/$app_name.desktop"