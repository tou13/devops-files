# Some files

本仓库用于存储Linux下部署服务时，所需要用到的脚本和配置文件等。

仓库仅供私人使用，不保证脚本的稳定性。

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

## docker应用
安装nps
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-nps.sh) admin pass@word
```