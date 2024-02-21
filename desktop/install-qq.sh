#!/usr/bin/env bash

$app_name='linuxqq'
target_user=${1:-ubuntu}

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/desktop-init-check.sh) $app_name $target_user)
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
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
