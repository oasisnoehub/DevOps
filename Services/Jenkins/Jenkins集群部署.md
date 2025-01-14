# Jenkins 集群部署（docker）

使用docker部署Jenkins，运行jenkins（blueocean版本）

创建jenkins本地挂载文件夹
```shell
#!/bin/bash
mkdir -p /mydata/jenkins/home
mkdir -p /mydata/jenkins/certs
mkdir -p /mydata/jenkins/maven
```
上传开发maven包到`/mydata/jenkins/maven`

![Alt text](assets/Jenkins%E9%9B%86%E7%BE%A4%E9%83%A8%E7%BD%B2/image.png)

修改`apache-maven-3.5.4`中setting文件，修改本地Maven包的地址
![Alt text](assets/Jenkins%E9%9B%86%E7%BE%A4%E9%83%A8%E7%BD%B2/image-1.png)

添加jenkins容器对本地jenkins文件的操作权限：
```shell
chown -R 1000:1000 /mydata/jenkins
```

创建jenkins集群网络
```shell
docker network create --scope=swarm --attachable -d overlay jenkins-network
```

部署jenkins集群
```shell
docker stack deploy -c jenkins-stack.yml jenkins
```