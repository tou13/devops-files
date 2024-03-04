# 第三方脚本
github国内加速hosts
```
sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
```
为IPv6添加nat64
```
cp -n /etc/resolv.conf /etc/resolv.conf.bak && echo -e "nameserver 2a00:1098:2b::1\nnameserver 2a01:4f9:c010:3f02::1\nnameserver 2a01:4f8:c2c:123f::1\nnameserver 2a00:1098:2c::1" > /etc/resolv.conf
```
重装debian 11 (有DHCP)
```
bash <(curl -Ls https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh) debian-11
```
重装debian 11 (无DHCP)
```
bash <(curl -Ls https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh) -d 11 -v 64 -p pass@word -port 22 -a -firmware --mirror 'https://mirrors.huaweicloud.com/debian/'
```
重装win 11
```
bash <(curl -Ls https://raw.githubusercontent.com/teddysun/across/master/InstallNET.sh) -dd 'https://dl.lamp.sh/vhd/tiny11_23h2.xz'
```
lxc或openvz7重装
```
bash <(curl -Ls https://raw.githubusercontent.com/LloydAsp/OsMutation/main/OsMutation.sh)
```
添加warp网络
```
bash <(curl -Ls https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh)
```
VPS测试脚本
```
bash <(curl -Ls https://raw.githubusercontent.com/teddysun/across/master/bench.sh)
```
流媒体解锁测试
```
bash <(curl -Ls https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
```
回程路由测试脚本（需下载大量依赖）
```
bash <(curl -Ls https://raw.githubusercontent.com/hijkpw/testrace/master/testrace.sh)
```