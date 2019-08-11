[TOC]

# 调试信息与调试原理

如何判断 hello_server 是否带有调试信息呢？gdb 加载成功以后，会显示如下信息：

```
Reading symbols **from** /root/testclient/hello_server...done.
```

即读取符号文件完毕，说明该程序含有调试信息。我们不加 **-g** 选项再试试：

```
Reading symbols from /root/testclient/hello_server2...(no debugging symbols found)...done.
```

顺便提一下，除了不加 -g 选项，也可以使用 Linux 的 strip 命令移除掉某个程序中的调试信息，我们这里对 hello_server 使用 strip 命令试试：

```
[root@localhost testclient]# strip hello_server
##使用 strip 命令之前
-rwxr-xr-x. 1 root root 12416 Sep 8 09:45 hello_server
##使用 strip 命令之后
-rwxr-xr-x. 1 root root 6312 Sep 8 09:55 hello_server
```

可以发现，对 hello_server 使用 strip 命令之后，这个程序明显变小了（由 12416 个字节减少为 6312 个字节）。我们通常会在程序测试没问题以后，将其发布到生产环境或者正式环境中，因此生成不带调试符号信息的程序，以减小程序体积或提高程序执行效率。

另外补充两点说明：

- 本课程里虽然以 gcc 为例，但 -g 选项实际上同样也适用于使用 makefile 、cmake 等工具编译生成的 Linux 程序。

- 在实际生成调试程序时，一般不仅要加上 -g 选项，也建议关闭编译器的程序优化选项。编译器的程序优化选项一般有五个级别，从 O0 ~ O4 （ 注意第一个 O0 ，是字母 O 加上数字 0 ）， O0 表示不优化，从 O1 ~ O4 优化级别越来越高，O4 最高。这样做的目的是为了调试的时候，符号文件显示的调试变量等能与源代码完全对应起来。举个例子，假设有以下代码：

  > 总之一句话，**建议生成调试文件时关闭编译器优化选项**。

# 启动 GDB 调试

## 直接调试目标程序

```shell
 gdb filename
```

可以使用 **gdb filename** 直接启动这个程序的调试，其中 **filename** 是需要启动的调试程序文件名，这种方式是直接使用 GDB 启动一个程序进行调试。注意这里说的**启动一个程序进行调试**其实不严谨，因为实际上只是附加（attach）了一个可执行文件，并没有把程序启动起来；接着需要输入**run** 命令，程序才会真正的运行起来。

## 附加进程

```shell
gdb attach 进程 ID 
```

在某些情况下，一个程序已经启动了，我们想调试这个程序，但是又不想重启这个程序。假设有这样一个场景，我们的聊天测试服务器程序正在运行，运行一段时间之后，发现这个聊天服务器不能接受新的客户端连接了，这时肯定是不能重启程序的，如果重启，当前程序的各种状态信息就丢失了。怎么办呢？可以使用 **gdb attach 进程 ID** 来将 GDB 调试器附加到聊天测试服务器程序上。例如，假设聊天程序叫 chatserver，可以使用 ps 命令获取该进程的 PID，然后使用 gdb attach 就可以调试了，操作如下：

```
[zhangyl@iZ238vnojlyZ flamingoserver]$ ps -ef | grep chatserver
zhangyl  21462 21414  0 18:00 pts/2    00:00:00 grep --color=auto chatserver
zhangyl  26621     1  5 Oct10 ?        2-17:54:42 ./chatserver -d
```

实际执行如下图所示：

