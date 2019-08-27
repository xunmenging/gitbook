# gitbook准备工作

## 安装 Node.js

GitBook 是一个基于 Node.js 的命令行工具，下载安装 [Node.js](https://link.jianshu.com/?t=https%3A%2F%2Fnodejs.org%2Fen)，安装完成之后，你可以使用下面的命令来检验是否安装成功。

```
$ node -v
v7.7.1
```

### 安装 GitBook

输入下面的命令来安装 GitBook。

```
$ npm install gitbook-cli -g
```

安装完成之后，你可以使用下面的命令来检验是否安装成功。

```
$ gitbook -V
CLI version: 2.3.2
GitBook version: 3.2.3
```

# gitbook的使用

1. gitbook init初始化

2. gitbook serve 开启服务

3. gitbook安装折叠目录的插件

   - Add it to your `book.json` configuration:

     ```json
     {
     	"plugins": ["expandable-chapters"]
     }
     ```

   - Install your plugins using:

     ```shell
     $ gitbook install
     ```

# typora使用

## 常用快捷键

- ctrl+l：选中行
- ctrl+shift+]：无序列表
- ctrl+shift+[：有序列表
- ctrl+shift+k：插入代码段
- ctrl+shift+q：插入引用
- ctrl+b：加粗
- ctrl+k：链接引用
- ctrl+shift+i：插入图片

# github的使用

## Deploying a subfolder to GitHub Pages

Sometimes you want to have a subdirectory on the master branch be the root directory of a repository’s gh-pages branch. This is useful for things like sites developed with Yeoman, or if you have a Jekyll site contained in the master branch alongside the rest of your code.

For the sake of this example, let’s pretend the subfolder containing your site is named dist.

**Step 1**
Remove the dist directory from the project’s .gitignore file (it’s ignored by default by Yeoman).

**Step 2**
Make sure git knows about your subtree (the subfolder with your site).

```shell
git add dist && git commit -m "Initial dist subtree commit"
```

**Step 3**
Use subtree push to send it to the gh-pages branch on GitHub.

```shell
git subtree push --prefix dist origin gh-pages
```


Boom. If your folder isn’t called dist, then you’ll need to change that in each of the commands above.

If you do this on a regular basis, you could also create a script containing the following somewhere in your path:

```shell
#!/bin/sh
if [ -z "$1" ]
then
  echo "Which folder do you want to deploy to GitHub Pages?"
  exit 1
fi
git subtree push --prefix $1 origin gh-pages
```


Which lets you type commands like:

```shell
git gh-deploy path/to/your/site
```

## gitbook访问网址

```html
https://xunmenging.github.io/gitbook/index.html
```

