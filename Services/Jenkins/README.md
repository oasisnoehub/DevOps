# Jenkins

参考文档：https://www.jenkins.io/doc/book/installing/docker/

## 使用docker部署jenkins
使用docker部署Jenkins，运行jenkins（blueocean版本）
```shell
# 拉取jenkins镜像
docker pull jenkinsci/blueocean
# 运行jenkins实例
```shell
docker  run   -d -u root   -p 8080:8080   -v /usr/local/jenkins:/var/jenkins_home   -v /var/run/docker.sock:/var/run/docker.sock  -v "$HOME":/home -v /usr/local/apache-maven-3.5.4:/usr/local/maven  --name myjenkins jenkinsci/blueocean:latest
```
# 查看运行jenkins容器日志
docker logs myjenkins
```

