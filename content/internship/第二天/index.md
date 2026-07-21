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

---

## 我的进度：

### 任务1：磁盘挂载与本地APT仓库

#### 一、在VMware中添加硬盘

在VMware虚拟机设置中添加两块新硬盘（各20GB），用于后续挂载实验。

![image.png](image/image%201.png)

![image.png](image/image%206.png)

在虚拟机内操作，检查新添加的磁盘：

```bash
lsblk
```

可以看到添加成功，出现了 sdb 和 sdc 两块新磁盘。

![image.png](image/image%2010.png)

#### 二、创建第一个磁盘分区并挂载到 /mnt

1. 创建分区（假设为/dev/sdb）

```bash
sudo fdisk /dev/sdb
```

操作步骤：`n` -> `p` -> `1` -> 回车 -> 回车 -> `w`

![image.png](image/image%209.png)

- 输入 `n` —— New，新建分区
- 输入 `p` —— primary，创建**主分区**
- 分区号默认 1，起始扇区、结束扇区全部直接回车，**整块 20G 磁盘只分一个分区**
- 输入 `w` —— write，**把分区配置写入磁盘并保存退出**

2. 格式化分区

```bash
sudo mkfs.ext4 /dev/sdb1
```

`mkfs.ext4` = make filesystem ext4，给空白分区创建 ext4 文件系统。磁盘分区只是划分空间，必须格式化后才能存放文件、挂载使用。

![image.png](image/image%202.png)

3. 创建挂载点并挂载

```bash
sudo mkdir -p /mnt
sudo mount /dev/sdb1 /mnt
```

![image.png](image/image.png)

4. 持久化挂载（编辑fstab）

```bash
echo '/dev/sdb1 /mnt ext4 defaults 0 0' | sudo tee -a /etc/fstab
```

之前执行的 `sudo mount /dev/sdb1 /mnt` 是**临时挂载**，虚拟机重启后挂载会失效；写入 `/etc/fstab` 后，系统开机自动读取该文件，实现永久挂载。

![image.png](image/image%205.png)

#### 三、创建 /mnt/repository 并下载 MySQL 8.0 包

1. 创建repository目录

```bash
sudo mkdir -p /mnt/repository
```

2. 安装必要的工具

```bash
sudo apt update
sudo apt install -y wget gnupg2
```

> gnupg2（GNU Privacy Guard 2）：GPG 加密签名工具，用于生成、校验软件仓库的数字签名，消除 `apt update` 时的「仓库未签名」警告。

3. 下载MySQL官方APT仓库配置包

```bash
cd /mnt/repository
sudo apt install -y mysql-server-8.0
```

![image.png](image/image%207.png)

4. 生成仓库元数据

```bash
cd /mnt/repository
sudo apt install -y dpkg-dev
dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz
apt-ftparchive release . > Release
```

![image.png](image/image%2012.png)

![image.png](image/image%204.png)

5. 添加本地仓库源

```bash
echo "deb file:///mnt/repository ./" | sudo tee /etc/apt/sources.list.d/local-mysql-repo.list
```

![image.png](image/image%2011.png)

6. 更新软件包索引

```bash
sudo apt update
```

7. 验证是否成功

```bash
apt-cache policy mysql-server-8.0
```

![image.png](image/image%203.png)

#### 四、挂载第二个磁盘到 /mnt/repository 并安装 MySQL

**思考：当磁盘挂载到 /mnt/repository 时如何使用本地仓库？**

有两种解决方案：

**方案A：在挂载前下载包，挂载后使用**

1. 在挂载第二个磁盘之前，先下载所有包到 /mnt/repository

2. 创建第二个磁盘的分区和格式化（假设为/dev/sdc）

```bash
sudo fdisk /dev/sdc
# 操作：n -> p -> 1 -> 回车 -> 回车 -> w
sudo mkfs.ext4 /dev/sdc1
```

3. 备份现有 /mnt/repository 的内容

```bash
sudo cp -a /mnt/repository /tmp/mnt_repository_backup
```

4. 挂载第二个磁盘到 /mnt/repository

```bash
sudo mount /dev/sdc1 /mnt/repository
```

5. 复制备份的内容到新磁盘

```bash
sudo cp -a /tmp/mnt_repository_backup/* /mnt/repository/
```

6. 持久化挂载

```bash
echo '/dev/sdc1 /mnt/repository ext4 defaults 0 0' | sudo tee -a /etc/fstab
```

7. 确保仓库元数据正确

```bash
cd /mnt/repository
sudo dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz
sudo apt-ftparchive release . > Release
```

8. 更新软件包索引并安装MySQL

```bash
sudo apt update
sudo apt install -y mysql-server-8.0
```

