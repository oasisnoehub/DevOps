# Centos 7 安装 Docker 步骤（流畅安装版）
https://cloud.tencent.com/developer/article/1701451

`重要： 更新 yum 包 (否则后面版本改错改到想哭)`
```shell
yum -y update 
```

卸载旧版本Docker
```shell
yum remove docker  docker-common docker-selinux docker-engine
```
安装docker依赖包
```shell
yum install -y yum-utils device-mapper-persistent-data lvm2
```
添加镜像仓库源
```shell
yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo（中央仓库）

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo（阿里仓库）
```

安装docker-ce
```shell
yum -y install docker-ce
```

开启docker
```shell
# 启动docker
systemctl start docker
# 开机自启
systemctl enable docker
```