---
title: "第二天"
date: 2026-07-22
draft: false
tags: ["Linux", "文件系统", "systemd", "MySQL", "supervisor"]
categories: ["实习记录"]
summary: "文件系统、用户权限与包管理，Linux 服务、日志与进程管理"
---

## 主题：文件系统、用户权限与包管理，Linux 服务、日志与进程管理

## 学习目标：掌握文件系统类型、硬/软链接、挂载、用户组、sudo/su、apt/dpkg，dnf/yum/rpm。掌握 systemd服务管理、journalctl、rsyslog以及各类系统日志文件、ps/top/kill

## 当日任务：

1. 根据学习目标展开学习

2. 实操任务1：

    1. 分配两个磁盘给虚拟机，一个磁盘挂载至/mnt。

    2. 创建/mnt/repository目录，下载mysql8.0软件deb包以及相关依赖包到/mnt/repository目录下（不安装仅下载）。

    3. 将/mnt/repository做成本地apt仓库。

    4. 将另外一块磁盘挂载到/mnt/repository，挂载好后思考怎么在磁盘挂载的情况下使用刚刚做好的本地apt仓库安装mysql8.0

3. 实操任务2：

    - 启动mysql服务，获取到mysql服务下进程的pid。（思考拿到进程pid如何反过来查到进程所属服务）

    - 创建一个自定义systemd服务，服务能够实现定时每1个小时备份一次mysql的配置文件（思考其他实现方式）

    1. 安装学习supervisor工具，并思考supervisor与原生systemd服务的区别

## 我的进度：

### 任务1：挂载磁盘

#### 一：在Vmware中添加硬盘

![image](image/image%206.png)

![image](image/image%2026.png)

在虚拟机内操作（假设磁盘为/dev/sdb和/dev/sdc）：

检查新添加的磁盘

```shell
lsblk
```

可以看到添加成功

![image](image/image%2022.png)

2. 创建第一个磁盘的分区（/dev/sdb）

```shell
sudo fdisk /dev/sdb
# fdisk 是 Linux 磁盘分区工具，sudo fdisk /dev/sdb 表示操作你新增的第一块 20G 裸磁盘 sdb，给它创建分区表与可用分区。
```

操作：n -> p -> 1 -> 回车 -> 回车 -> w

![image](image/image%2031.png)

1. 输入 `n` —— New，新建分区

2. 输入 `p` —— primary，创建**主分区**（Linux 数据盘首选）

3. 分区号默认 1，起始扇区、结束扇区全部直接回车，**整块 20G 磁盘只分一个分区**，占满全部空间

4. 工具提示：成功创建 20G Linux 类型分区 `/dev/sdb1`

5. 输入 `w` —— write，**把分区配置写入磁盘并保存退出**

    - `The partition table has been altered.`：分区表修改完成

    - `Syncing disks.`：同步磁盘，内核识别新分区 `/dev/sdb1`

3. 格式化第一个磁盘

```shell
sudo mkfs.ext4 /dev/sdb1
```

`mkfs.ext4` = make filesystem ext4，作用是**给空白分区创建 ext4 文件系统**。 磁盘分区只是划分空间，必须格式化后才能存放文件、挂载使用。

![image](image/image%2027.png)

1. `Creating filesystem with 5242624 4k blocks and 1310720 inodes` 分配 4K 大小的数据块、inode 节点，用于存储文件数据与文件元信息。

2. `Filesystem UUID: 077c18a5-b9fd-4e92-8e8d-027cd7ec8424` 生成该分区唯一标识 UUID，

> 挂载时，UUID比直接写 /dev/sdb1 更稳定。

3. `Superblock backups stored on blocks` 超级块备份，ext4 会多处备份分区元数据，磁盘损坏时可恢复。

4. 末尾 4 行 `done` 代表格式化全流程完成：分配组表、写入 inode 表、创建日志、写入超级块信息全部执行完毕。

4. 创建挂载点并挂载

```shell
sudo mkdir -p /mnt
sudo mount /dev/sdb1 /mnt
```

![image](image/image.png)

5. 持久化挂载（编辑fstab）

```shell
echo '/dev/sdb1 /mnt ext4 defaults 0 0' | sudo tee -a /etc/fstab
# /etc/fstab 是 Ubuntu 系统的开机自动挂载配置文件，系统开机时会自动读取这个文件里所有条目，按规则挂载磁盘分区。 这条命令就是告诉系统：每次开机自动把 /dev/sdb1 挂载到 /mnt
```

![image](image/image%201.png)

之前执行的 `sudo mount /dev/sdb1 /mnt` 是**临时挂载**，虚拟机重启后挂载会失效； 写入 `/etc/fstab` 后，系统开机自动读取该文件，自动把 `/dev/sdb1` 挂载到 `/mnt`，实现永久挂载。

#### 二：创建/mnt/repository并下载MySQL 8.0包

1. 创建repository目录