**方案B：动态链接仓库路径**

1. 先挂载磁盘

```bash
sudo mount /dev/sdc1 /mnt/repository
```

2. 创建软链接到其他位置存放deb包

```bash
sudo mkdir -p /var/cache/repository-packages
sudo ln -s /var/cache/repository-packages /mnt/repository/.deb-cache
```

3. 下载包到缓存位置

```bash
cd /var/cache/repository-packages
sudo apt download mysql-server-8.0 mysql-client-8.0 mysql-common
```

4. 重新生成仓库元数据

```bash
cd /mnt/repository
sudo dpkg-scanpackages --multiversion . /dev/null | gzip -9c > Packages.gz
sudo apt-ftparchive release . > Release
```

5. 安装MySQL

```bash
sudo apt update
sudo apt install -y mysql-server-8.0
```

---

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

4. 通过PID反查进程所属服务

```bash
# 方法1：使用lsof查看进程打开的文件
sudo lsof -p <PID>

# 方法2：使用fuser查看进程使用的文件系统
sudo fuser /var/run/mysqld/mysqld.sock

# 方法3：使用systemd-cgls查看cgroup
systemd-cgls

# 方法4：使用cat查看进程的cgroup信息
cat /proc/<PID>/cgroup

# 方法5：使用systemctl status查看（最直接）
systemctl status <PID>
```

> **思考：拿到进程PID如何反过来查到进程所属服务？**
>
> 推荐方法：使用 `systemctl status <PID>`，systemd会自动识别PID所属的服务名称。
> 或者手动查询：`sudo systemctl list-units --type=service | grep -E "$(cat /proc/<PID>/cgroup | grep -o 'system.slice/.*' | cut -d'/' -f2)"`

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

![image.png](image/image%208.png)

2. 设置执行权限

```bash
sudo chmod +x /opt/scripts/backup_mysql_config.sh
```

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

8. 手动测试一次服务

```bash
sudo systemctl start mysql-config-backup.service
sudo journalctl -u mysql-config-backup.service
```

9. 查看备份结果

```bash
ls -la /var/backups/mysql/
```

> **思考其他实现方式：**
> - 方式1：使用 `crontab -e`，添加：`0 * * * * /opt/scripts/backup_mysql_config.sh`
> - 方式2：使用 at 命令（一次性任务，需要循环调用）
> - 方式3：使用 anacron（适合笔记本/不常开机的设备）
> - 方式4：使用第三方工具如 Jenkins/GitLab-CI 进行定时任务

#### 三、安装学习 supervisor 工具

1. 安装 supervisor

```bash
sudo apt update
sudo apt install -y supervisor
```

2. 启动并设置开机自启

```bash
sudo systemctl start supervisor
sudo systemctl enable supervisor
```

3. 检查服务状态

```bash
sudo systemctl status supervisor
```

4. 查看supervisor配置文件

```bash
ls -la /etc/supervisor/
cat /etc/supervisor/supervisord.conf
```

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

7. 重新加载supervisor配置

```bash
sudo supervisorctl reread
sudo supervisorctl update
```

8. 管理supervisor进程

```bash
sudo supervisorctl status all
sudo supervisorctl start test_program
sudo supervisorctl stop test_program
sudo supervisorctl restart test_program
sudo supervisorctl tail -f test_program
```

9. 查看supervisor管理的进程

```bash
ps aux | grep test_program
```

---

## 思考：Supervisor 与 systemd 的区别

| 特性 | Supervisor | Systemd |
|------|------------|---------|
| **设计目的** | 专注于进程管理、监控和自动重启 | 系统初始化和服务管理 |
| **进程监控** | 监控进程状态，自动重启崩溃进程 | 监控服务状态，但对单个进程监控较弱 |
| **日志管理** | 内置日志轮转和集中管理 | 依赖journald，日志分散 |
| **配置方式** | INI格式，简单直观 | Unit文件，功能强大但复杂 |
| **资源限制** | 支持进程级别的资源限制（CPU、内存） | 支持cgroup资源限制，功能更全面 |
| **网络管理** | 不支持 | 支持socket激活、网络配置等 |
| **依赖管理** | 简单的启动顺序控制 | 复杂的依赖关系管理 |
| **适用场景** | 单机应用、容器内进程管理 | 系统服务、需要复杂依赖管理的场景 |
| **学习曲线** | 简单，易于上手 | 功能强大，学习曲线较陡 |

**总结：**
- **Supervisor**：适合管理单个应用程序进程，特别是需要自动重启、日志管理的场景
- **Systemd**：适合系统级服务管理，需要复杂的依赖关系、资源控制、网络管理等场景
