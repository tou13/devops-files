#!/usr/bin/env bash

if ! command -v mkswap &> /dev/null || ! command -v swapon &> /dev/null; then
    echo "必需的命令 mkswap 或 swapon 不存在，请先安装它们。"
    exit 1
fi

if [[ $(swapon --show) ]]; then
    echo "系统已经启用了swap空间。"
    exit 0
fi

swap_size=${1:-1024}
dd if=/dev/zero of=/swapfile bs=1MB count=$swap_size
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

if ! grep -q "/swapfile swap swap" /etc/fstab; then
    echo "/swapfile swap swap defaults 0 0" | tee -a /etc/fstab
else
    echo "fstab 已经包含 swapfile 条目，跳过添加。"
fi

swapon --show