![enter image description here](https://images.gitbook.cn/ca090200-fc3e-11e8-9fb2-0bb0adb1f496)

通过以上代码得到 chatserver 的 PID 为 26621，然后使用 **gdb attach 26621** 把 GDB 附加到 chatserver 进程。**当提示 “Attaching to process 26621” 时就说明我们已经成功地将 GDB 附加到目标进程了。**需要注意的是，程序使用了一些系统库（如 libc.so），由于这是发行版本的 Linux 系统，这些库是没有调试符号的，因而 GDB 会提示找不到这些库的调试符号。因为目的是调试 chatserver，对系统 API 调用的内部实现并不关注，所以这些提示可以不用关注，只要 chatserver 这个文件有调试信息即可。

当调试完程序想结束此次调试时，而且不对当前进程 chatserver 有任何影响，也就是说想让这个程序继续运行，可以在 GDB 的命令行界面输入 detach 命令让程序与 GDB 调试器分离，这样 chatserver 就可以继续运行了：

```
(gdb) detach
Detaching from program: /home/zhangyl/flamingoserver/chatserver, process 42921
```

然后再退出 GDB 就可以了：

```
(gdb) quit
[zhangyl@localhost flamingoserver]$
```

## 调试 core 文件

```
gdb filename corename
```

Linux 系统默认是不开启程序崩溃产生 core 文件这一机制的，我们可以使用 ulimit -c 命令来查看系统是否开启了这一机制。

> 顺便提一句，ulimit 这个命令不仅仅可以查看 core 文件生成是否开启，还可以查看其他的一些功能，比如系统允许的最大文件描述符的数量等，具体可以使用 ulimit -a 命令来查看，由于这个内容与本课主题无关，这里不再赘述。

```
[zhangyl@localhost flamingoserver]$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 15045
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 4096
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

发现 core file size 那一行默认是 0，表示关闭生成 core 文件，可以使用“ulimit 选项名 设置值”来修改。例如，可以将 core 文件生成改成具体某个值（最大允许的字节数），这里我们使用 **ulimit -c unlimited**（**unlimited** 是 **-c** 选项值）直接修改成不限制大小。

> 注意，这个命令容易记错，第一个 ulimit 是 **Linux 命令**， -c 选项后面的 unlimited 是**选项的值**，表示不限制大小，当然也可以改成具体的数值大小。很多初学者在学习这个命令时，总是把 **ulimit 命令**和 **unlimited 取值**搞混淆，如果读者能理解其含义，一般就不会混淆了。

还有一个问题就是，这样修改以后，当我们关闭这个 Linux 会话，设置项的值就会被还原成 0，而服务器程序一般是以后台程序（守护进程）长周期运行，也就是说当前会话虽然被关闭，服务器程序仍然继续在后台运行，这样这个程序在某个时刻崩溃后，是无法产生 core 文件的，这种情形不利于排查问题。因此，我们希望这个选项永久生效，永久生效的方式是把“ulimit -c unlimited”这一行加到 /etc/profile 文件中去，放到这个文件最后一行即可。

### 自定义 core 文件名称

但是细心的读者会发现一个问题：一个正在程序运行时，其 PID 是可以获取到的，但是当程序崩溃后，产生了 core 文件，尤其是多个程序同时崩溃，我们根本没法通过 core 文件名称中的 PID 来区分到底是哪个服务解决这个问题有两个方法：

- 程序启动时，记录一下自己的 PID

```
void writePid()
{
      uint32_t curPid = (uint32_t) getpid();
      FILE* f = fopen("xxserver.pid", "w");
      assert(f);
      char szPid[32];
      snprintf(szPid, sizeof(szPid), "%d", curPid);
      fwrite(szPid, strlen(szPid), 1, f);
      fclose(f);
}
```

我们在程序启动时调用上述 **writePID** 函数，将程序当时的 PID 记录到 **xxserver.pid** 文件中去，这样当程序崩溃时，可以从这个文件中得到进程当时运行的 PID，这样就可以与默认的 core 文件名后面的 PID 做匹配了。

- 自定义 core 文件的名称和目录

**/proc/sys/kernel/core_uses_pid** 可以控制产生的 core 文件的文件名中是否添加 PID 作为扩展，如果添加则文件内容为 1，否则为 0；**/proc/sys/kernel/core_pattern** 可以设置格式化的 core 文件保存位置或文件名。修改方式如下：

```
echo "/corefile/core-%e-%p-%t" > /proc/sys/kernel/core_pattern
```

各个参数的说明如下：

| 参数名称 | 参数含义（英文）                                          | 参数含义（中文）                               |
| :------: | :-------------------------------------------------------- | :--------------------------------------------- |
|    %p    | insert pid into filename                                  | 添加 pid 到 core 文件名中                      |
|    %u    | insert current uid into filename                          | 添加当前 uid 到 core 文件名中                  |
|    %g    | insert current gid into filename                          | 添加当前 gid 到 core 文件名中                  |
|    %s    | insert signal that caused the coredump into the filename  | 添加导致产生 core 的信号到 core 文件名中       |
|    %t    | insert UNIX time that the coredump occurred into filename | 添加 core 文件生成时间（UNIX）到 core 文件名中 |
|    %h    | insert hostname where the coredump happened into filename | 添加主机名到 core 文件名中                     |
|    %e    | insert coredumping executable name into filename          | 添加程序名到 core 文件名中                     |

假设现在的程序叫 **test**，我们设置该程序崩溃时的 core 文件名如下：

```
echo "/root/testcore/core-%e-%p-%t" > /proc/sys/kernel/core_pattern
```

那么最终会在 **/root/testcore/** 目录下生成的 test 的 core 文件名格式如下：

```
-rw-------. 1 root root 409600 Jan 14 13:54 core-test-13154-1547445291
```

![img](https://images.gitbook.cn/1abcbda0-1809-11e9-90f4-4f5962647553)

> 需要注意的是，您使用的用户必须对指定 core 文件目录具有写权限，否则生成时 会因为权限不足而导致无法生成 core 文件。

# GDB 常用的调试命令概览

常用命令的列表

| 命令名称    | 命令缩写 | **命令说明**                                           |
| :---------- | :------- | :----------------------------------------------------- |
| run         | r        | 运行一个程序                                           |
| continue    | c        | 让暂停的程序继续运行                                   |
| next        | n        | 运行到下一行                                           |
| step        | s        | 如果有调用函数，进入调用的函数内部，相当于 step into   |
| until       | u        | 运行到指定行停下来                                     |
| finish      | fi       | 结束当前调用函数，到上一层函数调用处                   |
| return      | return   | 结束当前调用函数并返回指定值，到上一层函数调用处       |
| jump        | j        | 将当前程序执行流跳转到指定行或地址                     |
| print       | p        | 打印变量或寄存器值                                     |
| backtrace   | bt       | 查看当前线程的调用堆栈                                 |
| frame       | f        | 切换到当前调用线程的指定堆栈，具体堆栈通过堆栈序号指定 |
| thread      | thread   | 切换到指定线程                                         |
| break       | b        | 添加断点                                               |
| tbreak      | tb       | 添加临时断点                                           |
| delete      | del      | 删除断点                                               |
| enable      | enable   | 启用某个断点                                           |
| disable     | disable  | 禁用某个断点                                           |
| watch       | watch    | 监视某一个变量或内存地址的值是否发生变化               |
| list        | l        | 显示源码                                               |
| info        | info     | 查看断点 / 线程等信息                                  |
| ptype       | ptype    | 查看变量类型                                           |
| disassemble | dis      | 查看汇编代码                                           |
| set args    |          | 设置程序启动命令行参数                                 |
| show args   |          | 查看设置的命令行参数                                   |

当 GDB 输入命令时，对于一个命令可以缩写成什么样子，只需要遵循如下两个规则即可。

- 一个命令缩写时不能出现多个选择，否则 GDB 就不知道对应哪个命令了。举个例子，输入 th，那么 th 对应的命令有 thread 和 thbreak（上表没有列出），这样 GDB 就不知道使用哪个了，需要更具体的输入，GDB 才能识别。

```
(gdb) th
Ambiguous command "th": thbreak, thread.
```

- GDB 有些命令虽然也对应多个选择，但是有些命令的简写是有规定的，例如，r 就是命令“run”的简写，虽然输入“r”时，你的本意可能是“return”命令。

# GDB 常用命令详解

为了方便调试，我们需要生成调试符号并且关闭编译器优化选项，操作如下：

```
[root@localhost gdbtest]# cd redis-4.0.11
[root@localhost redis-4.0.11]# make CFLAGS="-g -O0" -j 4
```

> 注意：由于 redis 是纯 C 项目，使用的编译器是 gcc，因而这里设置编译器的选项时使用的是 CFLAGS 选项；如果项目使用的语言是 C++，那么使用的编译器一般是 g++，相对应的编译器选项是 CXXFLAGS。这点请读者注意区别。
>
> 另外，这里 makefile 使用了 -j 选项，其值是 4，表示开启 4 个进程同时编译，加快编译速度。

## run 命令

默认情况下，前面的课程中我们说 **gdb filename** 命令只是附加的一个调试文件，并没有启动这个程序，需要输入 **run** 命令（简写为 r）启动这个程序。

假设程序已经启动，再次输入 run 命令则是重启程序。我们在 GDB 界面按 Ctrl + C 快捷键让 GDB 中断下来，再次输入 r 命令，GDB 会询问我们是否重启程序，输入 yes 确认重启。

## continue 命令

当 GDB 触发断点或者使用 Ctrl + C 命令中断下来后，想让程序继续运行，只要输入 **continue** 命令即可（简写为 c）。当然，如果 **continue** 命令继续触发断点，GDB 就会再次中断下来。

## break 命令

**break** 命令（简写为 b）即我们添加断点的命令，可以使用以下方式添加断点：

- break functionname，在函数名为 functionname 的入口处添加一个断点；
- break LineNo，在当前文件行号为 LineNo 处添加一个断点；
- break filename:LineNo，在 filename 文件行号为 LineNo 处添加一个断点。

## backtrace 与 frame 命令

**backtrace** 命令（简写为 bt）用来查看当前调用堆栈。接上，redis-server 现在中断在 anet.c:452 行，可以通过 **backtrace** 命令来查看当前的调用堆栈：

```
(gdb) bt
#0  anetListen (err=0x746bb0 <server+560> "", s=10, sa=0x7e34e0, len=16, backlog=511) at anet.c:452
#1  0x0000000000426e35 in _anetTcpServer (err=err@entry=0x746bb0 <server+560> "", port=port@entry=6379, bindaddr=bindaddr@entry=0x0, af=af@entry=10, backlog=511)
    at anet.c:487
#2  0x000000000042793d in anetTcp6Server (err=err@entry=0x746bb0 <server+560> "", port=port@entry=6379, bindaddr=bindaddr@entry=0x0, backlog=511)
    at anet.c:510
#3  0x000000000042b0bf in listenToPort (port=6379, fds=fds@entry=0x746ae4 <server+356>, count=count@entry=0x746b24 <server+420>) at server.c:1728
#4  0x000000000042fa77 in initServer () at server.c:1852
#5  0x0000000000423803 in main (argc=1, argv=0x7fffffffe648) at server.c:3862
(gdb)
```

这里一共有 6 层堆栈，最顶层是 main() 函数，最底层是断点所在的 anetListen() 函数，堆栈编号分别是 #0 ~ #5 ，如果想切换到其他堆栈处，可以使用 frame 命令（简写为 f），该命令的使用方法是“**frame 堆栈编号**（编号不加 #）”。

## info break、enable、disable 和 delete 命令

在程序中加了很多断点，而我们想查看加了哪些断点时，可以使用 **info break** 命令（简写为 info b）：

```
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000423450 in main at server.c:3709
        breakpoint already hit 1 time
2       breakpoint     keep y   0x000000000049c1f0 in _redisContextConnectTcp at net.c:267
3       breakpoint     keep y   0x0000000000426cf0 in anetListen at anet.c:441
        breakpoint already hit 1 time
4       breakpoint     keep y   0x0000000000426d05 in anetListen at anet.c:444
        breakpoint already hit 1 time
5       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:450
        breakpoint already hit 1 time
6       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:452
        breakpoint already hit 1 time
```

通过上面的内容片段可以知道，目前一共增加了 6 个断点，除了断点 2 以外，其他的断点均被触发一次，其他信息比如每个断点的位置（所在的文件和行号）、内存地址、断点启用和禁用状态信息也一目了然。如果我们想禁用某个断点，使用“**disable 断点编号**”就可以禁用这个断点了，被禁用的断点不会再被触发；同理，被禁用的断点也可以使用“**enable 断点编号**”重新启用。

```
(gdb) disable 1
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep n   0x0000000000423450 in main at server.c:3709
        breakpoint already hit 1 time
2       breakpoint     keep y   0x000000000049c1f0 in _redisContextConnectTcp at net.c:267
3       breakpoint     keep y   0x0000000000426cf0 in anetListen at anet.c:441
        breakpoint already hit 1 time
4       breakpoint     keep y   0x0000000000426d05 in anetListen at anet.c:444
        breakpoint already hit 1 time
5       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:450
        breakpoint already hit 1 time
6       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:452
        breakpoint already hit 1 time
```

使用 **disable 1** 以后，第一个断点的 Enb 一栏的值由 y 变成 n，重启程序也不会再次触发：

```
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/gdbtest/redis-4.0.11/src/redis-server
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".
46795:C 08 Sep 16:15:55.681 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
46795:C 08 Sep 16:15:55.681 # Redis version=4.0.11, bits=64, commit=00000000, modified=0, pid=46795, just started
46795:C 08 Sep 16:15:55.681 # Warning: no config file specified, using the default config. In order to specify a config file use /root/gdbtest/redis-4.0.11/src/redis-server /path/to/redis.conf
46795:M 08 Sep 16:15:55.682 * Increased maximum number of open files to 10032 (it was originally set to 1024).

Breakpoint 3, anetListen (err=0x746bb0 <server+560> "", s=10, sa=0x75edb0, len=28, backlog=511) at anet.c:441
441         if (bind(s,sa,len) == -1) {
```

如果 **disable** 命令和 **enable** 命令不加断点编号，则分别表示禁用和启用所有断点：

```
(gdb) disable
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep n   0x0000000000423450 in main at server.c:3709
2       breakpoint     keep n   0x000000000049c1f0 in _redisContextConnectTcp at net.c:267
3       breakpoint     keep n   0x0000000000426cf0 in anetListen at anet.c:441
        breakpoint already hit 1 time
4       breakpoint     keep n   0x0000000000426d05 in anetListen at anet.c:444
5       breakpoint     keep n   0x0000000000426d16 in anetListen at anet.c:450
6       breakpoint     keep n   0x0000000000426d16 in anetListen at anet.c:452
(gdb) enable
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000423450 in main at server.c:3709
2       breakpoint     keep y   0x000000000049c1f0 in _redisContextConnectTcp at net.c:267
3       breakpoint     keep y   0x0000000000426cf0 in anetListen at anet.c:441
        breakpoint already hit 1 time
4       breakpoint     keep y   0x0000000000426d05 in anetListen at anet.c:444
5       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:450
6       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:452
(gdb)
```

使用“**delete 编号**”可以删除某个断点，如 **delete 2 3** 则表示要删除的断点 2 和断点 3：

```
(gdb) delete 2 3
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000423450 in main at server.c:3709
4       breakpoint     keep y   0x0000000000426d05 in anetListen at anet.c:444
5       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:450
6       breakpoint     keep y   0x0000000000426d16 in anetListen at anet.c:452
```

同样的道理，如果输入 delete 不加命令号，则表示删除所有断点。

## list 命令

**List** 命令（简写为 l）可以查看当前断点处的代码

第一次输入 **list** 命令会显示断点处前后的代码，继续输入 **list** 指令会以递增行号的形式继续显示剩下的代码行，一直到文件结束为止。当然 list 指令还可以往前和往后显示代码，命令分别是“**list +** （加号）”和“**list -** （减号）”

可以使用 **list FILE:LINENUM** 来显示某个文件的某一行处的代码，

## print 和 ptype 命令

通过 **print** 命令（简写为 p）我们可以在调试过程中方便地查看变量的值，也可以修改当前内存中的变量值。切换当前断点到堆栈 #4 ，然后打印以下三个变量。

```C
(gdb) bt
#0  anetListen (err=0x746bb0 <server+560> "", s=10, sa=0x7e34e0, len=16, backlog=511) at anet.c:447
#1  0x0000000000426e35 in _anetTcpServer (err=err@entry=0x746bb0 <server+560> "", port=port@entry=6379, bindaddr=bindaddr@entry=0x0, af=af@entry=10, backlog=511)
    at anet.c:487
#2  0x000000000042793d in anetTcp6Server (err=err@entry=0x746bb0 <server+560> "", port=port@entry=6379, bindaddr=bindaddr@entry=0x0, backlog=511)
    at anet.c:510
#3  0x000000000042b0bf in listenToPort (port=6379, fds=fds@entry=0x746ae4 <server+356>, count=count@entry=0x746b24 <server+420>) at server.c:1728
#4  0x000000000042fa77 in initServer () at server.c:1852
#5  0x0000000000423803 in main (argc=1, argv=0x7fffffffe648) at server.c:3862
(gdb) f 4
#4  0x000000000042fa77 in initServer () at server.c:1852
1852            listenToPort(server.port,server.ipfd,&server.ipfd_count) == C_ERR)
(gdb) l
1847        }
1848        server.db = zmalloc(sizeof(redisDb)*server.dbnum);
1849
1850        /* Open the TCP listening socket for the user commands. */
1851        if (server.port != 0 &&
1852            listenToPort(server.port,server.ipfd,&server.ipfd_count) == C_ERR)
1853            exit(1);
1854
1855        /* Open the listening Unix domain socket. */
1856        if (server.unixsocket != NULL) {
(gdb) p server.port
$15 = 6379
(gdb) p server.ipfd
$16 = {0 <repeats 16 times>}
(gdb) p server.ipfd_count
$17 = 0
```

这里使用 **print** 命令分别打印出 server.port 、server.ipfd 、server.ipfd_count 的值，其中 server.ipfd 显示 “{0 \}”，这是 GDB 显示字符串或字符数据特有的方式，当一个字符串变量或者字符数组或者连续的内存值重复若干次，GDB 就会以这种模式来显示以节约空间。

**print** 命令不仅可以显示变量值，也可以显示进行一定运算的表达式计算结果值，甚至可以显示一些函数的执行结果值。

举个例子，我们可以输入 **p &server.port** 来输出 server.port 的地址值，如果在 C++ 对象中，可以通过 p this 来显示当前对象的地址，也可以通过 p *this 来列出当前对象的各个成员变量值，如果有三个变量可以相加（ 假设变量名分别叫 a、b、c ），可以使用 **p a + b + c** 来打印这三个变量的结果值。

假设 func() 是一个可以执行的函数，p func() 命令可以输出该变量的执行结果。举一个最常用的例子，某个时刻，某个系统函数执行失败了，通过系统变量 errno 得到一个错误码，则可以使用 p strerror(errno) 将这个错误码对应的文字信息打印出来，这样就不用费劲地去 man 手册上查找这个错误码对应的错误含义了。

print 命令不仅可以输出表达式结果，同时也可以修改变量的值，我们尝试将上文中的端口号从 6379 改成 6400 试试：

```
(gdb) p server.port=6400
$24 = 6400
(gdb) p server.port
$25 = 6400
(gdb)
```

当然，一个变量值修改后能否起作用要看这个变量的具体位置和作用，举个例子，对于表达式 int a = b / c ; 如果将 c 修改成 0 ，那么程序就会产生除零异常。再例如，对于如下代码：

```C
int j = 100;
for (int i = 0; i < j; ++i) {
    printf("i = %d\n", i);
}
```

如果在循环的过程中，利用 **print** 命令将 j 的大小由 100 改成 1000 ，那么这个循环将输出 i 的值 1000 次。

总结起来，利用 **print** 命令，我们不仅可以查看程序运行过程中的各个变量的状态值，也可以通过临时修改变量的值来控制程序的行为。

GDB 还有另外一个命令叫 **ptype** ，顾名思义，其含义是“print type”，就是输出一个变量的类型。例如，我们试着输出 Redis 堆栈 #4 的变量 server 和变量 server.port 的类型：

```c
(gdb) ptype server
type = struct redisServer {
    pid_t pid;
    char *configfile;
    char *executable;
    char **exec_argv;
    int hz;
    redisDb *db;
    ...省略部分字段...
(gdb) ptype server.port
type = int
```

可以看到，对于一个复合数据类型的变量，ptype 不仅列出了这个变量的类型（ 这里是一个名叫 redisServer 的结构体），而且详细地列出了每个成员变量的字段名，有了这个功能，我们在调试时就不用刻意去代码文件中查看某个变量的类型定义了。

## info 和 thread 命令

> 1. thread apply all bt：可以打印所有的线程现在的调用情况，对于死锁的问题跟踪很有帮助。
> 2. phreads库线程同步检测工具
>    - Intel Thread Checker
>    - Valgrind-Helgrind

在前面使用 **info break** 命令查看当前断点时介绍过，info 命令是一个复合指令，还可以用来查看当前进程的所有线程运行情况。下面以 redis-server 进程为例来演示一下，使用 delete 命令删掉所有断点，然后使用 run 命令重启一下 redis-server，等程序正常启动后，我们按快捷键 Ctrl+C 中断程序，然后使用 info thread 命令来查看当前进程有哪些线程，分别中断在何处：

```
(gdb) delete
Delete all breakpoints? (y or n) y
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/gdbtest/redis-4.0.11/src/redis-server
[Thread debugging using libthread_db enabled]
...省略部分无关内容...
53062:M 10 Sep 17:11:10.810 * Ready to accept connections
^C
Program received signal SIGINT, Interrupt.
0x00007ffff73ee923 in epoll_wait () from /lib64/libc.so.6
(gdb) info thread
  Id   Target Id         Frame
  4    Thread 0x7fffef7fd700 (LWP 53065) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  3    Thread 0x7fffefffe700 (LWP 53064) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  2    Thread 0x7ffff07ff700 (LWP 53063) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
* 1    Thread 0x7ffff7fec780 (LWP 53062) "redis-server" 0x00007ffff73ee923 in epoll_wait () from /lib64/libc.so.6
```

通过 **info thread** 的输出可以知道 redis-server 正常启动后，一共产生了 4 个线程，包括一个主线程和三个工作线程，线程编号（Id 那一列）分别是 4、3、2、1。三个工作线程（2、3、4）分别阻塞在 Linux API pthread_cond_wait 处，而主线程（1）阻塞在 epoll_wait 处。

> **注意**：虽然第一栏的名称叫 Id，但第一栏的数值不是线程的 Id，第三栏括号里的内容（如 LWP 53065）中，53065 这样的数值才是当前线程真正的 Id。那 LWP 是什么意思呢？在早期的 Linux 系统的内核里面，其实不存在真正的线程实现，当时所有的线程都是用进程来实现的，这些模拟线程的进程被称为 Light Weight Process（轻量级进程），后来 Linux 系统有了真正的线程实现，这个名字仍然被保留了下来。

读者可能会有疑问：怎么知道线程 1 就是主线程？线程 2、线程 3、线程 4 就是工作线程呢？是不是因为线程 1 前面有个星号（*）？错了，线程编号前面这个星号表示的是当前 GDB 作用于哪个线程，而不是主线程的意思。现在有 4 个线程，也就有 4 个调用堆栈，如果此时输入 **backtrace** 命令查看调用堆栈，由于当前 GDB 作用在线程 1，因此 **backtrace** 命令显示的一定是线程 1 的调用堆栈：

```
(gdb) bt
#0  0x00007ffff73ee923 in epoll_wait () from /lib64/libc.so.6
#1  0x00000000004265df in aeApiPoll (tvp=0x7fffffffe300, eventLoop=0x7ffff08350a0) at ae_epoll.c:112
#2  aeProcessEvents (eventLoop=eventLoop@entry=0x7ffff08350a0, flags=flags@entry=11) at ae.c:411
#3  0x0000000000426aeb in aeMain (eventLoop=0x7ffff08350a0) at ae.c:501
#4  0x00000000004238ef in main (argc=1, argv=0x7fffffffe648) at server.c:3899
```

由此可见，堆栈 #4 的 main() 函数也证实了上面的说法，即线程编号为 1 的线程是主线程。

如何切换到其他线程呢？可以通过“thread 线程编号”切换到具体的线程上去。例如，想切换到线程 2 上去，只要输入 **thread 2** 即可，然后输入 **bt** 就能查看这个线程的调用堆栈了：

```
(gdb) info thread
  Id   Target Id         Frame
  4    Thread 0x7fffef7fd700 (LWP 53065) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  3    Thread 0x7fffefffe700 (LWP 53064) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  2    Thread 0x7ffff07ff700 (LWP 53063) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
* 1    Thread 0x7ffff7fec780 (LWP 53062) "redis-server" 0x00007ffff73ee923 in epoll_wait () from /lib64/libc.so.6
(gdb) thread 2
[Switching to thread 2 (Thread 0x7ffff07ff700 (LWP 53063))]
#0  0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
(gdb) bt
#0  0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
#1  0x000000000047a91c in bioProcessBackgroundJobs (arg=0x0) at bio.c:176
#2  0x00007ffff76c0e25 in start_thread () from /lib64/libpthread.so.0
#3  0x00007ffff73ee34d in clone () from /lib64/libc.so.6
```

因此利用 **info thread** 命令就可以调试多线程程序，当然用 GDB 调试多线程程序还有一个很麻烦的问题，我们将在后面的 GDB 高级调试技巧中介绍。请注意，当把 GDB 当前作用的线程切换到线程 2 上之后，线程 2 前面就被加上了星号：

```
(gdb) info thread
  Id   Target Id         Frame
  4    Thread 0x7fffef7fd700 (LWP 53065) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  3    Thread 0x7fffefffe700 (LWP 53064) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
* 2    Thread 0x7ffff07ff700 (LWP 53063) "redis-server" 0x00007ffff76c4945 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
  1    Thread 0x7ffff7fec780 (LWP 53062) "redis-server" 0x00007ffff73ee923 in epoll_wait () from /lib64/libc.so.6
```

**info** 命令还可以用来查看当前函数的参数值，组合命令是 **info args**，我们找个函数值多一点的堆栈函数来试一下：

```
(gdb) thread 1
[Switching to thread 1 (Thread 0x7ffff7fec780 (LWP 53062))]
#0  0x00007ffff73ee923 in epoll_wait () from /lib64/libc.so.6
(gdb) bt
#0  0x00007ffff73ee923 in epoll_wait () from /lib64/libc.so.6
#1  0x00000000004265df in aeApiPoll (tvp=0x7fffffffe300, eventLoop=0x7ffff08350a0) at ae_epoll.c:112
#2  aeProcessEvents (eventLoop=eventLoop@entry=0x7ffff08350a0, flags=flags@entry=11) at ae.c:411
#3  0x0000000000426aeb in aeMain (eventLoop=0x7ffff08350a0) at ae.c:501
#4  0x00000000004238ef in main (argc=1, argv=0x7fffffffe648) at server.c:3899
(gdb) f 2
#2  aeProcessEvents (eventLoop=eventLoop@entry=0x7ffff08350a0, flags=flags@entry=11) at ae.c:411
411             numevents = aeApiPoll(eventLoop, tvp);
(gdb) info args
eventLoop = 0x7ffff08350a0
flags = 11
(gdb)
```

上述代码片段切回至主线程 1，然后切换到堆栈 #2，堆栈 #2 调用处的函数是 aeProcessEvents() ，一共有两个参数，使用 **info args** 命令可以输出当前两个函数参数的值，参数 eventLoop 是一个指针类型的参数，对于指针类型的参数，GDB 默认会输出该变量的指针地址值，如果想输出该指针指向对象的值，在变量名前面加上 * 解引用即可，这里使用 p *eventLoop 命令：

```
(gdb) p *eventLoop
$26 = {maxfd = 11, setsize = 10128, timeEventNextId = 1, lastTime = 1536570672, events = 0x7ffff0871480, fired = 0x7ffff08c2e40, timeEventHead = 0x7ffff0822080,
  stop = 0, apidata = 0x7ffff08704a0, beforesleep = 0x429590 <beforeSleep>, aftersleep = 0x4296d0 <afterSleep>}
```

如果还要查看其成员值，继续使用 **变量名 ->字段名** 即可，在前面学习 print 命令时已经介绍过了，这里不再赘述。

上面介绍的是 **info** 命令最常用的三种方法，更多关于 info 的组合命令在 GDB 中输入 **help info** 就可以查看：

```
(gdb) help info
Generic command for showing things about the program being debugged.

List of info subcommands:

info address -- Describe where symbol SYM is stored
info all-registers -- List of all registers and their contents
info args -- Argument variables of current stack frame
info auto-load -- Print current status of auto-loaded files
info auto-load-scripts -- Print the list of automatically loaded Python scripts
info auxv -- Display the inferior's auxiliary vector
info bookmarks -- Status of user-settable bookmarks
info breakpoints -- Status of specified breakpoints (all user-settable breakpoints if no argument)
info checkpoints -- IDs of currently known checkpoints
info classes -- All Objective-C classes
info common -- Print out the values contained in a Fortran COMMON block
info copying -- Conditions for redistributing copies of GDB
info dcache -- Print information on the dcache performance
info display -- Expressions to display when program stops
info extensions -- All filename extensions associated with a source language
info files -- Names of targets and files being debugged
info float -- Print the status of the floating point unit
info frame -- All about selected stack frame
info frame-filter -- List all registered Python frame-filters
info functions -- All function names
info handle -- What debugger does when program gets various signals
info inferiors -- IDs of specified inferiors (all inferiors if no argument)
info line -- Core addresses of the code for a source line
info locals -- Local variables of current stack frame
info macro -- Show the definition of MACRO
info macros -- Show the definitions of all macros at LINESPEC
info mem -- Memory region attributes
info os -- Show OS data ARG
info pretty-printer -- GDB command to list all registered pretty-printers
info probes -- Show available static probes
info proc -- Show /proc process information about any running process
info program -- Execution status of the program
info record -- Info record options
info registers -- List of integer registers and their contents
info scope -- List the variables local to a scope
---Type <return> to continue, or q <return> to quit---
info selectors -- All Objective-C selectors
info set -- Show all GDB settings
info sharedlibrary -- Status of loaded shared object libraries
info signals -- What debugger does when program gets various signals
info skip -- Display the status of skips
info source -- Information about the current source file
info sources -- Source files in the program
info stack -- Backtrace of the stack
info static-tracepoint-markers -- List target static tracepoints markers
info symbol -- Describe what symbol is at location ADDR
info target -- Names of targets and files being debugged
info tasks -- Provide information about all known Ada tasks
info terminal -- Print inferior's saved terminal status
info threads -- Display currently known threads
info tracepoints -- Status of specified tracepoints (all tracepoints if no argument)
info tvariables -- Status of trace state variables and their values
info type-printers -- GDB command to list all registered type-printers
info types -- All type names
info variables -- All global and static variable names
info vector -- Print the status of the vector unit
info vtbl -- Show the virtual function table for a C++ object
info warranty -- Various kinds of warranty you do not have
info watchpoints -- Status of specified watchpoints (all watchpoints if no argument)
info win -- List of all displayed windows

Type "help info" followed by info subcommand name for full documentation.
Type "apropos word" to search for commands related to "word".
Command name abbreviations are allowed if unambiguous.
```

## next、step、until、finish、return 和 jump 命令

这几个命令是我们用 GDB 调试程序时最常用的几个控制流命令，因此放在一起介绍。**next** 命令（简写为 n）是让 GDB 调到下一条命令去执行，这里的下一条命令不一定是代码的下一行，而是根据程序逻辑跳转到相应的位置。举个例子：

```
int a = 0;
if (a == 9)
{
    print("a is equal to 9.\n");
}

int b = 10;
print("b = %d.\n", b);
```

如果当前 GDB 中断在上述代码第 2 行，此时输入 **next** 命令 GDB 将调到第 7 行，因为这里的 if 条件并不满足。

这里有一个小技巧，在 GDB 命令行界面如果直接按下回车键，默认是将最近一条命令重新执行一遍，因此，当使用 **next** 命令单步调试时，不必反复输入 **n** 命令，直接回车就可以了。

```
3704    int main(int argc, char **argv) {
(gdb) n
3736        spt_init(argc, argv);
(gdb) n
3738        setlocale(LC_COLLATE,"");
(gdb) n
3739        zmalloc_set_oom_handler(redisOutOfMemoryHandler);
(gdb) n
3740        srand(time(NULL)^getpid());
(gdb) n
3752        server.exec_argv = zmalloc(sizeof(char*)*(argc+1));
(gdb) n
3740        srand(time(NULL)^getpid());
(gdb) n
3741        gettimeofday(&tv,NULL);
(gdb) n
3752        server.exec_argv = zmalloc(sizeof(char*)*(argc+1));
(gdb)
```

上面的执行过程等价于输入第一个 **n** 后直接回车：

```
(gdb) n
3736        spt_init(argc, argv);
(gdb)
3738        setlocale(LC_COLLATE,"");
(gdb)
3739        zmalloc_set_oom_handler(redisOutOfMemoryHandler);
(gdb)
3740        srand(time(NULL)^getpid());
(gdb)
3752        server.exec_argv = zmalloc(sizeof(char*)*(argc+1));
(gdb)
```

**next** 命令用调试的术语叫“单步步过”（step over），即遇到函数调用直接跳过，不进入函数体内部。而下面的 **step** 命令（简写为 **s**）就是“单步步入”（step into），顾名思义，就是遇到函数调用，进入函数内部。举个例子，在 redis-server 的 main() 函数中有个叫 spt_init(argc, argv) 的函数调用，当我们停在这一行时，输入 s 将进入这个函数内部。

```
//为了说明问题本身，除去不相关的干扰，代码有删减
int main(int argc, char **argv) {
    struct timeval tv;
    int j;
    /* We need to initialize our libraries, and the server configuration. */
    spt_init(argc, argv);
    setlocale(LC_COLLATE,"");
    zmalloc_set_oom_handler(redisOutOfMemoryHandler);
    srand(time(NULL)^getpid());
    gettimeofday(&tv,NULL);
    char hashseed[16];
    getRandomHexChars(hashseed,sizeof(hashseed));
    dictSetHashFunctionSeed((uint8_t*)hashseed);
    server.sentinel_mode = checkForSentinelMode(argc,argv);
    initServerConfig();
    moduleInitModulesSystem();
    //省略部分无关代码...
 }
```

演示一下，先使用 **b main** 命令在 main() 处加一个断点，然后使用 r 命令重新跑一下程序，会触发刚才加在 main() 函数处的断点，然后使用 **n** 命令让程序走到 spt_init(argc, argv) 函数调用处，再输入 **s** 命令就可以进入该函数了：

```
(gdb) b main
Breakpoint 3 at 0x423450: file server.c, line 3704.
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/redis-4.0.9/src/redis-server
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".

Breakpoint 3, main (argc=1, argv=0x7fffffffe588) at server.c:3704
3704    int main(int argc, char **argv) {
(gdb) n
3736        spt_init(argc, argv);
(gdb) s
spt_init (argc=argc@entry=1, argv=argv@entry=0x7fffffffe588) at setproctitle.c:152
152     void spt_init(int argc, char *argv[]) {
(gdb) l
147
148             return 0;
149     } /* spt_copyargs() */
150
151
152     void spt_init(int argc, char *argv[]) {
153             char **envp = environ;
154             char *base, *end, *nul, *tmp;
155             int i, error;
156
(gdb)
```

说到 **step** 命令，还有一个需要注意的地方，就是当函数的参数也是函数调用时，我们使用 **step** 命令会依次进入各个函数，那么顺序是什么呢？举个例子，看下面这段代码：

```
1  int fun1(int a, int b)
2  {
3     int c = a + b;
4     c += 2;
5     return c;
6  }
7
8  int func2(int p, int q)
9  {
10    int t = q * p;
11       return t * t;
12 }
13
14 int func3(int m, int n)
15 {
16    return m + n;
17 }
18
19 int main()
20 {
21    int c;
22    c = func3(func1(1, 2),  func2(8, 9));
23    printf("c=%d.\n", c);
24    return 0;
25 }
```

上述代码，程序入口是 main() 函数，在第 22 行 func3 使用 func1 和 func2 的返回值作为自己的参数，在第 22 行输入 **step** 命令，会先进入哪个函数呢？这里就需要补充一个知识点了—— 函数调用方式，我们常用的函数调用方式有 _cdecl 和 _stdcall，C++ 非静态成员函数的调用方式是 _thiscall 。在这些调用方式中，函数参数的传递本质上是函数参数的入栈过程，而这三种调用方式参数的入栈顺序都是从右往左的，因此，这段代码中并没有显式标明函数的调用方式，采用默认 _cdecl 方式。

当我们在第 22 行代码处输入 **step** 先进入的是 func2() ，当从 func2() 返回时再次输入 **step** 命令会接着进入 func1() ，当从 func1 返回时，此时两个参数已经计算出来了，这时候会最终进入 func3() 。理解这一点，在遇到这样的代码时，才能根据需要进入我们想要的函数中去调试。

实际调试时，我们在某个函数中调试一段时间后，不需要再一步步执行到函数返回处，希望直接执行完当前函数并回到上一层调用处，就可以使用 **finish** 命令。与 **finish** 命令类似的还有 **return** 命令，**return** 命令的作用是结束执行当前函数，还可以指定该函数的返回值。

这里需要注意一下二者的区别：**finish** 命令会执行函数到正常退出该函数；而 **return** 命令是立即结束执行当前函数并返回，也就是说，如果当前函数还有剩余的代码未执行完毕，也不会执行了。我们用一个例子来验证一下：

```
1  #include <stdio.h>
2
3  int func()
4  {
5     int a = 9;
6     printf("a=%d.\n", a);
7
8     int b = 8;
9     printf("b=%d.\n", b);
10    return a + b;
11 }
12
13 int main()
14 {
15    int c = func();
16    printf("c=%d.\n", c);
17
18    return 0;
19 }
```

在 main() 函数处加一个断点，然后运行程序，在第 15 行使用 **step** 命令进入 func() 函数，接着单步到代码第 8 行，直接输入 **return** 命令，这样 func() 函数剩余的代码就不会继续执行了，因此 printf("b=%d.\n", b); 这一行就没有输出。同时由于我们没有在 **return** 命令中指定这个函数的返回值，因而最终在 main() 函数中得到的变量 c 的值是一个脏数据。这也就验证了我们上面说的：**return**命令在当前位置立即结束当前函数的执行，并返回到上一层调用。

```
(gdb) b main
Breakpoint 1 at 0x40057d: file test.c, line 15.
(gdb) r
Starting program: /root/testreturn/test

Breakpoint 1, main () at test.c:15
15          int c = func();
Missing separate debuginfos, use: debuginfo-install glibc-2.17-196.el7_4.2.x86_64
(gdb) s
func () at test.c:5
5           int a = 9;
(gdb) n
6           printf("a=%d.\n", a);
(gdb) n
a=9.
8           int b = 8;
(gdb) return
Make func return now? (y or n) y
#0  0x0000000000400587 in main () at test.c:15
15          int c = func();
(gdb) n
16          printf("c=%d.\n", c);
(gdb) n
c=-134250496.
18          return 0;
(gdb)
```

再次用 **return** 命令指定一个值试一下，这样得到变量 c 的值应该就是我们指定的值。

```
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/testreturn/test

Breakpoint 1, main () at test.c:15
15          int c = func();
(gdb) s
func () at test.c:5
5           int a = 9;
(gdb) n
6           printf("a=%d.\n", a);
(gdb) n
a=9.
8           int b = 8;
(gdb) return 9999
Make func return now? (y or n) y
#0  0x0000000000400587 in main () at test.c:15
15          int c = func();
(gdb) n
16          printf("c=%d.\n", c);
(gdb) n
c=9999.
18          return 0;
(gdb) p c
$1 = 9999
(gdb)
```

仔细观察上述代码应该会发现，用 **return** 命令修改了函数的返回值，当使用 **print** 命令打印 c 值的时候，c 值也确实被修改成了 9999。

我们再对比一下使用 **finish** 命令来结束函数执行的结果。

```
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/testreturn/test

Breakpoint 1, main () at test.c:15
15          int c = func();
(gdb) s
func () at test.c:5
5           int a = 9;
(gdb) n
6           printf("a=%d.\n", a);
(gdb) n
a=9.
8           int b = 8;
(gdb) finish
Run till exit from #0  func () at test.c:8
b=8.
0x0000000000400587 in main () at test.c:15
15          int c = func();
Value returned is $3 = 17
(gdb) n
16          printf("c=%d.\n", c);
(gdb) n
c=9999.
18          return 0;
(gdb)
```

结果和我们预期的一样，**finish** 正常结束函数，剩余的代码也会被正常执行。因此 c 的值是 17。

实际调试时，还有一个 **until** 命令（简写为 **u**）可以指定程序运行到某一行停下来，还是以 redis-server 的代码为例：

```
1812    void initServer(void) {
1813        int j;
1814
1815        signal(SIGHUP, SIG_IGN);
1816        signal(SIGPIPE, SIG_IGN);
1817        setupSignalHandlers();
1818
1819        if (server.syslog_enabled) {
1820            openlog(server.syslog_ident, LOG_PID | LOG_NDELAY | LOG_NOWAIT,
1821                server.syslog_facility);
1822        }
1823
1824        server.pid = getpid();
1825        server.current_client = NULL;
1826        server.clients = listCreate();
1827        server.clients_to_close = listCreate();
1828        server.slaves = listCreate();
1829        server.monitors = listCreate();
1830        server.clients_pending_write = listCreate();
1831        server.slaveseldb = -1; /* Force to emit the first SELECT command. */
1832        server.unblocked_clients = listCreate();
1833        server.ready_keys = listCreate();
1834        server.clients_waiting_acks = listCreate();
1835        server.get_ack_from_slaves = 0;
1836        server.clients_paused = 0;
1837        server.system_memory_size = zmalloc_get_memory_size();
1838
1839        createSharedObjects();
1840        adjustOpenFilesLimit();
1841        server.el = aeCreateEventLoop(server.maxclients+CONFIG_FDSET_INCR);
1842        if (server.el == NULL) {
1843            serverLog(LL_WARNING,
1844                "Failed creating the event loop. Error message: '%s'",
1845                strerror(errno));
1846            exit(1);
1847        }
```

这是 redis-server 代码中 initServer() 函数的一个代码片段，位于文件 server.c 中，当停在第 1813 行，想直接跳到第 1839 行，可以直接输入 **u 1839**，这样就能快速执行完中间的代码。当然，也可以先在第 1839 行加一个断点，然后使用 **continue** 命令运行到这一行，但是使用 **until** 命令会更简便。

```
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/redis-4.0.9/src/redis-server
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".

Breakpoint 3, main (argc=1, argv=0x7fffffffe588) at server.c:3704
3704    int main(int argc, char **argv) {
(gdb) c
Continuing.
21574:C 14 Sep 06:42:36.978 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
21574:C 14 Sep 06:42:36.978 # Redis version=4.0.9, bits=64, commit=00000000, modified=0, pid=21574, just started
21574:C 14 Sep 06:42:36.979 # Warning: no config file specified, using the default config. In order to specify a config file use /root/redis-4.0.9/src/redis-server /path/to/redis.conf

Breakpoint 4, initServer () at server.c:1812
1812    void initServer(void) {
(gdb) n
1815        signal(SIGHUP, SIG_IGN);
(gdb) u 1839
initServer () at server.c:1839
1839        createSharedObjects();
(gdb)
```

**jump** 命令基本用法是：

```
jump <location>
```

**location** 可以是程序的行号或者函数的地址，jump 会让程序执行流跳转到指定位置执行，当然其行为也是不可控制的，例如您跳过了某个对象的初始化代码，直接执行操作该对象的代码，那么可能会导致程序崩溃或其他意外行为。**jump** 命令可以简写成 **j**，但是不可以简写成 **jmp**，其使用有一个注意事项，即如果 **jump** 跳转到的位置后续没有断点，那么 GDB 会执行完跳转处的代码会继续执行。举个例子：

```
1 int somefunc()
2 {
3   //代码A
4   //代码B
5   //代码C
6   //代码D
7   //代码E
8   //代码F
9 }
```

假设我们的断点初始位置在行号 **3** 处（代码 A），这个时候我们使用 **jump 6**，那么程序会跳过代码 B 和 C 的执行，执行完代码 D（ **跳转点**），程序并不会停在代码 **6** 处，而是继续执行后续代码，因此如果我们想查看执行跳转处的代码后的结果，需要在行号 **6**、**7** 或 **8** 处设置断点。

**jump** 命令除了跳过一些代码的执行外，还有一个妙用就是可以执行一些我们想要执行的代码，而这些代码在正常的逻辑下可能并不会执行（当然可能也因此会产生一些意外的结果，这需要读者自行斟酌使用）。举个例子，假设现在有如下代码：

```
1  #include <stdio.h>
2  int main()
3  {
4    int a = 0;
5    if (a != 0)
6    {
7      printf("if condition\n");
8    }
9    else
10   {
11     printf("else condition\n");
12   }
13
14   return 0;
15 }
```

我们在行号 **4** 、**14** 处设置一个断点，当触发行号 **4** 处的断点后，正常情况下程序执行流会走 else 分支，我们可以使用 **jump 7** 强行让程序执行 if 分支，接着 GDB 会因触发行号 **14** 处的断点而停下来，此时我们接着执行 **jump 11**，程序会将 else 分支中的代码重新执行一遍。整个操作过程如下：

```
[root@localhost testcore]# gdb test
Reading symbols from /root/testcore/test...done.
(gdb) b main
Breakpoint 1 at 0x400545: file main.cpp, line 4.
(gdb) b 14
Breakpoint 2 at 0x400568: file main.cpp, line 14.
(gdb) r
Starting program: /root/testcore/test

Breakpoint 1, main () at main.cpp:4
4       int a = 0;
Missing separate debuginfos, use: debuginfo-install glibc-2.17-260.el7.x86_64 libgcc-4.8.5-36.el7.x86_64 libstdc++-4.8.5-36.el7.x86_64
(gdb) jump 7
Continuing at 0x400552.
if condition

Breakpoint 2, main () at main.cpp:14
14       return 0;
(gdb) jump 11
Continuing at 0x40055e.
else condition

Breakpoint 2, main () at main.cpp:14
14       return 0;
(gdb) c
Continuing.
[Inferior 1 (process 13349) exited normally]
(gdb)
```

**redis-server** 在入口函数 **main** 处调用 **initServer()** ，我们使用 “**b initServer**” 、“**b 2025**”、“**b 2027**”在这个函数入口处、2025 行、2027 行增加三个断点，然后使用 **run** 命令重新运行一下程序，触发第一个断点后，继续输入 **c** 命令继续运行，然后触发 2025 行处的断点，接着输入 **jump 2027** ：

```
(gdb) b 2025
Breakpoint 5 at 0x42c8e7: file server.c, line 2025.
(gdb) b 2027
Breakpoint 6 at 0x42c8f8: file server.c, line 2027.
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) n
Program not restarted.
(gdb) b initServer
Note: breakpoint 3 also set at pc 0x42c8b0.
Breakpoint 7 at 0x42c8b0: file server.c, line 2013.
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/redis-5.0.3/src/redis-server
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".

Breakpoint 1, main (argc=1, argv=0x7fffffffe4e8) at server.c:4003
4003    int main(int argc, char **argv) {
(gdb) c
Continuing.
13374:C 14 Jan 2019 15:12:16.571 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
13374:C 14 Jan 2019 15:12:16.571 # Redis version=5.0.3, bits=64, commit=00000000, modified=0, pid=13374, just started
13374:C 14 Jan 2019 15:12:16.571 # Warning: no config file specified, using the default config. In order to specify a config file use /root/redis-5.0.3/src/redis-server /path/to/redis.conf

Breakpoint 3, initServer () at server.c:2013
2013    void initServer(void) {
(gdb) c
Continuing.

Breakpoint 5, initServer () at server.c:2025
2025        server.hz = server.config_hz;
(gdb) jump 2027
Continuing at 0x42c8f8.

Breakpoint 6, initServer () at server.c:2027
2027        server.current_client = NULL;
(gdb)
```

程序将 **2026** 行的代码跳过了，2026 行处的代码是获取当前进程 id：

```
2026 server.pid = getpid();
```

由于这一行被跳过了，所以 **server.pid** 的值应该是一个无效的值，我们可以使用 **print** 命令将这个值打印出来看一下：

```
(gdb) p server.pid
$3 = 0
```

结果确实是 **0** 这个我们初始化的无效值。

> 本质上，**jump** 命令的作用类似于在 Visual Studio 中调试时，拖鼠标将程序从一个执行处拖到另外一个执行处。

![img](https://images.gitbook.cn/eb4d9470-186e-11e9-b848-bfbdb26ffecb)

## disassemble 命令

当进行一些高级调试时，我们可能需要查看某段代码的汇编指令去排查问题，或者是在调试一些没有调试信息的发布版程序时，也只能通过反汇编代码去定位问题，那么 **disassemble** 命令就派上用场了。

```
initServer () at server.c:1839
1839        createSharedObjects();
(gdb) disassemble
Dump of assembler code for function initServer:
   0x000000000042f450 <+0>:     push   %r12
   0x000000000042f452 <+2>:     mov    $0x1,%esi
   0x000000000042f457 <+7>:     mov    $0x1,%edi
   0x000000000042f45c <+12>:    push   %rbp
   0x000000000042f45d <+13>:    push   %rbx
   0x000000000042f45e <+14>:    callq  0x421eb0 <signal@plt>
   0x000000000042f463 <+19>:    mov    $0x1,%esi
   0x000000000042f468 <+24>:    mov    $0xd,%edi
   0x000000000042f46d <+29>:    callq  0x421eb0 <signal@plt>
   0x000000000042f472 <+34>:    callq  0x42f3a0 <setupSignalHandlers>
   0x000000000042f477 <+39>:    mov    0x316d52(%rip),%r8d        # 0x7461d0 <server+2128>
   0x000000000042f47e <+46>:    test   %r8d,%r8d
   0x000000000042f481 <+49>:    jne    0x42f928 <initServer+1240>
   0x000000000042f487 <+55>:    callq  0x421a50 <getpid@plt>
   0x000000000042f48c <+60>:    movq   $0x0,0x316701(%rip)        # 0x745b98 <server+536>
   0x000000000042f497 <+71>:    mov    %eax,0x3164e3(%rip)        # 0x745980 <server>
   0x000000000042f49d <+77>:    callq  0x423cb0 <listCreate>
   0x000000000042f4a2 <+82>:    mov    %rax,0x3166c7(%rip)        # 0x745b70 <server+496>
   0x000000000042f4a9 <+89>:    callq  0x423cb0 <listCreate>
   0x000000000042f4ae <+94>:    mov    %rax,0x3166c3(%rip)        # 0x745b78 <server+504>
   0x000000000042f4b5 <+101>:   callq  0x423cb0 <listCreate>
   0x000000000042f4ba <+106>:   mov    %rax,0x3166c7(%rip)        # 0x745b88 <server+520>
   0x000000000042f4c1 <+113>:   callq  0x423cb0 <listCreate>
   0x000000000042f4c6 <+118>:   mov    %rax,0x3166c3(%rip)        # 0x745b90 <server+528>
   0x000000000042f4cd <+125>:   callq  0x423cb0 <listCreate>
   0x000000000042f4d2 <+130>:   movl   $0xffffffff,0x316d6c(%rip)        # 0x746248 <server+2248>
   0x000000000042f4dc <+140>:   mov    %rax,0x31669d(%rip)        # 0x745b80 <server+512>
   0x000000000042f4e3 <+147>:   callq  0x423cb0 <listCreate>
   0x000000000042f4e8 <+152>:   mov    %rax,0x316ec9(%rip)        # 0x7463b8 <server+2616>
   0x000000000042f4ef <+159>:   callq  0x423cb0 <listCreate>
   0x000000000042f4f4 <+164>:   mov    %rax,0x316ec5(%rip)        # 0x7463c0 <server+2624>
   0x000000000042f4fb <+171>:   callq  0x423cb0 <listCreate>
   0x000000000042f500 <+176>:   movl   $0x0,0x316e7e(%rip)        # 0x746388 <server+2568>
   0x000000000042f50a <+186>:   mov    %rax,0x316e6f(%rip)        # 0x746380 <server+2560>
   0x000000000042f511 <+193>:   movl   $0x0,0x316685(%rip)        # 0x745ba0 <server+544>
   0x000000000042f51b <+203>:   callq  0x432e90 <zmalloc_get_memory_size>
   0x000000000042f520 <+208>:   mov    %rax,0x316fd9(%rip)        # 0x746500 <server+2944>
=> 0x000000000042f527 <+215>:   callq  0x42a7b0 <createSharedObjects>
```

GDB 默认反汇编为 AT&T 格式的指令，可以通过 show disassembly-flavor 查看，如果习惯 intel 汇编格式可以用命令 set disassembly-flavor intel 来设置。

```
(gdb) set disassembly-flavor intel
(gdb) disassemble
Dump of assembler code for function initServer:
   0x000000000042f450 <+0>:     push   r12
   0x000000000042f452 <+2>:     mov    esi,0x1
   0x000000000042f457 <+7>:     mov    edi,0x1
   0x000000000042f45c <+12>:    push   rbp
   0x000000000042f45d <+13>:    push   rbx
   0x000000000042f45e <+14>:    call   0x421eb0 <signal@plt>
   0x000000000042f463 <+19>:    mov    esi,0x1
   0x000000000042f468 <+24>:    mov    edi,0xd
   0x000000000042f46d <+29>:    call   0x421eb0 <signal@plt>
   0x000000000042f472 <+34>:    call   0x42f3a0 <setupSignalHandlers>
   0x000000000042f477 <+39>:    mov    r8d,DWORD PTR [rip+0x316d52]        # 0x7461d0 <server+2128>
   0x000000000042f47e <+46>:    test   r8d,r8d
   0x000000000042f481 <+49>:    jne    0x42f928 <initServer+1240>
   0x000000000042f487 <+55>:    call   0x421a50 <getpid@plt>
   0x000000000042f48c <+60>:    mov    QWORD PTR [rip+0x316701],0x0        # 0x745b98 <server+536>
   0x000000000042f497 <+71>:    mov    DWORD PTR [rip+0x3164e3],eax        # 0x745980 <server>
   0x000000000042f49d <+77>:    call   0x423cb0 <listCreate>
   0x000000000042f4a2 <+82>:    mov    QWORD PTR [rip+0x3166c7],rax        # 0x745b70 <server+496>
   0x000000000042f4a9 <+89>:    call   0x423cb0 <listCreate>
   0x000000000042f4ae <+94>:    mov    QWORD PTR [rip+0x3166c3],rax        # 0x745b78 <server+504>
   0x000000000042f4b5 <+101>:   call   0x423cb0 <listCreate>
   0x000000000042f4ba <+106>:   mov    QWORD PTR [rip+0x3166c7],rax        # 0x745b88 <server+520>
   0x000000000042f4c1 <+113>:   call   0x423cb0 <listCreate>
   0x000000000042f4c6 <+118>:   mov    QWORD PTR [rip+0x3166c3],rax        # 0x745b90 <server+528>
   0x000000000042f4cd <+125>:   call   0x423cb0 <listCreate>
   0x000000000042f4d2 <+130>:   mov    DWORD PTR [rip+0x316d6c],0xffffffff        # 0x746248 <server+2248>
   0x000000000042f4dc <+140>:   mov    QWORD PTR [rip+0x31669d],rax        # 0x745b80 <server+512>
   0x000000000042f4e3 <+147>:   call   0x423cb0 <listCreate>
   0x000000000042f4e8 <+152>:   mov    QWORD PTR [rip+0x316ec9],rax        # 0x7463b8 <server+2616>
   0x000000000042f4ef <+159>:   call   0x423cb0 <listCreate>
   0x000000000042f4f4 <+164>:   mov    QWORD PTR [rip+0x316ec5],rax        # 0x7463c0 <server+2624>
   0x000000000042f4fb <+171>:   call   0x423cb0 <listCreate>
   0x000000000042f500 <+176>:   mov    DWORD PTR [rip+0x316e7e],0x0        # 0x746388 <server+2568>
   0x000000000042f50a <+186>:   mov    QWORD PTR [rip+0x316e6f],rax        # 0x746380 <server+2560>
   0x000000000042f511 <+193>:   mov    DWORD PTR [rip+0x316685],0x0        # 0x745ba0 <server+544>
   0x000000000042f51b <+203>:   call   0x432e90 <zmalloc_get_memory_size>
   0x000000000042f520 <+208>:   mov    QWORD PTR [rip+0x316fd9],rax        # 0x746500 <server+2944>
=> 0x000000000042f527 <+215>:   call   0x42a7b0 <createSharedObjects>
```

## set args 和 show args 命令

很多程序需要我们传递命令行参数。在 GDB 调试中，很多人会觉得可以使用 **gdb filename args** 这种形式来给 GDB 调试的程序传递命令行参数，这样是不行的。正确的做法是在用 GDB 附加程序后，在使用 **run** 命令之前，使用“**set args 参数内容**”来设置命令行参数。

还是以 redis-server 为例，Redis 启动时可以指定一个命令行参数，它的默认配置文件位于 redis-server 这个文件的上一层目录，因此我们可以在 GDB 中这样传递这个参数：**set args ../redis.conf**（即文件 redis.conf 位于当前程序 redis-server 的上一层目录），可以通过 **show args**查看命令行参数是否设置成功。

```
(gdb) set args ../redis.conf
(gdb) show args
Argument list to give program being debugged when it is started is "../redis.conf ".
(gdb)
```

如果单个命令行参数之间含有空格，可以使用引号将参数包裹起来。

```
(gdb) set args "999 xx" "hu jj"
(gdb) show args
Argument list to give program being debugged when it is started is ""999 xx" "hu jj"".
(gdb)
```

如果想清除掉已经设置好的命令行参数，使用 **set args** 不加任何参数即可。

```
(gdb) set args
(gdb) show args
Argument list to give program being debugged when it is started is "".
(gdb)
```

## tbreak 命令

**tbreak** 命令也是添加一个断点，第一个字母“**t**”的意思是 temporarily（临时的），也就是说这个命令加的断点是临时的，所谓临时断点，就是一旦该断点触发一次后就会自动删除。添加断点的方法与上面介绍的 break 命令一模一样，这里不再赘述。

```
(gdb) tbreak main
Temporary breakpoint 1 at 0x423450: file server.c, line 3704.
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/redis-4.0.9/src/redis-server
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".

Temporary breakpoint 1, main (argc=1, argv=0x7fffffffe588) at server.c:3704
3704    int main(int argc, char **argv) {
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/redis-4.0.9/src/redis-server
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".
21652:C 14 Sep 07:05:39.288 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
21652:C 14 Sep 07:05:39.288 # Redis version=4.0.9, bits=64, commit=00000000, modified=0, pid=21652, just started
21652:C 14 Sep 07:05:39.288 # Warning: no config file specified, using the default config. In order to specify a config file use /root/redis-4.0.9/src/redis-server /path/to/redis.conf
21652:M 14 Sep 07:05:39.289 * Increased maximum number of open files to 10032 (it was originally set to 1024).
[New Thread 0x7ffff07ff700 (LWP 21653)]
[New Thread 0x7fffefffe700 (LWP 21654)]
[New Thread 0x7fffef7fd700 (LWP 21655)]
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 4.0.9 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 21652
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
```

上述代码，我们使用 **tbreak** 命令在 main() 函数处添加了一个断点，当断点触发后，再次运行程序不再触发断点，因为这个临时断点已经被删除。

## watch 命令

**watch** 命令是一个强大的命令，它可以用来监视一个变量或者一段内存，当这个变量或者该内存处的值发生变化时，GDB 就会中断下来。被监视的某个变量或者某个内存地址会产生一个 watch point（观察点）。

我在数年前去北京中关村软件园应聘一个 C++ 开发的职位，当时一个面试官问了这样一个问题：有一个变量其值被意外地改掉了，通过单步调试或者挨个检查使用该变量的代码工作量会非常大，如何快速地定位到该变量在哪里被修改了？其实，面试官想要的答案是“硬件断点”。具体什么是硬件断点，我将在后面高级调试课程中介绍，而 watch 命令就可以通过添加硬件断点来达到监视数据变化的目的。watch 命令的使用方式是“watch 变量名或内存地址”，一般有以下几种形式：

- 形式一：整型变量

```
int i;
watch i
```

- 形式二：指针类型

```
char *p;
watch p 与 watch *p
```

> **注意**：watch p 与 watch *p 是有区别的，前者是查看 *(&p)，是 p 变量本身；后者是 p 所指内存的内容。我们需要查看地址，因为目的是要看某内存地址上的数据是怎样变化的。

- 形式三：watch 一个数组或内存区间

```
char buf[128];
watch buf
```

这里是对 buf 的 128 个数据进行了监视，此时不是采用硬件断点，而是用软中断实现的。用软中断方式去检查内存变量是比较耗费 CPU 资源的，精确地指明地址是硬件中断。

> **注意**：当设置的观察点是一个局部变量时，局部变量无效后，观察点也会失效。在观察点失效时 GDB 可能会提示如下信息：
>
> ```
> Watchpoint 2 deleted because the program has left the block in which its expression is valid.
> ```

## display 命令

**display** 命令监视的变量或者内存地址，每次程序中断下来都会自动输出这些变量或内存的值。例如，假设程序有一些全局变量，每次断点停下来我都希望 GDB 可以自动输出这些变量的最新值，那么使用“**display 变量名**”设置即可。

```
Program received signal SIGINT, Interrupt.
0x00007ffff71e2483 in epoll_wait () from /lib64/libc.so.6
(gdb) display $ebx
1: $ebx = 7988560
(gdb) display /x $ebx
2: /x $ebx = 0x79e550
(gdb) display $eax
3: $eax = -4
(gdb) b main
Breakpoint 8 at 0x4201f0: file server.c, line 4003.
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/redis-5.0.3/src/redis-server
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".

Breakpoint 8, main (argc=1, argv=0x7fffffffe4e8) at server.c:4003
4003    int main(int argc, char **argv) {
3: $eax = 4325872
2: /x $ebx = 0x0
1: $ebx = 0
(gdb)
```

上述代码中，我使用 **display** 命令分别添加了寄存器 **ebp** 和寄存器 **eax**，**ebp** 寄存器分别使用十进制和十六进制两种形式输出其值，这样每次程序中断下来都会自动把这些值打印出来，可以使用 **info display** 查看当前已经自动添加了哪些值，使用 **delete display** 清除全部需要自动输出的变量，使用 **delete diaplay 编号** 删除某个自动输出的变量。

```
(gdb) delete display
Delete all auto-display expressions? (y or n) n
(gdb) delete display 3
(gdb) info display
Auto-display expressions now in effect:
Num Enb Expression
2:   y  $ebp
1:   y  $eax
```

# GDB 实用调试技巧

## 将 print 打印结果显示完整

当使用 print 命令打印一个字符串或者字符数组时，如果该字符串太长，print 命令默认显示不全的，我们可以通过在 GDB 中输入 set print element 0 命令设置一下，这样再次使用 print 命令就能完整地显示该变量的所有字符串了。

当第一次打印 friendlist 这个变量值时，只能显示部分字符串。使用 set print element 0 设置以后就能完整地显示出来了。

```
(gdb) n
563         os << "{\"code\": 0, \"msg\": \"ok\", \"userinfo\":" << friendlist << "}";
(gdb) p friendlist
$1 = "[{\"members\":[{\"address\":\"\",\"birthday\":19900101,\"clienttype\":0,\"customface\":\"\",\"facetype\":2,\"gender\":0,\"mail\":\"\",\"markname\":\"\",\"nickname\":\"bj_man\",\"phonenumber\":\"\",\"signature\":\"\",\"status\":0,\"userid\":4,"...
(gdb) set print element 0
(gdb) p friendlist       
$2 = "[{\"members\":[{\"address\":\"\",\"birthday\":19900101,\"clienttype\":0,\"customface\":\"\",\"facetype\":2,\"gender\":0,\"mail\":\"\",\"markname\":\"\",\"nickname\":\"bj_man\",\"phonenumber\":太长了，这里省略...
```

## 让被 GDB 调试的程序接收信号

请看下面的代码：

```C
void prog_exit(int signo)
{
    std::cout << "program recv signal [" << signo << "] to exit." << std::endl;
}

int main(int argc, char* argv[])
{
    //设置信号处理
    signal(SIGCHLD, SIG_DFL);
    signal(SIGPIPE, SIG_IGN);
    signal(SIGINT, prog_exit);
    signal(SIGTERM, prog_exit);

    int ch;
    bool bdaemon = false;
    while ((ch = getopt(argc, argv, "d")) != -1)
    {
        switch (ch)
        {
        case 'd':
            bdaemon = true;
            break;
        }
    }

    if (bdaemon)
        daemon_run();

    //省略无关代码...
 }
```

在这个程序中，我们接收到 Ctrl + C 信号（对应信号 SIGINT）时会简单打印一行信息，而当用 GDB 调试这个程序时，由于 Ctrl + C 默认会被 GDB 接收到（让调试器中断下来），导致无法模拟程序接收这一信号。解决这个问题有两种方式：

- 在 GDB 中使用 signal 函数手动给程序发送信号，这里就是 signal SIGINT；
- 改变 GDB 信号处理的设置，通过 handle SIGINT nostop print 告诉 GDB 在接收到 SIGINT 时不要停止，并把该信号传递给调试目标程序 。

```
(gdb) handle SIGINT nostop print pass
SIGINT is used by the debugger. 
Are you sure you want to change it? (y or n) y  

Signal Stop Print Pass to program Description  
SIGINT No Yes Yes Interrupt
(gdb) 
```

## 函数明明存在，添加断点时却无效

有时候一个函数明明存在，并且我们的程序也存在调试符号，使用 break functionName 添加断点时 GDB 却提示：

```
Make breakpoint pending on future shared library load? y/n
```

即使输入 y 命令，添加的断点可能也不会被正确地触发，此时需要改变添加断点的方式，使用该函数所在的代码文件和行号添加断点就能达到效果。

## 多线程下禁止线程切换

假设现在有 5 个线程，除了主线程，工作线程都是下面这样的一个函数：

```
void thread_proc(void* arg)
{
    //代码行1
    //代码行2
    //代码行3
    //代码行4
    //代码行5
    //代码行6
    //代码行7
    //代码行8
    //代码行9
    //代码行10
    //代码行11
    //代码行12
    //代码行13
    //代码行14
    //代码行15
}
```

为了能说清楚这个问题，我们把四个工作线程分别叫做 A、B、C、D。

假设 GDB 当前正在处于线程 A 的代码行 3 处，此时输入 next 命令，我们期望的是调试器跳到代码行 4 处；或者使用“u 代码行10”，那么我们期望输入 u 命令后调试器可以跳转到代码行 10 处。

但是在实际情况下，GDB 可能会跳转到代码行 1 或者代码行 2 处，甚至代码行 13、代码行 14 这样的地方也是有可能的，这不是调试器 bug，这是多线程程序的特点，当我们从代码行 4 处让程序 continue 时，线程 A 虽然会继续往下执行，但是如果此时系统的线程调度将 CPU 时间片切换到线程 B、C 或者 D 呢？那么程序最终停下来的时候，处于代码行 1 或者代码行 2 或者其他地方就不奇怪了，而此时打印相关的变量值，可能就不是我们需要的线程 A 的相关值。

为了解决调试多线程程序时出现的这种问题，GDB 提供了一个在调试时将程序执行流锁定在当前调试线程的命令：set scheduler-locking on。当然也可以关闭这一选项，使用 set scheduler-locking off。除了 on/off 这两个值选项，还有一个不太常用的值叫 step，这里就不介绍了。

## 条件断点

在实际调试中，我们一般会用到三种断点：普通断点、条件断点和硬件断点。

硬件断点又叫数据断点，这样的断点其实就是前面课程中介绍的用 watch 命令添加的部分断点（为什么是部分而不是全部，前面介绍原因了，watch 添加的断点有部分是通过软中断实现的，不属于硬件断点）。硬件断点的触发时机是监视的内存地址或者变量值发生变化。

普通断点就是除去条件断点和硬件断点以外的断点。

下面重点来介绍一下条件断点，所谓条件断点，就是满足某个条件才会触发的断点，这里先举一个直观的例子：

```
void do_something_func(int i)
{
   i ++;
   i = 100 * i;
}

int main()
{
   for(int i = 0; i < 10000; ++i)
   {
      do_something_func(i);
   }

   return 0;
}
```

在上述代码中，假如我们希望当变量 i=5000 时，进入 do_something_func() 函数追踪一下这个函数的执行细节。此时可以修改代码增加一个 i=5000 的 if 条件，然后重新编译链接调试，这样显然比较麻烦，尤其是对于一些大型项目，每次重新编译链接都需要花一定的时间，而且调试完了还得把程序修改回来。

有了条件断点就不需要这么麻烦了，添加条件断点的命令是 break [lineNo] if [condition]，其中 lineNo 是程序触发断点后需要停下的位置，condition 是断点触发的条件。这里可以写成 break 11 if i==5000，其中，11 就是调用 do_something_fun() 函数所在的行号。当然这里的行号必须是合理行号，如果行号非法或者行号位置不合理也不会触发这个断点。

```
(gdb) break 11 if i==5000       
Breakpoint 2 at 0x400514: file test1.c, line 10.
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /root/testgdb/test1 

Breakpoint 1, main () at test1.c:9
9          for(int i = 0; i < 10000; ++i)
(gdb) c
Continuing.

Breakpoint 2, main () at test1.c:11
11            do_something_func(i);
(gdb) p i
$1 = 5000
```

把 i 打印出来，GDB 确实是在 i=5000 时停下来了。

添加条件断点还有一个方法就是先添加一个普通断点，然后使用“condition 断点编号断点触发条件”这样的方式来添加。添加一下上述断点：

```
(gdb) b 11
Breakpoint 1 at 0x400514: file test1.c, line 11.
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000400514 in main at test1.c:11
(gdb) condition 1 i==5000
(gdb) r
Starting program: /root/testgdb/test1 
y

Breakpoint 1, main () at test1.c:11
11            do_something_func(i);
Missing separate debuginfos, use: debuginfo-install glibc-2.17-196.el7_4.2.x86_64
(gdb) p i
$1 = 5000
(gdb) 
```

同样的规则，如果断点编号不存在，也无法添加成功，GDB 会提示断点不存在：

```
(gdb) condition 2 i==5000
No breakpoint number 2.
```

## 使用 GDB 调试多进程程序

这里说的多进程程序指的是一个进程使用 Linux 系统调用 fork() 函数产生的子进程，没有相互关联的进程就是普通的 GDB 调试，不必刻意讨论。

在实际的应用中，如有这样一类程序，如 Nginx，对于客户端的连接是采用多进程模型，当 Nginx 接受客户端连接后，创建一个新的进程来处理这一路连接上的信息来往，新产生的进程与原进程互为父子关系，那么如何用 GDB 调试这样的父子进程呢？一般有两种方法：

- 用 GDB 先调试父进程，等子进程 fork 出来后，使用 gdb attach 到子进程上去，当然这需要重新开启一个 session 窗口用于调试，gdb attach 的用法在前面已经介绍过了；
- GDB 调试器提供了一个选项叫 follow-fork，可以使用 show follow-fork mode 查看当前值，也可以通过 set follow-fork mode 来设置是当一个进程 fork 出新的子进程时，GDB 是继续调试父进程还是子进程（取值是 child），默认是父进程（ 取值是 parent）。

```
(gdb) show follow-fork mode     
Debugger response to a program call of fork or vfork is "parent".
(gdb) set follow-fork child
(gdb) show follow-fork mode
Debugger response to a program call of fork or vfork is "child".
(gdb) 
```

建议读者自己写个程序，然后调用 fork() 函数去实践一下，若要想阅读和调试 Apache HTTP Server 或者 Nginx 这样的程序，这个技能是必须要掌握的。

# 自定义 GDB 调试命令

在某些场景下，我们需要根据自己的程序情况，制定一些可以在调试时输出程序特定信息的命令，这在 GDB 中很容易做到，只要在 Linux 当前用户家（home）目录下，如 root 用户是 “**/root**” 目录，非 root 用户则对应 “**/home/ 用户名**”目录。

在上述目录中自定义一个名叫 **.gdbinit** 文件，在 Linux 系统中以点号开头的文件名一般都是隐藏文件，因此 **.gdbinit** 也是一个隐藏文件，可以使用 **ls -a** 命令查看（**a** 的含义是 **all** 的意思，即显示所有文件，当然也就包括显示隐藏文件）；如果不存在，使用 **vim** 或者 **touch** 命令创建一个就可以，然后在这个文件中写上你自定义命令的 shell 脚本即可。

以 Apache Web 服务器的源码为例（[Apache Server 的源码下载地址请点击这里](http://httpd.apache.org/)），在源码根目录下有个文件叫 .gdbinit，这个就是 Apache Server 自定义的 GDB 命令：

```c
# gdb macros which may be useful for folks using gdb to debug
# apache.  Delete it if it bothers you.

define dump_table
    set $t = (apr_table_entry_t *)((apr_array_header_t *)$arg0)->elts
    set $n = ((apr_array_header_t *)$arg0)->nelts
    set $i = 0
    while $i < $n
    if $t[$i].val == (void *)0L
       printf "[%u] '%s'=>NULL\n", $i, $t[$i].key
    else
       printf "[%u] '%s'='%s' [%p]\n", $i, $t[$i].key, $t[$i].val, $t[$i].val
    end
    set $i = $i + 1
    end
end

# 省略部分代码

# Set sane defaults for common signals:
handle SIGPIPE noprint pass nostop
handle SIGUSR1 print pass nostop
```

当然在这个文件的最底部，Apache 设置了让 GDB 调试器不要处理 SIGPIPE 和 SIGUSR1 这两个信号，而是将这两个信号直接传递给被调试的程序本身（即 Apache Server）。

# GDB TUI——在 GDB 中显示程序源码

很多 Linux 用户或者其他平台用户习惯了有强大的源码显示窗口的调试器，可能对 GDB 用 list 显示源码的方式非常不习惯，主要是因为 GDB 在调试的时候不能很好地展示源码。

GDB 中可以用 list 命令显示源码，但是 list 命令显示没有代码高亮，也不能一眼定位到正在执行的那行代码在整个代码中的位置。可以毫不夸张地说，这个问题是阻止很多人长期使用 GDB 的最大障碍，如此不便，以至于 GNU 都想办法解决了——使用 GDB 自带的 GDB TUI。

先来看一张效果图，是我在使用 GDB TUI 调试 redis-server 时的截图，这样看代码比使用 list 命令更方便。

![img](https://images.gitbook.cn/ee7aa260-eef6-11e8-9cda-75ff72aa1f8a)

## 开启 GDB TUI 模式

开启 GDB TUI 模式有两个方法。

方法一：使用 gdbtui 命令或者 gdb-tui 命令开启一个调试。

```
gdbtui -q 需要调试的程序名
```

方法二：直接使用 GDB 调试代码，在需要的时候使用切换键 **Ctrl + X + A** 调出 GDB TUI 。

## GDB TUI 模式常用窗口

![enter image description here](https://images.gitbook.cn/18b37cd0-fc41-11e8-aae4-7b05c4e3ac9c)

默认情况下，GDB TUI 模式会显示 command 窗口和 source 窗口，如上图所示，还有其他窗口，如下列举的四个常用的窗口：

- （cmd）command 命令窗口，可以输入调试命令
- （src）source 源代码窗口， 显示当前行、断点等信息
- （asm）assembly 汇编代码窗口
- （reg）register 寄存器窗口

可以通过“layout + 窗口类型”命令来选择自己需要的窗口，例如，在 cmd 窗口输入 layout asm 则可以切换到汇编代码窗口。

![img](https://images.gitbook.cn/0d2017e0-eef7-11e8-b080-ffb9f1a6f860)

layout 命令还可以用来修改窗口布局，在 cmd 窗口中输入 help layout，常见的有：

```
Usage: layout prev | next | <layout_name> 
Layout names are:
   src   : Displays source and command windows.
   asm   : Displays disassembly and command windows.
   split : Displays source, disassembly and command windows.
   regs  : Displays register window. If existing layout
           is source/command or assembly/command, the 
           register window is displayed. If the
           source/assembly/command (split) is displayed, 
           the register window is displayed with 
           the window that has current logical focus.
```

另外，可以通过 winheight 命令修改各个窗口的大小，如下所示：

```
(gdb) help winheight
Set the height of a specified window.
Usage: winheight <win_name> [+ | -] <#lines>
Window names are:
src  : the source window
cmd  : the command window
asm  : the disassembly window
regs : the register display

##将代码窗口的高度扩大 5 行代码
winheight src + 5
##将代码窗口的高度减小 4 代码
winheight src - 4
```

当前 GDB TUI 窗口放大或者缩小以后，窗口中的内容不会自己刷新以适应新的窗口尺寸，我们可以通过 space 键强行刷新 GDB TUI 窗口。

## 窗口焦点切换

在默认设置下，方向键和 PageUp/PageDown 都是用来控制 GDB TUI 的 src 窗口的，因此，我们常用上下键显示前一条命令和后一条命令的功能就没有了，不过可以通过 Ctrl + N/Ctrl + P 来获取这个功能。

> **注意**：通过方向键调整了GDB TUI 的 src 窗口以后，可以用 update 命令重新把焦点定位到当前执行的代码上。

我们可以通过 focus 命令来调整焦点位置，默认情况下焦点是在 src 窗口，通过 focus next 命令可以把焦点移到 cmd 窗口，这时候就可以像以前一样，通过方向键来切换上一条命令和下一条命令。同理，也可以使用 focus prev 切回到源码窗口，如果焦点不在 src 窗口，我们就不必使用方向键来浏览源码了。

```
(gdb) help focus  
help focus
Set focus to named window or next/prev window.
Usage: focus {<win> | next | prev}
Valid Window names are:
src  : the source window
asm  : the disassembly window
regs : the register display
cmd  : the command window
```

# GDB 高级扩展工具——CGDB

在使用 GDB 单步调试时，代码每执行一行才显示下一行，很多用惯了图形界面 IDE 调试的读者可能会觉得非常不方便，而 GDB TUI 可能看起来不错，但是存在经常花屏的问题，也让很多读者不胜其烦。那 Linux 下有没有既能在调试时动态显示当前调试处的文件代码，又能不花屏的工具呢？有的，这就是 CGDB。

CGDB 本质上是对 GDB 做了一层“包裹”，所有在 GDB 中可以使用的命令，在 CGDB 中也可以使用。

## CGDB 的安装

CGDB 的官网[请点击这里查看](http://cgdb.github.io/)，执行以下命令将 CGDB 压缩包下载到本地：

```
wget https://cgdb.me/files/cgdb-0.7.0.tar.gz
```

然后执行以下步骤解压、编译、安装：

```
tar xvfz cgdb-0.7.0.tar.gz
cd cgdb-0.7.0
./configure 
make
make install
```

CGDB 在编译过程中会依赖一些第三方库，如果这些库系统上不存在就会报错，安装一下就可以了。常见的错误及解决方案如下（这里以 CentOS 系统为例，使用的是 yum 安装方式，其他 Linux 版本都有对应的安装软件命令，请自行查找）。

（1）出现错误：

```
configure: error: CGDB requires curses.h or ncurses/curses.h to build.
```

解决方案：

```
yum install ncurses-devel
```

（2）出现错误：

```
configure: error: Please install makeinfo before installing
```

解决方案：

```
yum install install texinfo
```

（3）出现错误：

```
configure: error: Please install help2man
```

解决方案：

```
yum install help2man
```

（4）出现错误：

```
configure: error: CGDB requires GNU readline 5.1 or greater to link.
If you used --with-readline instead of using the system readline library,
make sure to set the correct readline library on the linker search path
via LD_LIBRARY_PATH or some other facility.
```

解决方案：

```
yum install readline-devel
```

（5）出现错误：

```
configure: error: Please install flex before installing
```

解决方案：

```
yum install flex
```

## CGDB 的使用

安装成功以后，就可以使用 CGDB 了，在命令行输入 cgdb 命令启动 CGDB ，启动后界面如下：

![img](https://images.gitbook.cn/7f8a9ec0-f1f6-11e8-b37f-7bcfd20d5d3a)

界面分为上下两部分：上部为代码窗口，显示调试过程中的代码；下部就是 GDB 原来的命令窗口。默认窗口焦点在下部的命令窗口，如果想将焦点切换到上部的代码窗口，按键盘上的 Esc 键，之后再次按字母 i 键将使焦点回到命令窗口。

> 注意：这个“焦点窗口”的概念很重要，它决定着你当前可以操作的是上部代码窗口还是命令窗口（ 和GDB TUI 一样）。

我们用 Redis 自带的客户端程序 redis-cli 为例，输入以下命令启动调试：

```
cgdb redis-cli
```

启动后的界面如下：

![img](https://images.gitbook.cn/9bfbcf20-f1f6-11e8-9fa2-2b61cbf641db)

然后加两个断点，如下图所示：

![img](https://images.gitbook.cn/b9032500-f1f6-11e8-b2e9-350578bd3de4)

如上图所示，我们在程序的 main ( 上图中第 2824 行 ）和第 2832 行分别加了一个断点，添加断点以后，代码窗口的行号将会以红色显示，另外有一个绿色箭头指向当前执行的行（ 这里由于在 main 函数上加了个断点，绿色箭头指向第一个断点位置 ）。单步调试并步入第 2827 行的 sdsnew() 函数调用中，可以看到代码视图中相应的代码也发生了变化，并且绿色箭头始终指向当前执行的行数：

![img](https://images.gitbook.cn/cb32e800-f1f6-11e8-b2e9-350578bd3de4)

更多 CGDB 的用法可以查阅官网，也可以参考 CGDB 中文手册，[点击这里可查看详情](https://github.com/leeyiw/cgdb-manual-in-chinese/blob/master/SUMMARY.md)。

## CGDB 的不足之处

CGDB 虽然已经比原始的 GDB 和 GDB TUI 模式在代码显示方面改进了许多，但实际使用时，CGDB 中调用 GDB 的 print 命令无法显示字符串类型中的中文字符，要么显示乱码，要么不显示，会给程序调试带来很大的困扰，这点需要注意。

总的来说，CGDB 仍然能满足我们大多数场景下的调试，瑕不掩瑜， CGDB 在 Linux 系统中调试程序还是比 GDB 方便很多。

# Windows 系统调试 Linux 程序——VisualGDB

VisualGDB 是一款 Visual Studio 插件，安装以后可以在 Windows 系统上利用 Visual Studio 强大的调试功能调试 Linux 程序。可能有读者会说，最新版的 Visual Studio 2015 或者 2017 不是自带了调试 Linux 程序的功能吗，为什么还要再装一款插件舍近而求远呢？很遗憾的是，经我测试 Visual Studio 2015 或者 2017 自带的调试程序，发现其功能很鸡肋，调试一些简单的 Linux 小程序还可以，调试复杂的或者多个源文件的 Linux 程序就力不从心了。

VisualGDB 是一款功能强大的商业软件，[点击这里详见官方网站](https://visualgdb.com/)。VisualGDB 本质上是利用 SSH 协议连接到远程 Linux 机器上，然后利用 Visual Studio 产生相应的 GDB 命令通过远程机器上的 gdbserver 传递给 GDB 调试器，其代码阅读功能建立在 samba 文件服务器之上。

利用这个工具远程调试 Linux 程序的方法有如下两种。

## 利用 VisualGDB 调试已经运行的程序

如果一个 Linux 程序已经运行，可以使用 VisualGDB 的远程 attach 功能。为了演示方便，我们将 Linux 机器上的 redis-server 运行起来：

```
[root@localhost src]# ./redis-server 
```

安装好 VisualGDB 插件以后，在 Visual Studio 的“Tools”菜单选择“Linux Source Cache Manager”菜单项，弹出如下对话框：

![img](https://images.gitbook.cn/b1d99410-f1f8-11e8-a886-5157ca7834b5)

单击 Add 按钮，配置成我们需要调试的 Linux 程序所在的机器地址、用户名和密码。

![img](https://images.gitbook.cn/d87eeb60-f1f8-11e8-9fa2-2b61cbf641db)

然后，在“Debug”菜单选择“Attach to Process...”菜单项，弹出 Attach To Process 对话框，Transport 类型选 VisualGDB，Qualifier 选择刚才我们配置的 Linux 主机信息。如果连接没有问题，会在下面的进程列表中弹出远程主机的进程列表，选择刚才启动的 redis-server，然后单击 Attach 按钮。

![img](https://images.gitbook.cn/f7341850-f1f8-11e8-a886-5157ca7834b5)

这样我们就可以在 Visual Studio 中调试这个 Linux 进程了。

![img](https://images.gitbook.cn/1d77a090-f1f9-11e8-a886-5157ca7834b5)

## 利用 VisualGDB 从头调试程序

更多的时候，我们需要从一个程序启动处，即 main() 函数处开始调试程序。在 Visual Studio 的“DEBUG”菜单选择“Quick Debug With GDB”菜单项，在弹出的对话框中配置好 Linux 程序所在的地址和目录：

![img](https://images.gitbook.cn/3bf65430-f1f9-11e8-9fa2-2b61cbf641db)

单击 Debug 按钮，就可以启动调试了。

![img](https://images.gitbook.cn/57b858d0-f1f9-11e8-b37f-7bcfd20d5d3a)

程序会自动停在 main() 函数处，这样我们就能利用强大的 Visual Studio 对 redis-server 进行调试。当然也可以在 VisualGDB 提供的 GDB Session 窗口直接输入 GDB 的原始命令进行调试。

![img](https://images.gitbook.cn/731b2670-f1f9-11e8-a886-5157ca7834b5)

没有工具是完美的，VisualGDB 也存在一些缺点，用这款工具调试 Linux 程序时可能会存在卡顿、延迟等现象。

卡顿和延迟的原因一般是由于调试远程 linux 机器上的程序时，网络不稳定导致的。如果读者调试程序所在的机器是本机虚拟机或局域网内的机器，一般不存在这个问题。

在笔者实际的使用过程中，VisualGDB 也存在一些缺点：

- VisualGDB 是一款商业软件，需要购买。当然互联网或许会有一些共享版本，有兴趣的读者可以找来学习一下。
- 由于 VisualGDB 是忠实地把用户的图形化操作通过网络最终转换为远程 linux 机器上的命令得到结果再图形化显示出来。GDB 本身对于一些代码的暂停处会存在定位不准确的问题，VisualGDB 也仍然存在这个问题。

## 扩展阅读

关于 GDB 的调试知识除了 GDB 自带的 Help 手册，国外还有一本权威的书籍 *Debugging with GDB：The The gnu Source-Level Debugger* 系统地介绍了 GDB 调试的方方面面，有兴趣的可以找来阅读一下，这里也给出书的下载链接，[请点击这里查看](https://pan.baidu.com/s/1J_JFpzrwRa-u684CZEmWKQ)。

![img](https://images.gitbook.cn/669156d0-fc59-11e8-bc5b-ef0caf885561)

GDB 调试对于 Linux C++ 开发以及阅读众多开源 C/C++ 项目是如此的重要，希望读者务必掌握它。掌握它的方法也很简单，找点程序尤其是多线程程序，实际调试一下，看看程序运行中的各种中间状态，很快就能熟悉绝大多数命令了。

关于 GDB 本身的知识，就这么多了。从下一课开始，我们将通过 GDB 正式调试 redis-server 和 redis-cli 的源码来分析其网络通信模块结构和实现思路。