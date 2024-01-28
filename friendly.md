# 第三方脚本
github国内加速hosts
```
sed -i "/# GitHub520 Host Start/Q" /etc/hosts && curl https://raw.hellogithub.com/hosts >> /etc/hosts
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
lxc或openvz重装
```
bash <(curl -Ls https://raw.githubusercontent.com/LloydAsp/OsMutation/main/OsMutation.sh)
```
VPS测试脚本
```
bash <(curl -Ls https://raw.githubusercontent.com/teddysun/across/master/bench.sh)
```