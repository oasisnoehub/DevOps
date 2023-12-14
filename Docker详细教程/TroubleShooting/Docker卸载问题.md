# Docker 卸载

## 卸载步骤
```shell
yum remove docker-ce \
           docker-ce-cli \
           containerd
      
```


### rm: 无法删除"docker/lib/docker/devicemapper/mnt/xxxxx": 设备或资源忙

查看docker挂载情况
```shell
cat /proc/mounts | grep "docker"
```
针对挂载的路径使用unmount命令进行卸载
```shell
unmount <挂载的路径>
```
然后使用`rm -rf`命令删除文件
```shell
rm -rf /etc/systemd/system/docker.service.d
rm -rf /etc/systemd/system/docker.service
rm -rf /var/lib/docker
rm -rf /var/run/docker
rm -rf /usr/local/docker
rm -rf /etc/docker
rm -rf /usr/bin/docker* /usr/bin/containerd* /usr/bin/runc /usr/bin/ctr
# 还有删除其他相关之前容器服务挂载的volumes
```

