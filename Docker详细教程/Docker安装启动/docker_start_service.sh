#!/bin/bash

# 启动所有部署的docker服务
systemctl start docker

docker restart myjenkins
docker restart gitlab

cd ~/harbor
./install.sh --with-trivy --with-chartmuseum
