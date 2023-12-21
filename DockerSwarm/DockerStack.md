# Docker Stack

**使用compose文件部署stack**
```shell
docker stack deploy --compose-file <compose-file> <stack-name>

docker stack deploy -c <compose-file> <stack-name>
docker stack deploy -c <new-compose-file> <stack-name>
```

**查看部署的stack服务**
```shell
docker stack services <stack name>
```
**删除stack服务**
```shell
docker stack rm <stack name>
```
**使node离开swarm集群**
```shell
docker swarm leave --force
```

# docker stack 与 docker service的区别
参考文档：https://www.cnblogs.com/zjdxr-up/p/17627701.html