```shell
sudo mkdir -p /mnt/repository
```

2. 安装必要的工具

```shell
sudo apt update
sudo apt install -y wget gnupg2
```

gnupg2

- 全称：GNU Privacy Guard 2，GPG 加密签名工具；

- 用途：生成、校验软件仓库的数字签名，消除执行`apt update`时的`仓库未签名`警告；

- 任务场景：制作本地 APT 仓库时，需要用它签名`Release`元数据文件，系统才能信任本地源并正常安装软件。

3. 下载MySQL官方APT仓库配置包（不安装）

```shell
cd /mnt/repository
```

```shell
sudo apt-get install --download-only -y mysql-server-8.0
# 包会下载到 /var/cache/apt/archives/，再复制到仓库目录
sudo cp /var/cache/apt/archives/mysql*.deb /mnt/repository/
```

再下载apt-utils 包

```shell
sudo apt install -y apt-utils dpkg-dev
```

4. 生成仓库元数据

```shell
cd /mnt/repository
dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz
apt-ftparchive release . > Release
```

![image](image/image%2029.png)

![image](image/image%2019.png)

5. 添加本地仓库源

```shell
echo "deb file:///mnt/repository ./" | sudo tee /etc/apt/sources.list.d/local-mysql-repo.list
```

![image](image/image%204.png)

6. 更新软件包索引

```shell
sudo apt update
```

7. 验证是否成功

```shell
apt-cache policy mysql-server-8.0
```

![image](image/image%2023.png)

##### 思考：将另外一块磁盘挂载到/mnt/repository，挂载好后思考怎么在磁盘挂载的情况下使用刚刚做好的本地apt仓库安装mysql8.0

解决方案：在挂载前下载包，挂载后使用

1. 在挂载第二个磁盘之前，先下载所有包到/mnt/repository

2. 挂载前备份

```shell
sudo cp -a /mnt/repository /tmp/repo-backup
```

3. 挂载第二块磁盘

```shell
sudo mount /dev/sdc1 /mnt/repository
```

4. 恢复内容

```shell
sudo cp -a /tmp/repo-backup/* /mnt/repository/
```

5. 重新生成元数据

```shell
cd /mnt/repository
sudo dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz
sudo apt-ftparchive release . > Release
```

6. 更新并安装

```shell
sudo apt update
sudo apt install -y mysql-server-8.0
```

### 任务2：MySQL服务管理与systemd

#### 一、启动MySQL服务并获取PID

1. 启动MySQL服务

```bash
sudo systemctl start mysql
```

2. 检查服务状态

```bash
sudo systemctl status mysql
```

![image](image/image%2015.png)

3. 获取MySQL进程PID

```bash
# 方法1：使用systemctl
systemctl show mysql -p MainPID

# 方法2：使用pgrep
pgrep mysql
# 或者
pgrep -a mysql

# 方法3：使用pidof
pidof mysqld

# 方法4：使用ps配合grep
ps aux | grep mysql
```

| 命令 | 优点 | 缺点 |
|---|---|---|
| systemctl show mysql -p MainPID | 直接获取服务主 PID，最标准 | 仅限 systemd 托管的服务 |
| pgrep | 简洁，支持模糊匹配 | 容易匹配到 mysql 客户端进程 |
| pidof mysqld | 精准匹配后台 mysqld 服务 | 需要记住进程名是 mysqld |
| ps aux | 信息完整，排错首选 | 输出杂乱，附带 grep 干扰进程 |

![image](image/image%208.png)

##### 思考：通过PID反查进程所属服务

- 1：直接传入 PID，一步输出服务名、运行状态、日志；

```shell
systemctl status 5110
```

![image](image/image%2010.png)

- 2：读取内核 /proc 虚拟文件

```shell
cat /proc/5110/cgroup
```

![image](image/image%203.png)

- 3：全局 cgroup 对照表检索

```shell
systemd-cgls | grep 5110
```

![image](image/image%2016.png)

- 4：通过进程打开的文件辅助判断

```shell
sudo lsof -p 5110
```

![image](image/image%2022.png)

#### 二、创建自定义systemd服务（定时备份MySQL配置）

1. 创建备份脚本

```bash
sudo mkdir -p /opt/scripts
sudo cat > /opt/scripts/backup_mysql_config.sh << 'EOF'
#!/bin/bash
# MySQL配置文件备份脚本

BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"
MYSQL_CONF_DIR="/etc/mysql/"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份主配置文件
cp $MYSQL_CONF $BACKUP_DIR/mysqld.cnf.$DATE.bak

# 备份整个配置目录（可选）
tar -czf $BACKUP_DIR/mysql_conf_$DATE.tar.gz $MYSQL_CONF_DIR

# 删除30天前的备份
find $BACKUP_DIR -name "*.bak" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "MySQL配置备份完成: $DATE"
EOF
```

![image](image/image%2033.png)

