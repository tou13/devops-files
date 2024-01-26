# Some files

本仓库用于存储Linux下部署服务时，所需要用到的脚本和配置文件等。

仓库仅供私人使用，不保证脚本的稳定性。第三方脚本看[这里](friendly.md)。

## 脚本使用
初始化软件包（安装cur, wget, git, nano等），国内机器先参考[这里](https://mirror.nju.edu.cn/mirrorz-help/debian/?mirror=NJU)换源
```
apt update && apt upgrade -y && apt install bash curl wget git nano openssl -y
```
增加swap交换空间
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/add-swap.sh) 1024
```
安装docker（并设置国内源）
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/install-docker.sh)
```
安装v2rxx
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/install-v2rxx.sh)
```
安装ttyd
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/install-ttyd.sh) admin pass@word
```
安装nginx
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/install-nginx.sh) 80 443
```
安装ninja
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/linux/install-ninja.sh) 7999
```
## docker应用
安装frp服务端
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-frps.sh) pass@word 7000 20000 30000
```
安装frp客户端
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-frpc.sh) default
```
安装firefox远程浏览器
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-firefox.sh) pass@word 6901
```
安装幻兽帕鲁palworld联机服务器
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-palworld.sh) mypalworld pass@word
```