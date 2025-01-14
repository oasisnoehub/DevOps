# 集群环境部署操作前置条件文档说明手册

## 文档版本信息

| 版本号 | 编辑日期   | 修改人  | 内容描述                    | 审核人  |
|--------|------------|---------|-----------------------------|---------|
| 1.0.0  | 2025-01-14 | 尹艺玲  | 适用于 Docker 集群微服务部署架构 | 尹艺玲  |

---

## 文档目录
1. **系统要求**

2. **网络设置**

3. **软件与工具准备**

4. **安全与权限配置**

---

### 1. 系统要求

在部署集群前，请确保目标系统满足以下要求：

（1）操作系统版本：
- 推荐使用 CentOS 7 或更高版本，或其他支持 Docker 的 Linux 发行版。

（2）硬件要求：

- CPU：双核及以上。

- 内存：至少 4GB。

- 磁盘空间：至少 100GB 可用空间。

（3）**时间同步（重点）**：

- 配置 NTP 服务，确保系统时间同步。
```
# 参考配置：
yum install -y ntp
systemctl enable ntpd
systemctl start ntpd
```

### 2. 网络设置
（1）IP 地址分配：

- 确保每个节点有固定的 IP 地址。

（2）防火墙规则：

- 开放 Docker Swarm 所需的端口：
```bash
firewall-cmd --add-port=2377/tcp --permanent
firewall-cmd --add-port=7946/tcp --permanent
firewall-cmd --add-port=7946/udp --permanent
firewall-cmd --add-port=4789/udp --permanent
firewall-cmd --reload
```
（3）DNS 配置：

- 确保节点可以正确解析主机名。

### 3. 软件与工具准备

离线安装文件：
- 准备 Docker 引擎，版本建议为 20.10 或以上。
- 准备好 Docker 和相关工具的安装包，以应对无网络环境。
【1】Docker离线安装文件；
【2】必要服务安装镜像：Portainer, MinIO, Nginx, Harbor, Seata, etc；
【3】微服务包以及相关配置文件。

### 4. 安全与权限配置

（1）用户权限：

- 创建专用用户组并将部署用户加入 Docker 组：
```bash
groupadd docker
usermod -aG docker $USER
```
（2）SSH 配置：
配置免密登录以简化节点之间的操作：
```bash
ssh-keygen -t rsa -b 2048
ssh-copy-id user@<target-node>
```
（3）系统更新与补丁：
确保所有节点已安装最新的安全补丁
```bash
yum update -y
```


