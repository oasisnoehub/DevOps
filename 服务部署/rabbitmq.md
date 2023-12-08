# Rabbitmq
## 使用docker创建rabbitmq集群
https://www.rabbitmq.com/clustering.html
#### 创建rabbitmq集群网络
```shell
docker network create --scope=swarm --attachable -d overlay rabbitmq-net
```

#### rabbitmq 集群compose yml文件（采用portainer的stack进行部署）
```shell
version: '3.7'

# 指定Cookie，保证集群中的不同节点相互通信
x-rabbitmq-common: &rabbitmq-common
  image: rabbitmq:management
  environment:
    - RABBITMQ_DEFAULT_USER=admin
    - RABBITMQ_DEFAULT_PASS=admin
    - RABBITMQ_ERLANG_COOKIE=rabbitmq_erlang_cookie
  networks:
    - network1
  restart: always

# 使用外部创建的rabbitmq-net网络
networks:
  network1:
    name: rabbitmq-net
    external: true

# 启动3个rabbitmq容器节点
services:
  rabbitmq1:
    <<: *rabbitmq-common
    hostname: rabbitmq1
    ports:
      - 15672:15672
      - 5672:5672
      - 1883:1883
    volumes:
      - rabbitmq1-data:/var/lib/rabbitmq
    
  rabbitmq2:
    <<: *rabbitmq-common
    hostname: rabbitmq2
    ports:
      - 15673:15672
      - 5673:5672
      - 1884:1883   
    volumes:
      - rabbitmq2-data:/var/lib/rabbitmq
    
  rabbitmq3:
    <<: *rabbitmq-common
    hostname: rabbitmq3
    ports:
      - 15674:15672
      - 5674:5672
      - 1885:1883
    volumes:
      - rabbitmq3-data:/var/lib/rabbitmq
volumes:
  rabbitmq1-data:
  rabbitmq2-data:
  rabbitmq3-data:
```
如果没有显示出图形管理界面，首先检查访问端口是否正确，如果正确还是没有，则进入rabbitmq容器内安装rabbitmq_management管理插件：
```shell
rabbitmq-plugins enable rabbitmq_management
```

#### 创建rabbitmq集群（将三个容器节点加入一个集群）

（1）进入rabbitmq2容器节点，以rabbit@rabbitmq1为主节点集群将rabbitmq2加入rabbit@rabbitmq1
```shell
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster rabbit@rabbitmq1
rabbitmqctl start_app
```
（2）进入rabbitmq3容器节点，加入rabbit@rabbitm2
```shell
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster rabbit@rabbitmq2
rabbitmqctl start_app
```
（3）使用以下命令查看cluster的状态
```shell
rabbitmqctl cluster_status
```
具有三个rabbitmq的集群
![Alt text](image-16.png)