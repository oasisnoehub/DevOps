# Nacos

https://nacos.io/zh-cn/docs/cluster-mode-quick-start.html

克隆项目
```shell
git clone https://github.com/nacos-group/nacos-docker.git
cd nacos-docker
```
使用docker compose启动nacos集群
```shell
docker compose -f example/cluster-hostname.yaml up 
```
服务注册：
```shell
curl -X POST 'http://172.22.70.18:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080'
```
服务发现：
```shell
curl -X GET 'http://172.22.70.18:8848/nacos/v1/ns/instance/list?serviceName=nacos.naming.serviceName'
```
## Nacos 集群搭建
https://nacos.io/en/docs/v2/quickstart/quick-start-docker/

### 创建集群网络
```shell
docker network create -d overlay --attachable nacos-net
```



## Nacos + Grafana + Prometheus 监控
https://nacos.io/zh-cn/docs/monitor-guide.html

https://prometheus.io/download/