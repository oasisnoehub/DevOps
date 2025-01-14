# Docker集群环境部署说明手册

| 版本号 | 编辑日期   | 修改人  | 内容描述               | 审核人  |
|--------|------------|---------|---------------------------|---------|
| 1.0.0    | 2025-01-14 | 尹艺玲    | 初始版本（乌鲁木齐T4/丽水机场）      | 尹艺玲    |

## 目录

1. **环境准备**

2. **Docker 安装**

3. **数据根地址迁移**

4. **网络配置**

5. **创建集群**

6. **安全实践配置**


### 1. 环境准备
在部署集群之前，请完成以下准备工作：
（1） 设置主机名称：
```shell
hostnamectl set-hostname <newhostname>
```
（2）删除可能冲突的软件（删除麒麟自带的podman）
```bash
# 参考文档： https://blog.csdn.net/qq_45547688/article/details/138150469#:~:text=docker:%20Er
yum remove podman -y
```

### 2. Docker安装（离线）

（1）准备安装文件：

- `docker-25.0.3.tgz`
- `docker.service`
- `docker-compose-linux-x86_64`

（2）执行以下脚本完成安装：
```shell
#!/bin/bash
# ======================================================
# Info: 离线安装Docker
# Prepare: 文件 | docker-25.0.3.tgz | docker.service
# ======================================================
tar -zxvf ./docker-25.0.3.tgz
cp docker/* /usr/bin/
cp docker.service /etc/systemd/system/
chmod 777 /etc/systemd/system/docker.service
systemctl daemon-reload
systemctl enable docker
systemctl start docker
systemctl status docker
docker -v
# 验证安装
docker info
# ======================================================
# Info: 离线安装docker compose-
# Prepare: 文件 | docker-compose-linux-x86_64
# ======================================================
mv docker-compose-linux-x86_64 docker-compose
mv docker-compose /usr/local/bin/
chmod +x /usr/local/bin/docker-compose
# 验证安装
docker-compose -v
# docker compose --version
# ======================================================
```

### 3. 数据根地址迁移
（1）创建目标目录：
```bash
mkdir -p /appdata/docker/lib
```
（2）使用 rsync 迁移数据：
```shell
# 将 /var/lib/docker的所有内容 复制到 /appdata/docker/lib
rsync -avzP /var/lib/docker /appdata/docker/lib
rm -rf /var/lib/docker
```
（3）配置`daemon.json`文件
编辑`/etc/docker/daemon.json`文件，如果没有`daemon.json`就直接创建`/etc/docker/daemon.json`：
```shell
mkdir -p /etc/docker
touch /etc/docker/daemon.json
```
将/etc/docker/daemon.json中的"data-root"对应的值为迁移后的文件地址+/docker（PS：没有则自行添加）：
```shell
{
    "data-root":"/appdata/docker/lib/docker"
}
```
（4）重载并重启 Docker：
执行下面重载、重启文件，并检查是否修改成功。如果没有修改成功，重新执行上述操作进行修改。
```shell
# 重载daemon文件
systemctl daemon-reload
# 重启docker
systemctl restart docker
# 检查data-root是否修改成功
docker info
```
### 4. 网络配置
（1）修改 daemon.json 配置文件：
修改`/etc/docker/daemon.json`文件内容如下（根据实际部署环境ip地址指定配置"bip":"172.12.0.1/24"）
（2）可考虑添加容器创建默认地址池
通过"default-address-pools"参数进行配置，请注意网络地址不要重叠：
```shell
        "default-address-pools": [
                {
                  "base": "172.16.0.0/24",
                  "size": 24
                }
        ],
```
- `daemon.json`文件配置示例:
```json
# 使用时请注意不要添加注释使用
{
    # 固定docker地址（根据实际部署环境进行修改）
    "bip":"172.12.0.1/24", 
    # 容器创建默认地址池（根据实际部署环境进行修改）
    "default-address-pools": [ 
        {
           "base": "172.16.0.0/24",
           "size": 24
        }
    ],
    # harbor镜像仓库地址（根据实际部署环境进行修改）
    "insecure-registries": ["http://172.20.220.20:8888"], 
    # 迁移后的docker数据地址（根据实际部署环境进行修改）
    "data-root":"/appdata/docker/lib/docker", 
    # pormetheus指标采集地址（根据实际部署环境进行修改）
    "metrics-addr": "172.20.220.12:9323", 
    # 代理镜像地址（根据实际部署环境进行修改）
    "registry-mirrors": ["http://mirrors.ustc.edu.cn","http://mirrors.aliyun.com/","https://registry.docker-cn.com"] 
}
```
---
参数解释：

