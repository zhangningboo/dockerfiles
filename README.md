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
    "223.5.5.5"
  ],
  "experimental": false,
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://docker.nju.edu.cn"
  ]
}
```

### 构建镜像
```shell
$ docker build -t ${IMAGE_NAME} .
```