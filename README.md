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
# 根据镜像sha256拉取镜像
$ docker pull nvidia/cuda@sha256:fb2afb86d2ad20c40e1daff83fcb8e33f88c29878535e602f8f752136a6b9db2
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


trtexec --onnx=v5s_v7.0_batch_64_imgsz_1280_epoch_350.onnx --shapes=images:1x3x640x640