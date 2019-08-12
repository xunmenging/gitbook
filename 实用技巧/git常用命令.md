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

