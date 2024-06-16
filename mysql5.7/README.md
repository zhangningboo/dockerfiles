## 启动
```shell
$ docker run -itd -p 3306:3306 \
-v /Users/zhangningboo/dataset/conf:/etc/mysql/conf.d \
-v /Users/zhangningboo/dataset/logs:/logs \
-v /Users/zhangningboo/dataset/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=root \
--name mysql_latest mysql:latest /bin/bash

$ docker run -itd -p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=root \
--name mysql_latest mysql:latest /bin/bash

$ docker run \
-p 3306:3306 \
--name mysql8 \
--privileged=true \
--restart on-failure:3 \
-v /Users/zhangningboo/dataset/mysql/etc/mysql:/etc/mysql \
-v /Users/zhangningboo/dataset/mysql/logs:/logs \
-v /Users/zhangningboo/dataset/mysql/data:/var/lib/mysql \
-v /Users/zhangningboo/dataset/mysql/mysql-files:/var/lib/mysql-files \
-v /etc/localtime:/etc/localtime \
-e MYSQL_ROOT_PASSWORD="123456" \
-d mysql:latest

$ docker run \
-p 3306:3306 \
--name mysql8 \
--privileged=true \
--restart on-failure:3 \
-v /etc/localtime:/etc/localtime \
-e MYSQL_ROOT_PASSWORD="123456" \
-d mysql:latest

$ docker cp  mysql:/etc/mysql /data/zhangningbo/dataset/mysql/etc/mysql

$ docker exec -it mysql_8_0_29 /bin/bash
$ ln -s /opt/data/mysql/mysqld/mysqld.sock /var/lib/mysql/mysql.sock
```

```shell
$ docker run \
--name mysql_8_0_29 \
-p 7406:3306 \
-e MYSQL_ROOT_PASSWORD=LalalahaHa123 \
-e MYSQL_DATABASE=bev \
-e MYSQL_USER=mysql \
-e MYSQL_PASSWORD=mypassworEs \
-v /data/zhangningbo/dataset/mysql/data:/var/lib/mysql \
-d mysql:8.0.29

```