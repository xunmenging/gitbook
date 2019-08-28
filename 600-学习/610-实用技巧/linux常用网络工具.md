[TOC]

# 设置ip地址

## 以DHCP方式配置网卡

1. 编辑文件/etc/network/interfaces

   ```
   sudo vi /etc/network/interfaces
   ```

2. 并用下面的行来替换有关eth0的行：

   ```
   # The primary network interface - use DHCP to find our address
   auto eth0
   iface eth0 inet dhcp
   ```

3. 用下面的命令使网络设置生效：

   ```
   sudo /etc/init.d/networking restart
   ```
   

> dhcp方式下不用设置dns服务器地址，dncp服务器会自动去选择一个可用的dns地址

## 为网卡配置静态IP地址

1. 编辑文件/etc/network/interfaces

2. 并用下面的行来替换有关eth0的行

   ```
   auto ens33
   iface ens33 inet static
   address 192.168.165.133
   gateway 192.168.165.2
   netmask 255.255.255.0
   broadcast 192.168.165.255
   dns-nameservers 8.8.8.8
   ```

   > - ens33为我的机器的网卡名，实操中需要根据实际机器的网卡名进行替换
   > - dns-nameservers一定要在该文件中设置，否则ping baidu.com会出现unknown host的错误
   >
   > - 不能直接修改 /etc/resolv.conf，这个文件是resolvconf程序动态创建的，不要直接手动编辑，修改将被覆盖。
   > - 当设置成功以后，就会发现/etc/resolv.conf文件中自动添加了一行：nameserver 8.8.8.8
   > - 静态ip方式下必须设置dns服务器的地址。

3. sudo /etc/init.d/networking restart

# ifconfig

```
sudo ifconfig eth0 down/up
sudo ifconfig eth0 192.168.102.123
```

# netstat

```
-a (all)显示所有选项，默认不显示LISTEN相关
-t (tcp)仅显示tcp相关选项
-u (udp)仅显示udp相关选项
-n 拒绝显示别名，能显示数字的全部转化成数字。
-l 仅列出有在Listen (监听) 的服務状态
-p 显示建立相关链接的程序名
-r 显示路由信息，路由表
-e 显示扩展信息，例如uid等
-s 按各个协议进行统计
-c 每隔一个固定时间，执行该netstat命令。
```

> 提示：LISTEN和LISTENING的状态只有用-a或者-l才能看到
> sudo netstat -anp | grep ftp