
# docker网络ip地址冲突(导致无法使用Xshell登录主机)

`注意：一定要避免docker网桥地址冲突的问题`

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
![Alt text](assets/Docker%E7%BD%91%E7%BB%9C%E9%97%AE%E9%A2%98/image.png)
删除`docker_gwbridge`网络
```shell
docker network inspect docker_gwbridge
```
如果报错说有节点在使用,
用下面命令查看谁在使用`docker_gwbridge`
```shell
docker network inspect docker_gwbridge
```
![Alt text](assets/Docker%E7%BD%91%E7%BB%9C%E9%97%AE%E9%A2%98/image-1.png)

断开与`gateway_ingress-sbox`的连接
```shell
docker network disconnect -f docker_gwbridge gateway_ingress-sbox
```
删除网络：
```shell
docker network rm docker_gwbridge
```
新建docker_gwbridge网络：设置地址为`192.168.16.0/24`
```shell
docker network create --subnet 192.168.14.1/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```


# 修改完之后，发现ip地址不冲突，但是启动服务无法访问
`docker网络与宿主机网络不在同一子网段，所以无法通过宿主机转发访问docker启动的服务`

修改的 `docker_gwbridge` 地址为：`192.168.14.1/24` 
(`inet 192.168.14.1  netmask 255.255.255.0  broadcast 192.168.14.255`)
而宿主机的网卡 地址为 `172.20.220.12` 
（`inet 172.20.220.12  netmask 255.255.255.0  broadcast 172.20.220.255`）

解决办法：修改 `docker_gwbridge` 地址，使其与宿主机网卡地址位于同一子网，但尽可能远离宿主机网络避免网络ip地址冲突, 按上述方法将`docker_gwbridge` 地址修改为`172.23.0.1/24` 
`inet 172.23.0.1  netmask 255.255.255.0  broadcast 172.23.0.255`

```shell
docker network create --subnet 172.24.0.1/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```

