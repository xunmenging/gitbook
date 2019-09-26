[TOC]

# linux基本知识

- linux系统垃圾桶，/dev/null 是linux下的一个设备文件，这个文件类似于一个垃圾桶，特点是：容量无限大

# 常用命令

## 命令的使用方法

**linux命令格式**

```shell
command  [-options]  [parameter1]  … 
说明：
	command：命令名，相应功能的英文单词或单词的缩写
	[-options]：选项，可用来对命令进行控制，也可以省略，[]代表可选
	parameter1 …：传给命令的参数，可以是零个一个或多个

```

### 查看帮助文档

#### --help

一般是 Linux 命令自带的帮助信息，并不是所有命令都自带这个选项。如我们想查看命令 ls 的用法：**ls --help**

#### man

```shell
1．Standard commands（标准命令）
2．System calls（系统调用，如open,write）
3．Library functions（库函数，如printf,fopen）
4．Special devices（设备文件的说明，/dev下各种设备）
5．File formats（文件格式，如passwd）
6．Games and toys（游戏和娱乐）
7．Miscellaneous（杂项、惯例与协定等，例如Linux档案系统、网络协定、ASCII 码；environ全局变量）
8．Administrative Commands（管理员命令，如ifconfig） 
```

**man使用格式如下：**

```shell
man [选项]  命令名
```

**man设置了如下的功能键：**

| **功能键** | **功能**             |
| ---------- | -------------------- |
| 空格键     | 显示手册页的下一屏   |
| Enter键    | 一次滚动手册页的一行 |
| b          | 回滚一屏             |
| f          | 前滚一屏             |
| q          | 退出man命令          |
| h          | 列出所有功能键       |
| /word      | 搜索word字符串       |

![](linux%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86.assets/man.jpg)

**使用 man 手册时，最好指定章节号：**

```shell
man 3 printf
```

## 常用命令

### 文件管理

#### 查看文件信息：ls

![](linux%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86.assets/ls.png)

#### 清屏：clear 

```shell
clear作用为清除终端上的显示(类似于DOS的cls清屏功能)，也可使用快捷键：Ctrl + l ( “l” 为字母 )。
```

### 网络访问

#### curl

- curl 访问https，

  ```shell
  curl -X GET -k --header 'Accept: application/json' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NjI0MDQwMjcsInVzZXJfbmFtZSI6InBsYXRmb3JtX2FkbWluIiwiYXV0aG9yaXRpZXMiOlsicGxhdGZvcm1fYXBwX2FkZEFwcCIsInBsYXRmb3JtX2FwcF9iaW5kQXV0aEdyb3VwMk1lbnUiLCJwbGF0Zm9ybV9hcHBfZGVsZXRlTWVudSIsInBsYXRmb3JtX2FwcF9wYWdlQWxsQXV0aG9yaXRpZXMiLCJwbGF0Zm9ybV9hcHBfYWRkQXV0aG9yaXR5R3JvdXAiLCJwbGF0Zm9ybV9hcHBfYWxsQXBwcyIsInBsYXRmb3JtX3VzZXIiLCJwbGF0Zm9ybV9hcHBfY2hpbGRBY2NvdW50TWFuYWdlbWVudCIsInBsYXRmb3JtX2FwcF9kZWxldGVBdXRob3JpdHkiLCJwbGF0Zm9ybV9hcHBfY3JlYXRlQ2hpbGRBY2NvdW50IiwicGxhdGZvcm1fYXBwX2FkZE1lbnUiLCJwbGF0Zm9ybV9hcHBfbWFuYWdlbWVudCIsInBsYXRmb3JtX2FwcF9jaGlsZFVzZXJzIiwicGxhdGZvcm1fYXBwX21lbnVNYW5hZ2VtZW50IiwicGxhdGZvcm1fYXBwX2JpbmRBdXRoMlVzZXIiLCJwbGF0Zm9ybV9hZG1pbiIsInBsYXRmb3JtX2FwcF9hbGxBdXRob3JpdGllcyIsInBsYXRmb3JtX2FwcF9nZXRNZW51IiwicGxhdGZvcm1fYXBwIiwicGxhdGZvcm1fdXNlcl9iYXRjaFJlZ2lzdGVyIiwicGxhdGZvcm1fYXBwX2FsbE1lbnVzIiwicGxhdGZvcm1fcmVzZXRQd2QiLCJwbGF0Zm9ybV9tZW51IiwicGxhdGZvcm1fYXBwX2JpbmRBdXRoMkF1dGhHcm91cCIsInBsYXRmb3JtX2FwcF9nZXRBcHAiLCJwbGF0Zm9ybV9hcHBfYXBwTGlzdCIsInBsYXRmb3JtX2FwcF9iaW5kQXV0aEdyb3VwMlVzZXIiLCJwbGF0Zm9ybV9hcHBfZW1wb3dlck1hbmFnZW1lbnQiLCJwbGF0Zm9ybV9hcHBfdXBkYXRlQXBwIiwicGxhdGZvcm1fYXBwX2FsbEF1dGhvcml0eUdyb3VwcyIsInBsYXRmb3JtX2F1dGhvcml0eUdyb3VwIiwicGxhdGZvcm1fYXBwX2JpbmRBdXRoMk1lbnUiLCJwbGF0Zm9ybV9saXN0UGxhdGZvcm1BcHBzIiwicGxhdGZvcm1fYXBwX2RlbGV0ZUF1dGhvcml0eUdyb3VwIiwicGxhdGZvcm1fYXBwX2F1dGhvcml0eU1hbmFnZW1lbnQiLCJwbGF0Zm9ybV9hcHBfYWRkQXV0aG9yaXR5IiwicGxhdGZvcm1fYXBwX2F1dGhvcml0eUdyb3VwTWFuYWdlbWVudCIsInBsYXRmb3JtX2FwcF9jaGFuZ2VBcHBTdGF0dXMiLCJwbGF0Zm9ybV9hcHBfdXBkYXRlQXV0aG9yaXR5R3JvdXAiLCJwbGF0Zm9ybV9hcHBfdXBkYXRlTWVudSIsInBsYXRmb3JtX2RldmVsb3BlciIsInBsYXRmb3JtX2F1dGhvcml0eSIsInBsYXRmb3JtX21hbmFnZW1lbnQiLCJwbGF0Zm9ybV9wYWdlUGxhdGZvcm1BcHBzIl0sImp0aSI6IjRlMGRiYWExLTM0ZDgtNDdjZi05NzJkLTVjYzJlNmUxYjg4ZiIsImNsaWVudF9pZCI6InNzby1nYXRld2F5Iiwic2NvcGUiOlsicmVhZCJdfQ.KkCaQvJxWcTcnJdbPJVdJkG5O9GQz0kDcuCBM-RTAEA' 'https://mobiledev.utcook.com/offline-authority/allItemsOfDevice?productId=SF32KJ&deviceId=JTPKSJQR1J&clientVersion=3' 
  ```

  > 必须是通过mobiledev地址，不走cookie