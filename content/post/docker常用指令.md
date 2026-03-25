+++
date = '2026-03-25T18:58:08+08:00'
draft = false
title = 'Docker常用指令'
+++
**启动docker服务**:sudo systemctl start docker

**设置 Docker 服务开机自启**：sudo systemctl enable docker.service

**查看docker 运行状态**: systemctl  status docker.service    (使用root权限)

**查看docker版本**: docker version

**检查 daemon.json 配置** cat /etc/docker/daemon.json



**卸载 docker**

1）停止docker：

systemctl  stop docker.service

ps -ef | grep docker



2）删除docker安装目录：

 rm -rf /etc/docker

 rm -rf /run/docker

 rm -rf /var/lib/dockershim

 rm -rf /var/lib/docker



3）查看docker依赖包

 docker list installed | grep docker



4）把匹配到的包执行 yum remove 删除

 yum remove docker-common.x86\_64

yum remove docker-client.x86\_64

yum remove docker.x86\_64



5)查看docker是否卸载完毕

docker version

systemctl start docker.service



**3.docker 常见命令操作**



3.1 帮助启动类命令



1）**启动docker**：systemctl start docker



2\)   **停止docker**：systemctl stop docker



3）\*\*停止docker：\*\*systemctl restart docker



4）**查看docker运行状态**：systemctl status docker



5）\*\*开机自启动docker：\*\*systemctl enable docker



6）\*\*查看docker概要信息：\*\*docker  info



7\)  **查看docker总体帮助文档：** docker --help











**查看镜像**：docker images

\*\*查看所有镜像，包含历史镜像：\*\*docker images -a

\*\*拉取镜像：\*\*docker pull 镜像名称\[:tag] docker pull mysql:5.7.25

\*\*删除镜像：\*\*docker rmi 某个XXX镜像名字ID

**使用  prune 删减虚悬镜像** docker image prune





**启动已有容器:** docker start <容器名称或ID>

**第一种方式:前台交互式启动容器：** docker run -it "ID" /bin/bash

这种的启动后会直接进入容器

\*\*第二种:后端守护式：\*\*docker run -d -t  "ID"  /bin/bash

例如：docker run -d centos-with-ifconfig:latest /bin/bash

这种的需要exec进入 docker exec -it container\_name /bin/bash

退出容器方式：exit（会关闭容器） 或者 ctr+d（容器不会被关闭）



exec 是在容器中打开新的终端，并且可以启动新的进程

因为是新终端，用exit退出，不会导致容器的停止。



**docker start是启动一个存在的但已经关闭的容器，docker run是启动一个镜像，先搜索本地是否存在这个镜像，如果没有就拉取，有的话就以此创建一个容器，有前端交互式启动和后台守护式两种**



**停止容器**：

docker ps

docker stop 959f6b83b0db

docker ps -a | grep 959f6b83b0db



**第一种退出容器方式**：ctrl+p+q 这种方式不会停止容器，官方建议使用最终方式

**第二种退出容器方式**：exit 或者 ctr+d这种方式会停止容器(后台启动的容器不会停止还是会挂起)





\*\*删除容器：\*\*docker rm mycentos1或者使用容器 ID docker rm abcdef123456



\*\*进入容器：\*\*docker exec -it 3a7d0b590c18 /bin/bash

**从宿主机docker 复制文件到容器:**

docker cp Dockerfile 3a7d0b590c18:/root

docker exec -it 3a7d0b590c18 /bin/bash



\*\*从容器复制文件到宿主机:\*\*docker cp 3a7d0b590c18:/root/anaconda-ks.cfg /root/test/anaconda-ks.cfg



**查看容器命令**:docker ps -a





**将容器保存为镜像**:docker commit -m="名字" -a="作者名字？" 65a4b2521717 centos-with-vim:1.0.0

缺点:

1）docker commit是一种手动创建镜像的方式，容易出错，效率低且可重复性弱。

例如: 在ubuntu base镜像中要加入vim, 还需要重复前面的所有步骤。

2）使用者不知道镜像如何创建出来的，无法对镜像进行审计，存在安全隐患。

优点:

镜像的底层都是使用docker commit一层一层构建新镜像的。使用docker commit命令，能够使我们更加深入的理解镜像的构建过程和镜像的分层结构。





**查看docker网络**：docker network ls   使用 docker network ls 命令，查看Docker安装后，自动在主机创建的三个网络。





k8s

**查看pod:** kubectl get pod

**应用yaml:** kubectl apply -f ...

**查看pod日志**: kubectl logs ...

**描述pod**:kubectl describe pod

**查看 Pod 所在节点**:kubectl get pods -l

**查看pod运行在哪个节点**:kubectl get pods -o wide

**查看Service详细信息**,\*\*获取访问地址：\*\*kubectl get svc 例如(kubectl get svc helloworld-env-service)

**根据yaml删除deployment和service:** kubectl delete -f .yaml

**删除 deployment:** kubectl delete deployment ...

**删除 pod:** kubectl delete pod ...




