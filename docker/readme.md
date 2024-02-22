## docker应用
frps服务端
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-frps.sh) pass@word 7000 443 20000 30000
```

frpc客户端
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-frpc.sh) default
```

Duplicati
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-duplicati.sh) 8200
```

firefox远程浏览器
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-kasm-firefox.sh) pass@word 6901
```

clxsh
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-clxsh.sh)
```

生成https泛域名证书
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/add-https-cert.sh) example.com cf_token cf_account_id
```

幻兽帕鲁palworld联机服务器
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-palworld.sh) mypalworld pass@word
```

cloudreve网盘
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-cloudreve.sh)
```

mysql数据库
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-mysql.sh) pass@word 127.0.0.1:3306
```

redis缓存
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-redis.sh) pass@word 127.0.0.1:6379
```

独角发卡
```
bash <(curl -Ls https://raw.githubusercontent.com/tou13/somefiles/main/docker/install-dujiaoka.sh) 127.0.0.1 3306 dbname dbuser dbpass 127.0.0.1 6379 redispass ShopName https://shop.your.com shop_random_key
```
