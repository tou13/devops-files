#!/usr/bin/env bash

# 获取主机名称
hostname=$(hostname)

# 自动获取包含公网IP的网络接口，如果获取不到，则默认使用eth0
get_public_interface() {
    for iface in $(ls /sys/class/net/ | grep -v lo); do
        # 检查 IPv4 地址
        ipv4=$(ip addr show $iface | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        if [[ $ipv4 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            if [[ ! $ipv4 =~ ^10\. ]] && [[ ! $ipv4 =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && [[ ! $ipv4 =~ ^192\.168\. ]]; then
                echo $iface
                return
            fi
        fi

        # 检查 IPv6 地址
        ipv6=$(ip addr show $iface | grep 'inet6 ' | awk '{print $2}' | cut -d/ -f1)
        if [[ $ipv6 =~ ^[^fF][^eE] ]]; then
            echo $iface
            return
        fi
    done
    echo "eth0"
}

INTERFACE=$(get_public_interface)

# 获取CPU使用率
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
cpu_usage=$(printf "%.0f" $cpu_usage)

# 获取内存使用率
mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
mem_usage=$(printf "%.0f" $mem_usage)

# 获取交换区使用率
swap_usage=$(free | grep Swap | awk '{print $3/$2 * 100.0}')
swap_usage=$(printf "%.0f" $swap_usage)

# 获取硬盘使用率
disk_usage=$(df -h | grep '/$' | awk '{print $5}' | cut -d'%' -f1)

# 获取系统运行时间
uptime=$(uptime -p)

# 第一次读取网络数据
R1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
T1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
sleep 1

# 第二次读取网络数据
R2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
T2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# 计算网络速度（以字节为单位）
TX=$((($T2 - $T1)))
RX=$((($R2 - $R1)))

# 转换速度为kb/s或mb/s
convert_speed() {
    local speed=$1
    if [ $speed -lt 1024 ]; then
        echo "${speed} b/s"
    elif [ $speed -lt 1048576 ]; then
        echo "$((speed / 1024)) kb/s"
    else
        echo "$((speed / 1048576)) mb/s"
    fi
}

tx_speed=$(convert_speed $TX)
rx_speed=$(convert_speed $RX)

# 获取系统负载
load=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

# 输出结果
echo "主机名称：$hostname"
echo "CPU 使用率: $cpu_usage%"
echo "内存使用率: $mem_usage%"
echo "交换区使用率: $swap_usage%"
echo "硬盘使用率: $disk_usage%"
echo "网络速度: 上行 $tx_speed | 下行 $rx_speed"
echo "系统负载: $load"
echo "运行时间: $uptime"