#!/usr/bin/env bash

$app_name='weixin'
target_user=${1:-ubuntu}

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/desktop-init-check.sh) $app_name $target_user)
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
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