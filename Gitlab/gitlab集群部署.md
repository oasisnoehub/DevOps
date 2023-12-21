# 创建gitlab集群

首先创建gitlab集群volume存储地址：
```shell
sh gitlab-volume-creator.sh
```

创建gitlab集群网络
```shell
docker network create --scope=swarm --attachable -d overlay gitlab-network
```
部署文件准备
- gitlab配置文件：`gitlab.rb`
- root账户登录密码：`root_password.txt`
- gitlab集群编排文件： `gitlab-stack.yml`
> 注意：将`gitlab.rb`，`root_password.txt` 以及 `gitlab-stack.yml` 放在同一路径下,并修改 `gitlab.rb` 文件的external_url外部访问地址，否则外部无法访问启动的gitlab服务。`root_password.txt` ：设置root账户密码，`gitlab-stack.yml`：gitlab集群编排文件

使用 docker stack 进行部署（在上述文件路径下执行stack部署命令）
```shell
docker stack deploy -c gitlab-stack.yml gitlab
```