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
