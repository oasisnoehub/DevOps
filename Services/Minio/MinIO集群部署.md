# MinIO 集群部署(多driver部署)

创建minio集群网络
```shell
docker network create --scope=swarm --attachable -d overlay minio-network
```
创建volume绑定宿主机本地文件夹
```shell
mkdir -p /mydata/minio/data-1
mkdir -p /mydata/minio/data-2
mkdir -p /mydata/minio/data-3
mkdir -p /mydata/minio/data-4
```

使用minio集群`mino-stack.yml`编排文件进行部署
```shell
docker stack deploy -c mino-stack.yml minio
```
`mino-stack.yml : `
```yml

version: '3.7'

networks:
  network1:
    name: minio-network
    external: true

services:
  minio:
    image: minio/minio
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: cfps@infosky #大于等于8位
      MINIO_VOLUMES: "/data-{1...4}"
    restart: always
    volumes: # 使用多driver的方式
      - /mydata/minio/data-1:/data-1
      - /mydata/minio/data-2:/data-2
      - /mydata/minio/data-3:/data-3
      - /mydata/minio/data-4:/data-4
    command: minio server --console-address ":9009"
    networks:
      - network1
    logging:
      options:
        max-size: "50M" # 最大文件上传限制
        max-file: "10"
      driver: json-file
    ports:
        - "9002:9000" # api 端口
        - "9009:9009"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.role == manager]
```

