# push reject： not allowed to force push code to a protected branch on this project
设置gitlab的ssh key，添加本地访问机器的ssh密匙
![Alt text](assets/TroubleShooting/image.png)
暂时取消分支机构的保护。
Gitlab - Settings - Repository - Protected Branches - Unprotect
或者自己按需配置repo分支的push和merge规则
![Alt text](assets/TroubleShooting/image-1.png)
执行命令就可以push了, 本地repo配置的remote要一致
```shell
git push -u gitlab main -f
```
![Alt text](assets/TroubleShooting/image-2.png)