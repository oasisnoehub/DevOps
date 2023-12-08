# Minio

## Minio集群部署
### 部署架构

建议生产采用至少4节点(服务器),每节点2块磁盘的集群部署,磁盘越大越好了。
部署模式采用nginx【1+】+minIO分布式部署[4+]

![Alt text](image.png)

## 部署方式：
分布式MinIO
原因：单机MinIO存在单点故障
更多请参见：
http://docs.minio.org.cn/docs/master/distributed-minio-quickstart-guide
https://www.minio.org.cn/docs/minio/container/index.html
资源：
    考虑资源的有限，建议本次生产资源采用最小的申请，后续可根据情况水平扩容。
4节点，每个节点挂载2块以上的磁盘，每个磁盘空间10T+。这样N=4*2=8块磁盘
只要N/2=4在线，仍然可读  N/2+1=5可写
这样能够保证4个节点坏掉2个节点仍然可读，坏掉1个节点仍然可写。或者磁盘坏了4块仍然可读。保持5块可用仍然可写。

同时minIO采用的纠删码的方式实现高可用，它能够提供磁盘利用率，准且最高的数据冗余系数为2，磁盘和节点越多，利用率越高。
见：https://www.jianshu.com/p/0da45bc5cc0b

部署方式采用区的方式启动MinIO集群，利于后续水平扩容。

其他参考帖子：
http://docs.minio.org.cn/docs/master/distributed-minio-quickstart-guide 
https://blog.csdn.net/networken/article/details/112044111 
https://csdnnews.blog.csdn.net/article/details/114860023?spm=1001.2101.3001.6650.2&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-2.no_search_link&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-2.no_search_link
https://blog.51cto.com/u_14625168/category11.html 
https://blog.csdn.net/weixin_40816738/article/details/120400182
https://www.jianshu.com/p/79e1cb948253

```shell
docker network create --scope=swarm --attachable -d overlay minio-net
```