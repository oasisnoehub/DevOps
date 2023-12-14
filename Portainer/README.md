# Portainer

参考文档：https://www.cnblogs.com/netcore3/p/16978867.html

### 安装

>一、官网
>
>https://www.portainer.io/
>
>https://docs.portainer.io/v/ce-2.9/start/install/server/docker/linux
>
>二、步骤
>
>1. docker命令安装
>
>```shell
>
>  docker run -d -p 8000:8000 -p 9000:9000 --name myportainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/portainer/data:/data portainer/portainer
>```
>
>2. 第一次登录需创建admin，访问地址：xxx.xxx.xxx.xxx:9000
>
>```shell
>用户名，直接用默认admin 
>密码记得8位，随便你写 
>```
>
>3. 设置admin用户和密码后首次登陆
>4. 选择local选项卡后本地docker详细信息展示
>5. 上一步的图形展示，能想得起对应命令吗？
>6. 登陆并演示介绍常用操作case

# 创建portainer 环境
https://docs.portainer.io/admin/environments/add/swarm

## Install Portainer Agent on Docker Swarm
`Portainer uses the Portainer Agent container to communicate with the Portainer Server instance and provide access to the node's resources. `

- The manager and worker nodes must be able to communicate with each other over `port 9001`. In addition, the Portainer Server installation must be able to `reach the nodes on port 9001`. If this is not possible, we advise looking at the Edge Agent instead.

If Docker on the environment you're deploying the Agent to has the Docker volume path at a non-standard location (instead of /var/lib/docker/volumes) you will need to adjust the volume mount in the deployment command to suit. 
For example, if your volume path was /srv/data/docker, you would change the line in the command to:
```shell
--mount type=bind,src=//srv/data/docker,dst=/var/lib/docker/volumes \
```
The dst value of the mount should remain as `/var/lib/docker/volumes`, as that is what the Agent expects.

**创建portainer agent network**
```shell
docker network create \ 
--driver overlay \ 
--attachable \ 
protainer_agent_network
```
**创建portainer agent**
```shell
docker service create \
    --name portainer_agent \
    --network portainer_agent_network \
    -p 9001:9001/tcp \
    --mode global \
    --constraint 'node.platform.os == linux' \
    --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes \
    portainer/agent
```


# Portainer agent 管理 swarm 集群

https://zhuanlan.zhihu.com/p/575371623

## 安装Portainer
**选择一个manager节点，安装portainer:**
创建portainer网络
```shell
docker network create \
 --driver overlay \
 --attachable \
 --subnet 10.12.0.0/24 \
 portainer_agent_network
```
创建portainer
```shell
docker run -d -p 9000:9000 --name portainer \
 --network portainer_agent_net \
 --restart always \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v /docker/data/portainer:/data portainer/portainer
```

**在swarm集群上创建portainer_agent服务:**
```shell
docker service create \
    --name portainer_agent \
    --network portainer_agent_network \
    --mode global \
    --constraint 'node.platform.os == linux' \
    --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes \
    portainer/agent
```
**登入Portainer管理UI，添加Agent作为Swarm集群的统一EndPoint：**



