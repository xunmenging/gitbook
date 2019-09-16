# gcc相关

## gcc常用的工具

### nm工具

查看可执行文件中包含的接口

```c
python@ubuntu:~/xcli-test/gdb_test$ nm a.out 
0000000000601038 B __bss_start
0000000000601038 b completed.7594
0000000000601028 D __data_start
0000000000601028 W data_start
0000000000400460 t deregister_tm_clones
00000000004004e0 t __do_global_dtors_aux
0000000000600e18 t __do_global_dtors_aux_fini_array_entry
0000000000601030 D __dso_handle
0000000000600e28 d _DYNAMIC
0000000000601038 D _edata
0000000000601040 B _end
00000000004005e4 T _fini
0000000000400500 t frame_dummy
0000000000600e10 t __frame_dummy_init_array_entry
0000000000400750 r __FRAME_END__
0000000000400526 T fun
0000000000601000 d _GLOBAL_OFFSET_TABLE_
                 w __gmon_start__
0000000000400600 r __GNU_EH_FRAME_HDR
00000000004003c8 T _init
0000000000600e18 t __init_array_end
0000000000600e10 t __init_array_start
00000000004005f0 R _IO_stdin_used
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
0000000000600e20 d __JCR_END__
0000000000600e20 d __JCR_LIST__
                 w _Jv_RegisterClasses
00000000004005e0 T __libc_csu_fini
0000000000400570 T __libc_csu_init
                 U __libc_start_main@@GLIBC_2.2.5
0000000000400540 T main
                 U printf@@GLIBC_2.2.5
00000000004004a0 t register_tm_clones
0000000000400430 T _start
0000000000601038 D __TMC_END__

```

> - T：标识是本文件中静态链接的函数，比如fun（包括静态链接的库）
>
>
> - U：标识是外部链接的函数，比如printf（动态库）
>
>
> - 程序的入口是：_start
>
>
> - c程序的入口是：main

### file工具

查看文件的类型

```
python@ubuntu:~/xcli-test/gdb_test$ file a.out 
a.out: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/l, for GNU/Linux 2.6.32, BuildID[sha1]=d9a2971a35198f68136f6e6296a1cb9d2e1a9658, not stripped

```

> ELF 64-bit LSB executable：可执行文件

### addr2line工具

地址转行号和文件名

### strings工具

打印某个文件的可答应你字符串

### strip工具

丢弃目标文件中的全部或者特定符号，减少文件体积

### readelf工具

显式elf格式可执行文件的信息

### strace工具

跟踪程序生成的系统调用，查看参数及返回值，比如

```shell
strace cat foo
```



## gcc常用的命令参数

- gcc -V：查看gcc的版本

- gcc main.c -v：查看编译，链接的详细过程，包括第三方目标文件

- gcc -c main.c -v：查看搜索头文件的过程

  ```
  python@ubuntu:~/xcli-test/gdb_test$ gcc -c main.c -v
  Using built-in specs.
  COLLECT_GCC=gcc
  Target: x86_64-linux-gnu
  #include "..." search starts here:
  #include <...> search starts here:
   /usr/lib/gcc/x86_64-linux-gnu/5/include
   /usr/local/include
   /usr/lib/gcc/x86_64-linux-gnu/5/include-fixed
   /usr/include/x86_64-linux-gnu
   /usr/include
  
  ```

## 静态库

### 制作过程

- 将要加入到库文件中的源文件编译成目标文件

- 将目标文件打包

  ```
  ar -r libtmath.a *.o
  ```

- 使用静态库文件，

  ```
  gcc main.c -I./ -L./ -ltmath
  ```

  > - 在默认情况下会优先链接动态库，次链接静态库文件
  >
  > - -L：路径名，存放静态库的路径名
  >
  > - -l库名：链接的库文件
  > - -I：头文件的路径


## 搭建交叉编译链的环境

- 下载gcc的工具包
- 可以在/etc/environment文件中指定下载的gcc的bin目录
- 修改makefile

- 工具链的下载地址：www.linaro.org/downloads

# arm体系结构

## 相关的工具

### QEMU

### busyBox

### scratchbox

### u-boot

# USB

## 常用命令

- lsusb -v

  列出详细的Usb设备信息

## 传输方式

- 中断传输：例如鼠标

  这里的中断和硬件上下文中的中断不宜样，他不是设备主动发送一个中断请求，而是主机控制器在保证不大于某个时间间隔内安排一个传输（类似主机的轮询机制）







