#!/usr/bin/env bash

app_name='obsidian'
target_user=${1:-}

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/desktop-init-check.sh) $app_name $target_user)
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
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