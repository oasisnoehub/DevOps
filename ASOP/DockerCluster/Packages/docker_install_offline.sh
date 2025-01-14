#!/bin/bash

# ============================================================================
# Info: 离线安装Docker
# Prepare: 文件 | docker-25.0.3.tgz | docker.service
# =============================================================================
# 解决麒麟操作系统docker无法运行的问题
yum remove podman
# 开始离线安装docker
tar -zxvf ./docker-25.0.3.tgz

cp docker/* /usr/bin/

cp docker.service /etc/systemd/system/

chmod 777 /etc/systemd/system/docker.service

systemctl daemon-reload

systemctl enable docker

systemctl start docker

systemctl status docker

docker -v

docker info

# ============================================================================
# Info: 离线安装docker compose-
# Prepare: 文件 | docker-compose-linux-x86_64
# =============================================================================
mv docker-compose-linux-x86_64 docker-compose

mv docker-compose /usr/local/bin/

chmod +x /usr/local/bin/docker-compose

docker-compose -v
# docker compose --version
# =============================================================================