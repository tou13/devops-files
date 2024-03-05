#!/usr/bin/env bash

app_name='gitfiend'
target_user=${1:-}

output_message=$(bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/common/desktop-init-check.sh) $app_name $target_user)
if [ "$?" -ne 0 ]; then
    echo "初始化脚本检查失败，错误原因：$output_message"
    exit $?
fi

wget -O /tmp/$app_name.deb https://gitfiend.com/resources/GitFiend_0.44.3_amd64.deb
apt install /tmp/$app_name.deb

echo "GitFiend 安装成功"

target_user_home=$(getent passwd $target_user | cut -d: -f6)
cat <<EOF > $target_user_home/Desktop/$app_name.desktop
[Desktop Entry]
Name=GitFiend
Exec=/opt/GitFiend/gitfiend --no-sandbox %U
Terminal=false
Type=Application
Icon=gitfiend
StartupWMClass=GitFiend
Comment=A Git client designed for humans
Categories=Development;
EOF

chmod +x "$target_user_home/Desktop/$app_name.desktop"