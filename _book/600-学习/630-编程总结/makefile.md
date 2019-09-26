# makefile基本用法

## 常规步骤

- 一般我们可以使用“$(wildcard *.c)”来获取工作目录下的所有的.c文件列表。

- 复杂一些用法；可以使用“$(patsubst %.c,%.o,$(wildcard *.c))”，首先使用“wildcard”函数获取工作目录下的.c文件列表；之后将列表中所有文件名的后缀.c替换为.o。这样我们就可以得到在当前目录可生成的.o文件列表。

- 因此在一个目录下可以使用如下内容的Makefile来将工作目录下的所有的.c文件进行编译并最后连接成为一个可执行文件：

  ```makefile
  #sample Makefile
  objects := $(patsubst %.c,%.o,$(wildcard *.c))
  foo : $(objects)
  	cc -o foo $(objects)
  ```

  

