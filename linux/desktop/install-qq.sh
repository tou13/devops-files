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

target_user=${1:-ubuntu}
target_user_home=$(getent passwd $target_user | cut -d: -f6)
if [ -z "$target_user_home" ]; then
    echo "用户 '$target_user' 不存在，跳过安装"
    exit 1
fi

wget -O /tmp/$app_name.deb https://dldir1.qq.com/qqfile/qq/QQNT/feb78c41/linuxqq_3.2.5-21159_amd64.deb
apt install /tmp/$app_name.deb

echo "LinuxQQ安装成功"

cat <<EOF > $target_user_home/Desktop/$app_name.desktop
[Desktop Entry]
Name=QQ
Exec=/opt/QQ/qq --no-sandbox %U
Terminal=false
Type=Application
Icon=/usr/share/icons/hicolor/512x512/apps/qq.png
StartupWMClass=QQ
Categories=Network;
Comment=QQ
MimeType=x-scheme-handler/tencent;
EOF

chmod +x "$target_user_home/Desktop/$app_name.desktop"
