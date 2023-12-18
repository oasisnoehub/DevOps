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