`bip（Bridge IP）`: 这个配置项指定了 Docker 守护进程创建的默认桥接网络的 IP 地址范围。这个 IP 地址范围用于分配给连接到默认桥接网络的容器。示例中"bip":"172.12.0.1/24" 表示 Docker 将使用 172.12.0.1 到 172.12.0.255 之间的 IP 地址（/24 表示子网掩码是 255.255.255.0）。

`default-address-pools`: 这个配置项是在 Docker 20.10 及更高版本中引入的，用于定义默认的 IP 地址池。这些地址池用于自动分配给 overlay 网络和跨主机通信的容器。在你的例子中，"default-address-pools": [{"base": "172.16.0.0/24", "size": 24}] 表示 Docker 将使用 172.16.0.0/24 地址范围，并将其划分为 /24 子网（即每个子网有 256 个 IP 地址，从 172.16.0.0 到 172.16.0.255），用于创建 overlay 网络。

bip 用于默认桥接网络，而 default-address-pools 用于创建新的 overlay 网络

---

（3）`docker_gwbridge`网络配置

- `ifconfig`查看如果没有`docker_gwbridge`网络直接创建(按需指定地址)
```shell
docker network create --subnet 172.14.0.0/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```

- 修改`docker_gwbridge`地址（在此之前停止所有在运行的docker容器、服务和堆栈）：删除`docker_gwbridge`网络，如果报错信息说有节点在使用,用下面命令查看谁在使用`docker_gwbridge`，断开与`gateway_ingress-sbox`的连接，然后再删除网络
```shell
docker network ls
docker network inspect docker_gwbridge
docker network disconnect -f docker_gwbridge gateway_ingress-sbox
docker network rm docker_gwbridge
```
- 新建docker_gwbridge网络：本示例设置地址为`192.168.16.0/24`(注意：根据生产部署实际情况进行地址配置)
```shell
docker network create --subnet 192.168.16.0/24 \
--opt com.docker.network.bridge.name=docker_gwbridge \
--opt com.docker.network.bridge.enable_icc=false \
--opt com.docker.network.bridge.enable_ip_masquerade=true \
docker_gwbridge
```

（4）重载与重启docker
```shell
systemctl daemon-reload
systemctl restart docker
```
（5）检查配置
执行ipconfig命令，检查 `docker0` 和 `docker_gwbridge` 网络 是否与之前daemon.json配置的一致。如果不一致，则重新执行上述操作进行配置。

- 网络检查配置示例：
```shell
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.12.0.1  netmask 255.255.255.0  broadcast 172.12.0.255
        inet6 fe80::42:97ff:fe36:9d54  prefixlen 64  scopeid 0x20<link>
        ether 02:42:97:36:9d:54  txqueuelen 0  (Ethernet)
        RX packets 68431  bytes 4061766 (3.8 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 91977  bytes 135345602 (129.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

docker_gwbridge: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.27.0.1  netmask 255.255.255.0  broadcast 172.27.0.255
        inet6 fe80::42:8dff:fe2d:e9bc  prefixlen 64  scopeid 0x20<link>
        ether 02:42:8d:2d:e9:bc  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 8  bytes 656 (656.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

### 5. 创建集群
（1）初始化 Swarm 集群：
```shell
# 初始化集群
docker swarm init
# 多网卡情况下使用--advertise-addr参数进行指定初始化(注意：根据生产部署实际情况进行地址配置)
docker swarm init --advertise-addr 10.50.22.11
```
（2）节点加入集群：
根据返回结果，复制结果中`docker swarm join --token xxxxxx`的命令，然后在剩余需要加入swarm集群的节点执行复制的命令
```shell
Swarm initialized: current node (bvz81updecsj6wjz393c09vti) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-1awxwuwd3z9j1z3puu7rcgdbx 172.17.0.2:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
（3）查看swarm token
```shell
docker swarm join-token worker
```
（4）查看加入的docker swarm的节点
```shell
docker node ls
```
（5）节点角色配置
将节点提升为manager(只能在当前为manager的节点上运行)
```shell
docker node promote <节点名>
```
补充命令:如节点需要离开swarm集群
```shell
docker swarm leave -f
```
（6）集群节点添加标签
```shell
# docker node update --label-add role=node01 <docker hostname>
docker node update --label-add role=node01 agent1
docker node update --label-add role=node02 agent2
docker node update --label-add role=node03 agent3
```
（7）检查标签配置
```shell
# docker node inspect <docker hostname>
# 检查节点信息
docker node inspect agent1
# 看label参数是否与配置的设置一致
```

