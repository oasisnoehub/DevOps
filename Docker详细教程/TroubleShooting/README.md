# 问题
## 解决docker磁盘空间不足
/root 一般不会挂载或者分配大的数据盘
/opt 可以
https://blog.csdn.net/qq_45473377/article/details/118889446

## Docker的/var/lib/docker文件夹占满了磁盘空间

先清理不必要的镜像和日志，然后再迁移目录
https://blog.csdn.net/zhangkunls/article/details/132751081?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-4-132751081-blog-118889446.235^v39^pc_relevant_3m_sort_dl_base4&spm=1001.2101.3001.4242.3&utm_relevant_index=7

## 集群部署-使用了纠删码的算法

