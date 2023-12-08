# Redis Sebtinal Cluster

https://redis.io/docs/management/sentinel/

https://zhuanlan.zhihu.com/p/648737280

## Redis 集群架构
![Alt text](image-11.png)
![Alt text](image-13.png)
## 创建docker redis 集群网路
`注意：创建网络范围为swarm并且需要attachable`
```shell
docker network create --scope=swarm --attachable -d overlay redis-net-ms
```

创建redis master节点
```shell
docker run -itd --name redis-master --net redis-net-ms  -v ~/redis-data:/data redis:latest redis-server --port 6379 --appendonly yes
```
创建redis subnode节点，将它们连接到之前创建的 redis-net 网络中。每个容器将监听不同的端口（6380、6381），并使用 --slaveof 参数将它们设置为 redis-master 的从节点redis-subnode1和redis-subnode2。
```shell
# 创建从节点1 ： subnode1 （port:6379）
docker run -itd --name redis-subnode1 --net redis-net-ms -v ./redis-data:/data redis:latest redis-server --port 6380 --slaveof redis-master 6379 --appendonly yes
# 创建从节点2 ： subnode2 （port:6379）
docker run -itd --name redis-subnode2 --net redis-net-ms -v ./redis-data:/data redis:latest redis-server --port 6381 --slaveof redis-master 6379 --appendonly yes
```
查看redis-master节点网络
```shell
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis-master
# -------------------------------------------
>>> [root@dockerswarm-01 ~]# docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis-master
>>> 10.0.8.6
```
![Alt text](image-14.png)

新建用于存放sentinel配置文件的文件夹
```shell
mkdir ~/sentinel-conf
cd ~/sentinel-conf
```
下载sentinel配置文件
```shell
wget http://download.redis.io/redis-stable/sentinel.conf
vi sentinel.conf
```
配置sentinel.conf文件
```shell
port 26379
daemonize yes
sentinel monitor mymaster  192.168.48.2 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 10000
```

文件配置模板sentinel.conf
```shell
# Example sentinel.conf

protected-mode no

# port <sentinel-port>
# The port that this sentinel instance will run on
port 26379

# By default Redis Sentinel does not run as a daemon. Use 'yes' if you need it.
# Note that Redis will write a pid file in /var/run/redis-sentinel.pid when
# daemonized.
daemonize no

pidfile /var/run/redis-sentinel.pid

loglevel notice

# Specify the log file name. Also the empty string can be used to force
# Sentinel to log on the standard output. Note that if you use standard
# output for logging but daemonize, logs will be sent to /dev/null
logfile ""

dir /tmp

sentinel monitor mymaster 10.0.8.6 6379 2

sentinel auth-pass mymaster redispassword

sentinel down-after-milliseconds mymaster 5000

acllog-max-len 128

sentinel parallel-syncs mymaster 1

sentinel failover-timeout mymaster 10000

r /var/redis/notify.sh

sentinel deny-scripts-reconfig yes

SENTINEL resolve-hostnames no

SENTINEL announce-hostnames no

SENTINEL master-reboot-down-after-period mymaster 0

```

创建 Redis Sentinel (创建个数要求为单数个)
```shell
# 并将其连接到之前创建的 redis-net 网络中。它将监控 redis-master 主节点，并在主节点失效后触发故障转移
docker run -itd --name redis-sentinel1 --net redis-net-ms -v ~/sentinel-conf/sentinel.conf:/usr/local/etc/redis/sentinel.conf  redis:latest redis-sentinel  /usr/local/etc/redis/sentinel.conf

docker run -itd --name redis-sentinel2 --net redis-net-ms -v ~/sentinel-conf/sentinel.conf:/usr/local/etc/redis/sentinel.conf  redis:latest redis-sentinel  /usr/local/etc/redis/sentinel.conf

docker run -itd --name redis-sentinel3 --net redis-net-ms -v ~/sentinel-conf/sentinel.conf:/usr/local/etc/redis/sentinel.conf  redis:latest redis-sentinel  /usr/local/etc/redis/sentinel.conf

```
![Alt text](image-15.png)
