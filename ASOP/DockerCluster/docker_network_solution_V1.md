# Docker网络问题处理说明文档

| 版本号 | 编辑日期   | 修改人  | 内容描述               | 审核人  |
|--------|------------|---------|---------------------------|---------|
| 1.0.0    | 2025-01-14 | 尹艺玲    | 初始版本 （乌鲁木齐T4/丽水机场）       | 尹艺玲    |

## 目录
1. **Docker 网络 IP 地址冲突问题**
2. **网络子网段导致服务无法访问问题**
3. **Docker Swarm 节点网桥配置**
4. **容器网络池限制问题**
5. **银河麒麟 V10 系统运行错误问题**
6. **无法添加节点到 Swarm 问题**


### 1. Docker 网络 IP 地址冲突问题
#### 问题描述
Docker 网络的 docker0 网桥默认 IP 地址可能与宿主机网络发生冲突，导致无法使用 Xshell 等工具登录主机。
注意：一定要避免docker网桥地址冲突的问题
#### 解决方案
参考文档：https://blog.csdn.net/github_30641423/article/details/117375669

（1）修改`docker0`网络ip地址
```shell
# 修改daemon.json文件
vi /etc/docker/daemon.json
```
配置示例：
```json
{
   {
        "bip": "172.14.0.1/24",
        "insecure-registries": [
            "172.20.220.15:8888",
            "172.20.220.12:8888",
            "172.20.220.18:8888",
            "172.20.220.15:9001"
        ],
        "data-root": "/appdata/docker/lib/docker"
    }
}
```
（2）重新加载 Docker 配置并重启服务
```shell
# 更新daemon配置
systemctl daemon-reload
# 重启docker
systemctl restart docker
```
（3）修改`docker_gwbridge`地址（在此之前停止所有在运行的docker容器、服务和堆栈）
```shell
# 查看网络
docker network ls
```
删除`docker_gwbridge`网络
```shell
docker network inspect docker_gwbridge
```
如果报错说有节点在使用,
用下面命令查看谁在使用`docker_gwbridge`
```shell
docker network inspect docker_gwbridge
```
断开与`gateway_ingress-sbox`的连接
```shell
docker network disconnect -f docker_gwbridge gateway_ingress-sbox
```
删除网络：
```shell
docker network rm docker_gwbridge
```
新建docker_gwbridge网络：设置地址为`172.29.0.0/24`（根据具体部署ip配置）
```shell
docker network create --subnet 172.69.0.0/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```

### 2. 网络子网段导致服务无法访问问题
#### 问题描述
Docker 网络与宿主机网络不在同一子网段，导致无法通过宿主机访问 Docker 启动的服务。完成上述修改完之后，发现ip地址不冲突，但是启动服务无法访问，`docker网络与宿主机网络不在同一子网段，所以无法通过宿主机转发访问docker启动的服务`

解释：
- 修改的 `docker_gwbridge` 地址为：`172.29.0.0/24` 
(`inet 192.168.14.1  netmask 255.255.255.0  broadcast 192.168.14.255`)
- 而宿主机的网卡 地址为 `172.20.220.12` 
（`inet 172.20.220.12  netmask 255.255.255.0  broadcast 172.20.220.255`）

#### 解决办法
修改 `docker_gwbridge` 地址，使其与宿主机网卡地址位于同一子网，但尽可能远离宿主机网络避免网络ip地址冲突, 按上述方法将`docker_gwbridge` 地址修改为`172.23.0.1/24` （根据具体部署环境ip地址配置）

`inet 172.23.0.1  netmask 255.255.255.0  broadcast 172.23.0.255`

```shell
docker network create --subnet 172.27.0.0/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```

### 3. Docker Swarm 节点网桥配置
建立三个docker节点集群的网桥地址分配(
注意：避免ip地址冲突且在同一子网段，使docker服务能被访问到

**配置示例：**
docker swarm节点本机网卡地址
- dockerswarm01：`172.20.220.12`
    `inet 172.20.220.12  netmask 255.255.255.0  broadcast 172.20.220.255`
- dockerswarm02：`172.20.220.15`
    `inet 172.20.220.15  netmask 255.255.255.0  broadcast 172.20.220.255`
- dockerswarm03：`172.20.220.18`
    `inet 172.20.220.18  netmask 255.255.255.0  broadcast 172.20.220.255`

`docker0`网络配置：
- dockerswarm01： : `172.12.0.1/24` 
    (`inet 172.12.0.1  netmask 255.255.255.0  broadcast 172.12.0.255`)
- dockerswarm02： : `172.14.0.1/24` 
    (`inet 172.14.0.1  netmask 255.255.255.0  broadcast 172.14.0.255`)
- dockerswarm03： : `172.16.0.1/24` 
    (`inet 172.16.0.1  netmask 255.255.255.0  broadcast 172.16.0.255`)

`docker_gwbridge`网络配置：
- dockerswarm01： : `172.23.0.1/24` 
    (`inet 172.23.0.1  netmask 255.255.255.0  broadcast 172.23.0.255`)
- dockerswarm02： : `172.24.0.1/24` 
    (`inet 172.24.0.1  netmask 255.255.255.0  broadcast 172.24.0.255`)
- dockerswarm03： : `172.25.0.1/24` 
    (`inet 172.25.0.1  netmask 255.255.255.0  broadcast 172.25.0.255`)


### 4. 容器网络池限制问题
使用`default-address-pools`限定容器网络默认ip池：
```shell
{
    "bip": "172.32.0.1/24",
    "default-address-pools": [
        {
            "base": "172.35.0.0/16",
            "size": 24
        }
    ],
    "insecure-registries": ["http://172.20.220.20:8888"],
    "data-root": "/appdata/docker/lib/docker",
    "registry-mirrors": [
        "http://mirrors.ustc.edu.cn",
        "http://mirrors.aliyun.com/"
    ]
}
```    

### 5. 银河麒麟 V10 系统运行错误问题
#### 问题描述
在 Kylin Linux Advanced Server V10 系统中运行 Docker 容器时报错 permission denied。

参考文档： https://blog.csdn.net/qq_45547688/article/details/138150469#:~:text=docker:%20Er

#### 解决方案
（1）卸载系统自带的 Podman：
```shell
yum remove podman -y
```
（2）重启docker


### 6. 无法添加节点到swarm的问题

#### 问题描述
因防火墙限制导致无法将节点加入 Swarm 集群。
参考文档：https://blog.csdn.net/u011731053/article/details/111179380

#### 解决方案
（1）修改防火墙配置，开放必要端口：
```shell
# 配置防火墙 
firewall-cmd --permanent --add-port=2377/tcp
firewall-cmd --reload
```
（2）如果仍有问题，可暂时关闭防火墙：
```bash
systemctl stop firewalld
```