2. 设置执行权限

```bash
sudo chmod +x /opt/scripts/backup_mysql_config.sh
```

![image](image/image%2017.png)

3. 创建systemd服务单元文件

```bash
sudo cat > /etc/systemd/system/mysql-config-backup.service << EOF
[Unit]
Description=MySQL Configuration Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/scripts/backup_mysql_config.sh
User=root
Group=root
EOF
```

![image](image/image%2024.png)

4. 创建systemd定时器单元文件

```bash
sudo cat > /etc/systemd/system/mysql-config-backup.timer << EOF
[Unit]
Description=Run MySQL Config Backup Every Hour

[Timer]
OnCalendar=*-*-* *:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
```

![image](image/image%2029.png)

5. 重新加载systemd配置

```bash
sudo systemctl daemon-reload
```

6. 启用并启动定时器

```bash
sudo systemctl enable mysql-config-backup.timer
sudo systemctl start mysql-config-backup.timer
```

7. 检查定时器状态

```bash
sudo systemctl status mysql-config-backup.timer
sudo systemctl list-timers
```

![image](image/image%202.png)

8. 手动测试一次服务

```bash
sudo systemctl start mysql-config-backup.service
sudo journalctl -u mysql-config-backup.service
```

![image](image/image%207.png)

9. 查看备份结果

```bash
ls -la /var/backups/mysql/
```

![image](image/image%205.png)

##### 思考：其他实现方式：

- 方式1：使用 `crontab -e`，添加：`0 * * * * /opt/scripts/backup_mysql_config.sh`

- 方式2：使用 at 命令（一次性任务，需要循环调用）

- 方式3：使用 anacron（适合笔记本/不常开机的设备/最小单位是天，不能做到按小时定时）

- 方式4：使用第三方工具如 Jenkins/GitLab-CI 进行定时任务

#### 三、安装学习 supervisor 工具

1. 安装 supervisor

```bash
sudo apt update
sudo apt install -y supervisor
```

![image](image/image%2018.png)

2. 启动并设置开机自启

```bash
sudo systemctl start supervisor
sudo systemctl enable supervisor
```

![image](image/image%208.png)

3. 检查服务状态

```bash
sudo systemctl status supervisor
```

![image](image/image%2015.png)

4. 查看supervisor配置文件

```bash
ls -la /etc/supervisor/
cat /etc/supervisor/supervisord.conf
```

![image](image/image%2026.png)

5. 使用supervisor管理一个示例程序

创建测试程序：

```bash
cat > /opt/scripts/test_program.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date): Hello from Supervisor" >> /var/log/test_program.log
    sleep 10
done
EOF
chmod +x /opt/scripts/test_program.sh
```

![image](image/image%2025.png)

6. 创建supervisor配置文件

```bash
sudo cat > /etc/supervisor/conf.d/test_program.conf << EOF
[program:test_program]
command=/opt/scripts/test_program.sh
directory=/opt/scripts
autostart=true
autorestart=true
stderr_logfile=/var/log/test_program.err.log
stdout_logfile=/var/log/test_program.out.log
user=root
EOF
```

![image](image/image%2030.png)

7. 重新加载supervisor配置

```bash
sudo supervisorctl reread
sudo supervisorctl update
```

![image](image/image%206.png)

8. 管理supervisor进程

```bash
sudo supervisorctl status all
sudo supervisorctl start test_program
sudo supervisorctl stop test_program
sudo supervisorctl restart test_program
sudo supervisorctl tail -f test_program
```

![image](image/image%2023.png)

![image](image/image.png)

9. 查看supervisor管理的进程

```bash
ps aux | grep test_program
```

![image](image/image%2012.png)

##### 思考：supervisor与原生systemd服务的区别

| 特性 | Supervisor | Systemd |
|---|---|---|
| **设计目的** | 专注于进程管理、监控和自动重启 | 系统初始化和服务管理 |
| **进程监控** | 监控进程状态，自动重启崩溃进程 | 监控服务状态，但对单个进程监控较弱 |
| **日志管理** | 内置日志轮转和集中管理 | 依赖 journald，日志分散 |
| **配置方式** | INI 格式，简单直观 | Unit 文件，功能强大但复杂 |
| **资源限制** | 支持进程级别的资源限制（CPU、内存） | 支持 cgroup 资源限制，功能更全面 |
| **网络管理** | 不支持 | 支持 socket 激活、网络配置等 |
| **依赖管理** | 简单的启动顺序控制 | 复杂的依赖关系管理 |
| **适用场景** | 单机应用、容器内进程管理 | 系统服务、需要复杂依赖管理的场景 |
| **学习曲线** | 简单，易于上手 | 功能强大，学习曲线较陡 |

- Supervisor：适合管理单个应用程序进程，特别是需要自动重启、日志管理的场景

- Systemd：适合系统级服务管理，需要复杂的依赖关系、资源控制、网络管理等场景
