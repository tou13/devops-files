#!/usr/bin/env bash

app_name=${1:-}
target_user=${2:-}

if [ -z "$target_user" ]; then
    echo "缺少user身份参数"
    exit 1
fi

if dpkg -l | grep -q "$app_name"; then
    echo "$app_name 已经安装，跳过安装"
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "脚本未以root用户执行，请切换到root用户或使用sudo"
    exit 1
fi

target_user=${2:-}
target_user_home=$(getent passwd $target_user | cut -d: -f6)
if [ -z "$target_user_home" ]; then
    echo "用户 '$target_user' 不存在，跳过安装"
    exit 1
fi