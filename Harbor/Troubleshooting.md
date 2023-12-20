# TroubleShooting
## 设备更换ip地址后，启动harbor导致宿主机无法ssh的问题

使用其他机器远程ssh宿主机
```shell
ssh 172.20.220.18 -l root
# 输入yes
# 输入root ssh密码登入宿主机进行操作
```
![Alt text](assets/Troubleshooting/image.png)

停止harbor服务
```shell
cd ~/harbor
docker compose down
```
删除~/harbor文件夹，然后重新安装harbor（最简单直接的方法）

