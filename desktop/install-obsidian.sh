#!/usr/bin/env bash

$app_name='obsidian'

if dpkg -l | grep -q "$app_name"; then
    echo "obsidian 已经安装，跳过安装"
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

wget -O /tmp/$app_name.deb https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.3/obsidian_1.5.3_amd64.deb
apt install /tmp/$app_name.deb

echo "obsidian 安装成功"

cat <<EOF > $target_user_home/Desktop/$app_name.desktop
[Desktop Entry]
Name=Obsidian
Exec=/opt/Obsidian/obsidian --no-sandbox %U
Terminal=false
Type=Application
Icon=obsidian
StartupWMClass=obsidian
Comment=Obsidian
MimeType=x-scheme-handler/obsidian;
Categories=Office;
EOF

chmod +x "$target_user_home/Desktop/$app_name.desktop"