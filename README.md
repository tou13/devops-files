# Some service files

本仓库用于存储Linux下部署服务时，所需要用到的脚本和配置文件等。

仓库仅供私人使用，不保证脚本的稳定性。

## 脚本使用
增加swap交换空间
```
bash <(curl -Ls https://cdn.jsdelivr.net/gh/tou13/somefiles/linux/add-swap.sh) 1024
```
安装docker（并设置国内源）
```
bash <(curl -Ls https://cdn.jsdelivr.net/gh/tou13/somefiles/linux/install-docker.sh)
```