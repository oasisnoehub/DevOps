#!/bin/bash
# 更新yum
yum -y update 
# 删除旧版本docker
yum remove docker  docker-common docker-selinux docker-engine
# 安装docker依赖包
yum install -y yum-utils device-mapper-persistent-data lvm2
# 配置仓库源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 安装docker-ce
yum -y install docker-ce
# 启动docker
systemctl start docker
# 开机自启
systemctl enable docker
