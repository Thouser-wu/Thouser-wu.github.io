+++
date = '2026-03-25T18:58:08+08:00'
draft = false
title = 'Docker & Kubernetes 常用指令手册'
+++
## 1. Docker 服务管理
### 启动与状态
+ **启动 Docker 服务**:

```bash
sudo systemctl start docker
```

+ **设置开机自启**:

```bash
sudo systemctl enable docker.service
```

+ **查看运行状态** (需 root 权限):

```bash
systemctl status docker.service
```

+ **查看版本信息**:

```bash
docker version
```

+ **查看概要信息**:

```bash
docker info
```

+ **检查配置文件**:

```bash
cat /etc/docker/daemon.json
```

+ **查看帮助文档**:

```bash
docker --help
```

### 卸载 Docker
1. **停止服务**:

```bash
systemctl stop docker.service
ps -ef | grep docker
```

2. **删除安装目录**:

```bash
rm -rf /etc/docker
rm -rf /run/docker
rm -rf /var/lib/dockershim
rm -rf /var/lib/docker
```

3. **查看依赖包**:

```bash
yum list installed | grep docker
```

4. **删除依赖包**:

```bash
yum remove docker-common.x86_64
yum remove docker-client.x86_64
yum remove docker.x86_64
```

5. **验证卸载**:

```bash
docker version
systemctl start docker.service
# 若卸载成功，上述命令应报错
```

---

## 2. Docker 镜像操作
+ **查看本地镜像**:

```bash
docker images
```

+ **查看所有镜像** (包含中间层/历史镜像):

```bash
docker images -a
```

+ **拉取镜像**:

```bash
docker pull <镜像名称>[:tag]
# 示例:
docker pull mysql:5.7.25
```

+ **删除镜像**:

```bash
docker rmi <镜像名字或ID>
```

+ **清理虚悬镜像** (Dangling Images):

```bash
docker image prune
```

+ **将容器保存为新镜像**:

```bash
docker commit -m "<描述信息>" -a "<作者名字>" <容器ID> <新镜像名>:<标签>
# 示例:
docker commit -m="add vim" -a="name" 65a4b2521717 centos-with-vim:1.0.0
```

> **注意**: `docker commit` 是手动创建镜像的方式，可重复性弱且难以审计。生产环境建议使用 `Dockerfile` 构建。
>

---

## 3. Docker 容器操作
### 启动容器
+ **启动已存在的停止容器**:

```bash
docker start <容器名称或ID>
```

+ **创建并启动新容器**:
    - **前台交互式启动** (进入后直接操作容器):

```bash
docker run -it <镜像ID或名称> /bin/bash
```

    - **后台守护式启动**:

```bash
docker run -d -t <镜像ID或名称> /bin/bash
# 示例:
docker run -d centos-with-ifconfig:latest /bin/bash
```

> **进入后台容器**: `docker exec -it <容器名称> /bin/bash`
>

### 进入与退出容器
+ **进入容器**:

```bash
docker exec -it <容器ID或名称> /bin/bash
```

+ **退出容器方式**:
    1. **推荐方式** (`Ctrl + p` 然后 `q`): 退出终端但**不停止**容器。
    2. **普通方式** (`exit` 或 `Ctrl + d`):
        * 若是前台启动 (`docker run -it`)，会**停止**容器。
        * 若是通过 `exec` 进入的新终端，退出后容器**继续运行**。

### 停止与删除
+ **查看运行中的容器**:

```bash
docker ps
```

+ **查看所有容器** (含已停止):

```bash
docker ps -a
```

+ **停止容器**:

```bash
docker stop <容器ID或名称>
```

+ **删除容器**:

```bash
docker rm <容器名称或ID>
```

### 文件复制
+ **宿主机 -> 容器**:

```bash
docker cp <宿主机文件路径> <容器ID>:<容器内路径>
# 示例:
docker cp Dockerfile 3a7d0b590c18:/root
```

+ **容器 -> 宿主机**:

```bash
docker cp <容器ID>:<容器内文件路径> <宿主机目标路径>
# 示例:
docker cp 3a7d0b590c18:/root/anaconda-ks.cfg /root/test/anaconda-ks.cfg
```

---

## 4. Docker 网络
+ **查看网络列表**:

```bash
docker network ls
```

> 默认安装后会自动创建 `bridge`, `host`, `none` 三个网络。
>

---

## 5. Kubernetes (k8s) 常用指令
### Pod 管理
+ **查看 Pod 列表**:

```bash
kubectl get pod
```

+ **查看 Pod 详细信息** (含所在节点):

```bash
kubectl get pods -o wide
```

+ **根据标签查看 Pod**:

```bash
kubectl get pods -l <label-key>=<label-value>
```

+ **查看 Pod 日志**:

```bash
kubectl logs <pod-name>
```

+ **查看 Pod 详细描述** (用于排查问题):

```bash
kubectl describe pod <pod-name>
```

### 应用部署与服务
+ **应用 YAML 配置**:

```bash
kubectl apply -f <文件名.yaml>
```

+ **查看 Service 详细信息及访问地址**:

```bash
kubectl get svc
# 示例:
kubectl get svc helloworld-env-service
```

### 删除资源
+ **根据 YAML 删除**:

```bash
kubectl delete -f <文件名.yaml>
```

+ **删除 Deployment**:

```bash
kubectl delete deployment <deployment-name>
```

+ **删除 Pod**:

```bash
kubectl delete pod <pod-name>
```





