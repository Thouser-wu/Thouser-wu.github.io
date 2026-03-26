+++
date = '2026-03-26T08:43:23+08:00'
draft = false
title = 'Mysql常用指令'
+++

# MySQL 常用指令

## 一、数据库连接与基础操作

### 1. 连接与退出
```sql
-- 连接 MySQL
mysql -u root -p

-- 登录数据库
mysql -uroot -p

-- 退出数据库
exit
quit
```

### 2. 服务器信息
```sql
-- 查看服务器版本
select version();

-- CMD 命令查看版本
mysql --version
```

### 3. 数据库操作
```sql
-- 查看当前系统下的数据库
show databases;

-- 创建数据库
create database 库名;

-- 使用数据库
use 库名;

-- 删除数据库
drop database 库名;
```

### 4. 表操作
```sql
-- 查看表
show tables;

-- 查看其他数据库的表
show tables from 数据库名;

-- 创建表
create table 表名 (
    字段名 数据类型,
    字段名 数据类型
);

-- 查看表结构
desc 表名;

-- 查看建表结构
show create table 表名;

-- 删除表
drop table 表名;

-- 修改表名
alter table 旧表名 rename 新表名;
```

---

## 二、用户管理

```sql
-- 查询用户（命令行）
select user,host from mysql.user;

-- 删除用户
drop user 'user_11'@'%';
```

**默认端口号：** 3306

---

## 三、数据操作（CRUD）

### 1. 增加数据
```sql
insert into 表名 (列名) values (值);
```

### 2. 删除数据
```sql
-- 删除表中所有数据
delete from 表名;

-- 删除表中符合条件的数据
delete from 表名 where 条件;

-- 删除表的字段
alter table 表名 drop column 字段名;
-- 或
alter table 表名 drop 字段名;
```

### 3. 查询数据
```sql
-- 查询表中所有数据
select * from 表名;

-- 条件查询
select * from 表名 where 条件;
```

### 4. 修改数据
```sql
update 表名 set 字段=新值 where 条件;
```

---

## 四、WHERE 条件查询

### 1. 精确查询
```sql
=、!=、<>、>、<、>=、<=
```

### 2. 模糊查询
```sql
-- like：像
-- not like：不像

-- 通配符
%：任意字符
_：单个字符
```

### 3. 逻辑运算符
```sql
-- and：同时满足（优先级大于 or）
-- or：满足任意条件即可
```

### 4. 区间运算
```sql
-- between a and b（闭区间）
select * from 表名 where 字段 between 值 1 and 值 2;
```

### 5. 集合运算
```sql
in、not in
```

### 6. 非空运算
```sql
is null、is not null
```

---

## 五、排序与限制

### 1. 排序
```sql
-- order by：排序
-- asc：升序
-- desc：降序

-- 示例
select * from 表名 order by 列名 1 asc, 列名 2 desc;
```

### 2. 限制查询结果条数
```sql
-- 传一个参数（输出前 5 条数据）
select * from 表名 limit 5;

-- 传两个参数（输出第 6-15 条数据）
select * from 表名 limit 5,10;
-- 5：从第 5 条后开始（偏移量）
-- 10：条数
```

---

## 六、聚合函数

### 1. SUM() 函数 - 求和
```sql
select sum(字段名) as 别名 from 表名;
```

### 2. COUNT() 函数 - 计数
```sql
-- count(*)：计算表中总的行数，不管某列是否有数值或为空
select count(*) from 表名;

-- count(字段名)：计算指定列下总的行数，将忽略空值
select count(字段名) from 表名;
```

### 3. AVG() 函数 - 平均值
```sql
select avg(字段名) as 别名 from 表名;
```

### 4. MAX() 函数 - 最大值
```sql
select max(字段名) as 别名 from 表名;
```

### 5. MIN() 函数 - 最小值
```sql
select min(字段名) as 别名 from 表名;
```

---

## 七、分组查询

```sql
-- group by：按一列/多列的值分组，值相等为一组
select 列名 1, count(列名 2) as 别名 from 表名 group by 列名 1;

-- having：二次判断，用于聚合函数后的筛选
select 列名 1, count(列名 2) as 别名 from 表名 
group by 列名 1 
having 别名 > 2;
```

---

## 八、表结构修改

### 1. 修改字段
```sql
-- 修改字段名
alter table 表名 change id sid char;

-- 修改列类型
alter table 表名 modify 列名 char(20);
```

### 2. 添加字段
```sql
-- 添加单列
alter table 表名 add 列名 char;

-- 添加多列
alter table 表名 add(xh int(4), zc char(8), ads char(50));

-- 添加字段设主键约束（自增）
alter table 表名 add id int unsigned primary key auto_increment;
```

### 3. 删除字段
```sql
-- 删除单列
alter table 表名 drop 列名;

-- 删除多列
alter table 表名 drop xh, drop zc, drop ads;
```

---

## 九、约束类型

| 约束类型 | 关键字 |
|---------|--------|
| 主键约束 | primary key |
| 唯一约束 | unique |
| 非空约束 | not null |
| 默认约束 | default |
| 外键约束 | foreign key (外键) references 主表 (主键) |

---

## 十、关联查询

### 1. 等值查询
```sql
select * from 表名 where a.id=b.id and 条件;
```

### 2. 内连接（INNER JOIN）
```sql
select * from 表名 1 inner join 表名 2 on 表名 1.xh=表名 2.xh where 条件;
```

### 3. 左连接（LEFT JOIN）
```sql
select * from 表名 1 left join 表名 2 on 表名 1.xh=表名 2.xh where 条件;
```

### 4. 右连接（RIGHT JOIN）
```sql
select * from 表名 1 right join 表名 2 on 表名 1.xh=表名 2.xh where 条件;
```

---

## 十一、索引优化

> 原文链接：https://blog.csdn.net/dengchenrong/article/details/88425762

### 索引创建原则

1. **避免全表扫描**：首先应考虑在 `where` 及 `order by` 涉及的列上建立索引

2. **经常检索的字段**：在经常需要进行检索的字段上创建索引，比如要按照表字段 username 进行检索

3. **索引数量控制**：一个表的索引数最好不要超过 6 个，若太多则应考虑一些不常使用到的列上建的索引是否有必要

### 创建索引
```sql
-- 普通索引
create index 索引名 on 表名 (字段名);

-- 唯一索引
create unique index 索引名 on 表名 (字段名);

-- 主键索引
alter table 表名 add primary key (字段名);
```
