# Git 全局设置

```shell
git config --global user.name "李星辰" 
git config --global user.email "lixingchen@ut.cn" 
```

# 创建一个新仓库

```sh
git clone ssh://git@gitlab.utcook.com:10022/language_v3.2/language_core/vmexecute.git 
cd vmexecute 
touch README.md 
git add README.md 
git commit -m "add README" 
git push -u origin master
```

## git clone 带用户名密码

**git使用用户名密码clone的方式：**

```sh
git clone http://username:password@remote
```

**eg: username:  abc@qq.com, pwd: test, git地址为git@xxx.com/test.git**

```
git clone http://abc%40qq.com:test@git@xxx.com/test.git
```

> 注意：用户名密码中一定要转义 @符号转码后变成了%40

# 推送现有文件夹

```sh
cd existing_folder 
git init 
git remote add origin ssh://git@gitlab.utcook.com:10022/language_v3.2/vmexecute.git 
git add . 
git commit -m "Initial commit" 
git push -u origin master
```

# 推送现有的 Git 仓库

```sh
cd existing_repo 
git remote rename origin old-origin 
git remote add origin ssh://git@gitlab.utcook.com:10022/language_v3.2/vmexecute.git
git push -u origin --all
git push -u origin --tags
```

修改当前仓库的url

```sh
git remote set-url origin new_addr
```

# GitHub如何配置SSH Key

## 检查是否存在SSH Key

```sh
cd ~/.ssh
ll //看是否存在 id_rsa 和 id_rsa.pub文件，如果存在，说明已经有SSH Key
```

如果没有SSH Key，则需要先生成一下

```git
ssh-keygen -t rsa -C "xcli2018@126.com"
```

## 获取SSH Key

```git
cat id_rsa.pub //拷贝秘钥 ssh-rsa开头
```

## GitHub添加SSH Key

```
取个名字，把之前拷贝的秘钥复制进去，添加就好啦。
```

#  4 git submodule用法

前提：同一帐户下有母仓库的读写权限，子仓库的读权限；

###  4.1 在git仓库下使用`git submodule add`添加子git仓库：

```shell
git submodule add ../../share/pages-demo.git submodule-path
```

> 说明：
>
> 1. 同一git仓库下推荐使用相对路径
>     同组下项目
>     url = ../pages-demo.git
>     指定组项目
>     url = ../../share/pages-demo.git
> 2.  `.gitignore`不能添加`submodule-path` 

命令执行成功后，可以看到子仓库git克隆过程，否则多测试下相对路径，直到成功为止。

###  4.2 提交至远程仓库

```shell
git add -A
git commit -m 'git submodule add ../../share/pages-demo.git submodule-path'
git push
```

成功后，在浏览器中，可以看到点击子仓库链接到实际仓库。 如果有子仓库的写权限，也可直接修改子仓库，并提交到远程仓库。

###  4.3 克隆带有submodule的仓库

```shell
方式一：
git clone https://gitlab.utcook.com/share/c-lang-demo.git
cd c-lang-demo
git submodule update --init --recursive  # 第一次，需要加 --init

方式二：
git clone --recurse-submodules <main_project_url>  # 获取主项目和所有子项目源码
```

