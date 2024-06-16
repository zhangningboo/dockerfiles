### docker配置
```json
{
  "builder": {
    "features": {
      "buildkit": true
    },
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "default-shm-size": "2048M",
  "dns": [
    "180.76.76.76",
    "223.6.6.6"
  ],
  "experimental": false,
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
```

### 构建镜像
```shell
$ docker build -t ${IMAGE_NAME} .
```

### docker 镜像导出/导出

```shell
# 导出
$ docker save ${IMAGE_ID} > ${IMAGE_NAME}.tag
# 分卷压缩
$ zip -s 2048M -r dst-block.zip /your/compress/path
# 分卷解压
$ zip -s 0 dst-block.zip --out dst.zip
$ unzip dst.zip
# 导入
$ docker load < ${IMAGE_NAME}.tag
# 重命名
$ docker tag ${IMAGE_ID} ${Repo_NAME}:${TAG_NAME}
```
