# Docker网络问题处理说明文档

| 版本号 | 编辑日期   | 修改人  | 内容描述               | 审核人  |
|--------|------------|---------|---------------------------|---------|
| 1.0.0    | 2025-01-14 | 尹艺玲    | 初始版本                  | 尹艺玲    |


### 问题1: docker网络ip地址冲突(导致无法使用Xshell登录主机)
注意：一定要避免docker网桥地址冲突的问题

https://blog.csdn.net/github_30641423/article/details/117375669

修改`docker0`网络ip地址
```shell
# 修改daemon.json文件
vi /etc/docker/daemon.json
```
将`docker0`网络地址进行绑定` "bip":"172.14.0.1/24" `
```json
{
        "bip":"172.14.0.1/24",
        "insecure-registries": ["172.20.220.15:8888","172.20.220.12:8888","172.20.220.18:8888","172.20.220.15:9001"],
        "data-root": "/mydata/docker/lib"
}
```
重新加载docker
```shell
# 更新daemon配置
systemctl daemon-reload
# 重启docker
systemctl restart docker
```
修改`docker_gwbridge`地址（在此之前停止所有在运行的docker容器、服务和堆栈）
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
新建docker_gwbridge网络：设置地址为`172.29.0.0/24`
```shell
docker network create --subnet 172.69.0.0/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```

### 问题2: 修改完之后，发现ip地址不冲突，但是启动服务无法访问
`docker网络与宿主机网络不在同一子网段，所以无法通过宿主机转发访问docker启动的服务`

修改的 `docker_gwbridge` 地址为：`172.29.0.0/24` 
(`inet 192.168.14.1  netmask 255.255.255.0  broadcast 192.168.14.255`)
而宿主机的网卡 地址为 `172.20.220.12` 
（`inet 172.20.220.12  netmask 255.255.255.0  broadcast 172.20.220.255`）

解决办法：修改 `docker_gwbridge` 地址，使其与宿主机网卡地址位于同一子网，但尽可能远离宿主机网络避免网络ip地址冲突, 按上述方法将`docker_gwbridge` 地址修改为`172.23.0.1/24` 
`inet 172.23.0.1  netmask 255.255.255.0  broadcast 172.23.0.255`

```shell
docker network create --subnet 172.27.0.0/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```

### 问题3: 建立三个docker节点集群的网桥地址分配(
注意：避免ip地址冲突且在同一子网段，使docker服务能被访问到

**配置示例：**
docker swarm节点本机网卡地址
- dockerswarm01：`172.20.220.12`
    `inet 172.20.220.12  netmask 255.255.255.0  broadcast 172.20.220.255`
- dockerswarm02：`172.20.220.15`
    `inet 172.20.220.15  netmask 255.255.255.0  broadcast 172.20.220.255`
dockerswarm03：`172.20.220.18`
    `inet 172.20.220.18  netmask 255.255.255.0  broadcast 172.20.220.255`

查看网络配置：
```shell
ifconfig
```

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


### 问题4: 限定容器网络池问题
使用`default-address-pools`限定容器网络默认ip池
```shell
{
        "bip":"172.32.0.1/24",
        "default-address-pools": [
                {
                  "base": "172.35.0.0/16",
                  "size": 24
                }
        ],
        "insecure-registries": ["http://172.20.220.20:8888"],
        "data-root":"/appdata/docker/lib/docker",
        "registry-mirrors": ["http://mirrors.ustc.edu.cn","http://mirrors.aliyun.com/"]
}

```    

### 问题5: 银河麒麟V10操作系统Kylin Linux Advanced Server release V10 (Lance)版本 docker run时报错permission denied

参考文档： https://blog.csdn.net/qq_45547688/article/details/138150469#:~:text=docker:%20Er

解决办法：
卸载Kylin Linux Advanced Server release V10 (Lance) 自带的Podman, 重新run即可正常运行。
```shell
yum remove podman
```


### 问题6: 无法添加节点到swarm的问题

参考文档：https://blog.csdn.net/u011731053/article/details/111179380

防火墙问题：修改防火墙配置（可暂时先关闭防火墙进行配置）
```shell
# 配置防火墙 
firewall-cmd --permanent --add-port=2377/tcp
firewall-cmd --reload
```

