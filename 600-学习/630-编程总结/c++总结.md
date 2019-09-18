[TOC]

# 跨平台开发

对于不同平台或者是不同实现方式的函数，可以独立在c文件中，并且用static进行声明，然后使用者包含其c文件。

# 线程

活跃进程数一般控制在操作系统能够同时执行的进程数或者线程数的4到10之间，比如4核处理器下的最佳线程数是十几个。

# 容器

## 迭代器

```c++
vector<int>::iterator it1;
vector<Teacher>::iterator it2;
it1的型别其实就是Int*,it2的型别其实就是Teacher*.
```

# 异常

## 异常的栈解旋

异常被抛出后，从进入try块起，到异常被抛掷前，这期间在栈上构造的所有对象，都会被自动析构。析构的顺序与构造的顺序相反，这一过程称为栈的解旋(unwinding)

> 结论：不能在析构函数中抛出异常

## 异常接口声明

**声明规范**

- 为了加强程序的可读性，可以在函数声明中列出可能抛出异常的所有类型，例如：void func() throw(A,B,C);这个函数func能够且只能抛出类型A,B,C及其子类型的异常。
- 如果在函数声明中没有包含异常接口声明，则此函数可以抛任何类型的异常，例如:void func()
- 一个不抛任何类型异常的函数可声明为:void func() throw()
- 如果一个函数抛出了它的异常接口声明所不允许抛出的异常,unexcepted函数会被调用，该函数默认行为调用terminate函数中断程序。该规则在linux下和qt下是成立的，在window下不成立，

## 异常的多态使用

**常用做法**

```c++
//异常基类
class BaseException{
public:
    virtual void printError(){};
};

//空指针异常
class NullPointerException : public BaseException{
public:
    virtual void printError(){
        cout << "空指针异常!" << endl;
    }
};
//越界异常
class OutOfRangeException : public BaseException{
public:
    virtual void printError(){
        cout << "越界异常!" << endl;
    }
};

void doWork(){
    throw NullPointerException();
}

void test()
{
    try{
        doWork();
    }
    catch (BaseException& ex){
        ex.printError();
    }
}
```

# 流

## cerr流对象

cerr流对象是标准错误流，cerr流已被指定为与显示器关联。cerr的 作用是向标准错误设备(standard error device)输出有关出错信息。

> cerr与标准输出流cout的作用和用法差不多。但有一点不同：cout流通常是传送到显示器输出，但也可以被重定向输出到磁盘文件，而cerr流中的信息只能在显示器输出。当调试程序时，往往不希望程序运行时的出错信息被送到其他文件，而要求在显示器上及时输出，这时 应该用cerr。cerr流中的信息是用户根据需要指定的。

## clog流对象

clog流对象也是标准错误流，它是console log的缩写。

> 它的作用和cerr相同，都是在终端显示器上显示出错信息。区别：cerr是不经过缓冲区，直接向显示器上输出有关信息，而clog中的信息存放在缓冲区中，缓冲区满后或遇endl时向显示器输出。

# bug列表

- 在-o2模式下，负数浮点数转换为byte，会强制转换为0；

> https://www.embeddeduse.com/2013/08/25/casting-a-negative-float-to-an-unsigned-int/
> https://stackoverflow.com/questions/10541200/is-the-behaviour-of-casting-a-negative-double-to-unsigned-int-defined-in-the-c-s

	Casting a negative float to an unsigned int
	… is a very bad idea. The result of the cast differs depending on whether the cast is executed on a device with Intel or ARM architecture. The C++ Standard decrees that the result of such a cast is undefined.
	
	When we run the two lines of code
	
	float f = -5.33;
	unsigned int n = static_cast<unsigned int>(f);
	on a device with Intel architecture, n has the value 4294967291, which is equivalent to 2 ^ 32 – 5. The two’s complement representation of -5 for 32 bits was the result desired by the code author.
	When we run these two lines of code on a device with ARM architecture, however, n has the value 0. Actually, every negative floating point number less than or equal to -1 comes out as 0. By the way, the result is the same if we remove the static_cast. Then, the conversion is done implicitly.
	A post at StackOverflow points us to Section 6.3.1.4 Real floating and integer of the C++ Standard for an explanation to our problem:
	
	In other words, the two’s complement of a negative float need not be computed. The safe range for casting a negative float to an unsigned int is from -1 to the maximum integer number that can be represented by this unsigned integer type.
	A possible solution of our problem is to cast the floating point number to a signed integer number first and then to an unsigned integer number.
	
	float f = -5.33;
	unsigned int n = static_cast<unsigned int>(static_cast<int>(f));
- 很多处理器同样要求程序指令的对齐。多数RISC芯片要求指令必须对齐在4字节的边

# C++类型转换

- static_cast 静态类型转换

  所谓的静态,即在编译期内即可决定其类型的转换,用的也是最多的一种。

- dynamic_cast 子类和父类之间的多态类型转换

- const_cast 去掉const属性转换

- reinterpret_cast 重新解释类型转换

  interpret 是解释的意思,reinterpret 即为重新解释,此标识符的意思即为数据的二进制形式重新解释,但是不改变其值。

# 中断

## 中断的有效用法

- 对于一个高性能的设备，它处理请求很快，通常在cpu第一次轮询时就可以返回结果，此时如果使用中断，反而会使系统变慢；切换到其他进程，处理中断，然后再换回之前的进程，代价不小。
- 另一个不要使用中断的场景时网络，网络端接收到大量数据包，如果每一个包都发生一次捉中断，那么有可能使得系统发生活锁，即不断处理中断而无法处理应用用户层的请求。
- 另一个基于中断的优化是合并，设备在抛出中断之前往往会等待一小段时间，在次期间，其他请求可能很快就会完成，因此多次中断可以合并为一次中断抛出，从而降低处理中断的代价。

- 