### 6. 安全实践配置（检查）
（1）Docker集群节点之间防火墙策略配置
确保防火墙规则允许集群节点间的通信，需要开放 Docker Swarm 所需的端口包括:
- 用于集群管理通信 : `2377/tcp`
- 用于集群节点间通信(集群节点之间数据和状态同步): `7946/tcp` 和 `7946/udp`
- 用于 overlay 网络(跨主机通信): `4789/udp` 。

注意:在配置防火墙规则时，需要确保这些端口在所有集群节点上都是开放的。

例如，在使用 firewall-cmd 命令的系统中，可以执行以下操作来开放这些端口：
```shell
firewall-cmd --zone=public --add-port=2377/tcp --permanent
firewall-cmd --zone=public --add-port=7946/tcp --permanent
firewall-cmd --zone=public --add-port=7946/udp --permanent
firewall-cmd --zone=public --add-port=4789/udp --permanent
firewall-cmd --reload
```

（2）只有受信任的用户才能控制docker守护进程
实现配置如下:
```shell
# 建议docker组中不包含root或者其他高权限用户。
groupadd docker
usermod -aG docker $USER   # 将当前低权限用户加入 docker 组
# 检查系统中用户组里的用户是否必须要加入docker组的用户
grep "docker" /etc/group
# >>> docker:x:994:root
```
（3）审计Docker
查看是否有audit审计应用
```shell
rpm -aq | grep audit
rpm -ql audit
# 查看规则
auditctl -l
# 查看命令帮助
auditctl -h
```
查看Docker守护进程的审核规则
```shell
auditctl -l | grep /usr/bin/docker
```
添加审计docker相关的文件和目录，例如 docker.service、/etc/default/docker、/etc/docker docker.socket、daemon.json等规则,在`/etc/audit/rules.d/audit.rules`文件最后添加如下内容:
```shell
## First rule - delete all
-D
## Increase the buffers to survive stress events.
## Make this bigger for busy systems
-b 8192
## Set failure mode to syslog
-f 1
## docker audit tules 添加docker审计规则
-w /usr/bin/docker -k docker
-w /usr/lib/systemd/system/docker.service -k docker
-w /usr/lib/systemd/system/docker.socket -k docker
-w /usr/bin/docker-containerd -k docker
-w /usr/bin/docker-runc -k docker
-w /etc/docker -k docker
-w /etc/docker/daemon.json -k docker
-w /var/lib/docker -k docker
-w /appdata/docker/lib/docker -k docker
```
重新启动审计守护进程
```shell
service auditd restart
```
检查是否添加成功
```shell
# 查看规则
auditctl -l
```
（4）更新 Docker swarm CA 证书日期
查看证书有效期时间
```shell
docker system info
```
更新CA证书并延长证书时间
```shell
# 99 years
docker swarm update --cert-expiry 867240h0m0s
# 更新swarm节点 （管理节点上运行）
docker swarm ca --rotate | openssl x509 -text -noout
```
（5）容器重启策略on-failure设置为5
描述: 在docker run命令中使用 --restart标志，可以指定重启策略，以便在退出时确定是否重启容器。基于安全考虑，应该设置重启尝试次数限制为5次。加固方法: 在docker run 或 docker-compos e中设定容器重启次数
```shell
# 在 Docker run 上使用 --restart 标志，您可以指定容器在退出时应该或不应该如何重新启动的重新启动策略。
docker run xxx --restart=on-failure:5  # 此处设置重试数为5次。

# 查看当前容器异常导致的重启次数
docker ps -q  -a | xargs docker inspect -f "{{ .RestartCount }}".

# 查看重启策略及其重试次数
docker ps -q  -a | xargs docker inspect --format '{{.Id}}:RestartPolicyName={{.HostConfig.RestartPolicy.Name}}, MaximumRetryCount={{.HostConfig.RestartPolicy.MaximumRetryCount}}'  
# 5d8e597549062d7709b667457e278e33f15221cb5c8e112bcbb648b3bca59f04:RestartPolicyName=always，MaximumRetryCount=0
# b28b6bd4264d9aad4eff7214df6d368c44b5c252a6d61bb7fd85ebc75ffdc957:RestartPolicyName=always，MaximumRetryCount=0
```
命令返回`RestartPolicyName=no`或仅`RestartPolicyName=`，则重新启动策略未被使用，容器不会重新启动; 命令返`RestartPolicyName=onfailure`，则通过查看`MaximumRetryCount`验证重新启动尝试的次数是否设置为5或更少。


