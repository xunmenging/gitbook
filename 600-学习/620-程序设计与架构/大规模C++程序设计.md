[TOC]

# 预备知识

## 编程风格

### 标识符名称

成员变量不用下划线开头是因为下划线是预留给C编译器使用的

### 类成员的布局

- 生成函数（creator）

  ```
  构造。析构，拷贝
  ```

- 操纵函数（maniulators）

  ```
  operator=不是一个生成函数，但却是第一个操纵函数
  ```

- 访问函数（access）

  ```
  比如常用的set\get对
  ```

### 类设计

- 永远不要返回私有数据成员的非const指针或引用，这会破坏封装性。

- 避免将函数声明为可以重写的函数（虚函数），除非有合理的安排

- 使用枚举类型代替布尔类型，提高代码的可读性

- 尽量使用智能指针

  - 共享指针：引用计数方式，
  - 弱引用指针：包含一个指向对象的指针，通常为共享指针，但是不增加其引用计数，如果一个共享指针和一个弱指针引用了相同对象，那么当共享指针被销毁时，弱指针会立马变为null

- 将资源的申请和释放当作对象的构造和析构

- 不要将平台相关的#if或者#ifdef语句放在公共的api中，因为这些暴露了实现细节，使得api因平台而异

- 与成员函数相比，使用非成员，非友元的方法能降低耦合度

  ```c++
  如：
  // myobjecthelper.h
  namespace MyObjectHelper
  {
  	void PrintName(const MyObject& obj);
  };
  ```

  

## 逻辑设计表示法

### IsA关系

```
1、B是A的一种
class B ： public A{};
2、一般用于继承关系
```

### Uses-In-The-Interface

```c++
1、在B的接口中，B使用A。
class B{
public:
	void addFuel(A* );
}
2、如果一个类的公共成员函数的接口中使用了某个类型，那么就说这个类的接口中使用了该类型

```

###  Use-In-The-Inplement

-  被用在类的成员函数中

- 在类的数据成员的声明中被涉及

- 是类的私有继承，

  ```
  私有继承一种实现细节，但是公共继承和受保护继承却不是，继承增加了与基类相兼容的类型集合
  ```

# 基本规则

## 成员数据访问

- 保持数据私有

- 尽量少使用保护继承，以及保护成员函数，成员变量

## 全局名字空间

### 常用做法

- 将所有全局变量放在一个结构中

- 然后将他们私有化并添加静态访问函数

- 将自由函数分组到一个只包含静态函数的工具类中

### 使用规则

-  避免在文件作用于内包含带有外部链接的数据
- 避免在.h文件中使用自由函数，运算符函数除外，在.c文件中避免使用带有外部链接的自由函数，包括运算符函数
-  避免在.h文件中使用枚举，typedef，常量，但可以嵌套在类中
- 除非作为包含卫哨，否则应避免在头文件中使用预处理宏

### 冗余包含卫哨

在每个头文件的预处理器包含指示符周围放置冗余的包含卫哨

```c++
1、使用方式：
// s2.h
#ifndef INCLUDE_S2
#define INCLUDE_S2

#ifndef INCLUDE_S1
#include "s2.h"
#endif

#endif
2、好处是对于大型项目，可以节省大量的编译时间
3、否则，预处理会打开每一个头文件，并逐行进行处理
```

# 组件

## 循环物理依赖避免的方式

- 对c1和c2重新打包，以使它们不在相互依赖

- 将c1和c2在物理上组合成一个组件c12

- 将c1和c2当作一个单一的组件c12

# 层次化

## 循环依赖来源

- 允许两个组件通过include指令相知，会引入循环物理依赖

- 如果一个子系统可编译，并且单个组件的include指令隐含的依赖图时非循环的，则称这个系统时可层次化的

- 如果通层次的组件时循环依赖的，那么就有可能把互相依赖的功能从每一个组件升级为一个潜在的新的更高层次组件的静态成员。

- 如果同一层次的组件循环依赖，那么就有可能把互相依赖的功能从每一个组件降到一个潜在的较低级新组件中，每一个原来的组件都依赖于这个新的组件。

- 把一个具体的类分解为两个包含更高和更低层次功能的类可以促进层次化

- 将一个抽象的基类分解成两个类，一个类定义纯接口，另一个定义它的部分实现，可以促进层次化

## 不透明指针

如果编译函数f的函数体的时要求首先看到类型T的定义，则称函数f实质使用了类型T

```
不能调用类型T的函数
```

# 隔离

## C++结构和编译时耦合

### 解耦技巧

#### 删除枚举类型

1. 第一种是类的私有实现细节，可以将其放在.c文件中，然后在.h文件中定义一个私有的static const成员变量
2. 第二种是可公共访问的常量值。可以将其放在.c文件中，然后在.h文件中提供接口给外部使用。
3. 第三种是命名的返回状态值的枚举列表，可以将状态值分发到合适的组件中，并不要试图去重用它们

```C++
改造前：
class WhatEver
{
	enum {DEFAULT_TBL_SIZE}; // 1
public:
	enum {DEFAULT_BUF_SIZE}; // 2
	enum Status{A, B, C, D, E}; // 3
	Status doIt();
};

改造后：
.h
class WhatEver
{
	static const int s_defaultBufSize; // 2
public:
	static int getDefaultBufSize(); // 2
	enum status{A, B, C}; // 3
};

inline int getDefaultBufSize(){
	return s_defaultBufSize;
}

.c
enum {DEFAULT_TBL_SIZE=100}; // 1
const int WhatEver::s_defaultBufSize = 200; // 2
WhatEver::Status WhatEver::doIt(){///}
```

### 导致耦合的情况

- 继承和分层迫使客户端程序看到继承或嵌入对象的定义

- 内联函数和私有成员把对象的实现细节暴露给了客户端程序

- 保护成员把保护的细节暴露给了公共的客户端层序

- 编译器产生的函数，迫使实现的变化影响到声明的接口

- 包含指令，人为的制造了编译时耦合

- 默认参数，把默认值暴露给了客户端程序

- 枚举类型，不合适的位置或不适当的重用，引起不必要的编译时耦合

### 降低耦合的方式

- 通过将WasA转化为HoldsA来移除私有继承

- 通过将HasA转化为HoldsA关系来移除嵌入的数据成员

- 通过使私有成员函数成为文件作用域内静态函数，并将他们移动到.c文件中，来移除私有的成员函数

- 通过创建独立的工具组件或者提取协议来移除保护成员函数

- 通过提取协议或移动文件作用域的静态数据到.c文件，移除私有数据成员

- 通过明确定义来移除编译器产生的函数

- 通过前向声明来移除包含指令

- 通过无效的默认值来调换有效的默认值或使用多函数声明来移除默认参数

- 通过将枚举类型重新放置到.c文件中，用const静态类成员数据来替换他们，或者重新分发枚举类型到使用他们的类中，来移除枚举类型

## 整体的隔离技术

### 协议类

  满足下列条件：

  1. 它既不包含也不继承那些包含成员数据，非虚函数或任何种类私有或保护的成员的类
  2. 它有一个空实现定义的非内联虚析构函数
  3. 除虚函数以外的所有的成员函数，包含继承的函数都声明为纯虚函数而不定义

  ```C++
  简单的协议类：
  .h
  class File
  {
  public: 
  	enum From {START, CURRENT, END};
  	
  	// creator
  	virtual ~File();
  	
  	// maniputators
  	virtual void seek(int distance, From loaction) = 0;
  	virtual int read(char* buf, int numBytes) = 0;
  	
  	// accessors
  	virtual int tell(From location) = 0;
  };
  
  .c
  File::~File(){}
  
  ```

> 协议类是近乎完美的隔离器
> ​协议类可以用来消除编译时和链接时依赖

### 完全隔离类

**满足下列条件**

1. 正好包含一个数据成员，它表面上是不透明的指针，指向一个该类实现的non-const struct (定义在.c文件中)
2. 不包含任何种类的其他私有的或受保护的成员
3. 不继承任何类。
4. 不声明任何虚函数或内敛函数

```C++
例子:
.h
class FileImpl;
class File
{
public: 
	FileImpl* d_this;
public:
	File();
	File(const File& file);
	~File();
	File& operator=(const File& file);
	double value()const;
};

.c
File::File():d_this(new FileImpl){}

File::~File(){}
```

### 工具类

```C++
使用其功能时没有必要创建该类的一个实例，在那种情况下，把所有的成员函数声明为静态和非内联的，并且所有的静态成员移到.c文件中，可以避免实例化以及虚拟调用机制的开销
```

# 包

## 发布过程

### 兼容性发布

- 改变一个非内联函数的函数体

- 改变.c文件中任何有内部链接的结构

- 增加一个新的到处头文件到一个版本

- 对类增加有元声明

- 放宽一个已有的访问权限（例如，从protect到public）

- 给类增加一个新的非虚函数（有风险）

- 在头文件中增加类或自由运算符（有风险）

### 非兼容性发布

- 增加，重排序，修改，删除任何数据成员

- 增加，重排，删除任何虚函数

- 改变函数的签名或返回值

- 增加，重排序，修改，或删除任何继承关系

- 改变头文件中任何有着内部链接的结构

- 缩小一个类成员的访问权限

- 在相邻的数据成员之间引入访问限定符

## 设计规则

> 只有定义了mian的.c文件才有权重新定义全局的New和delete

## 初始化静态结构的技术

- 唤醒已初始化的，静态数据成员是一个基本类型，可以在加载时初始化

- 显式的init函数，一个组件的Init函数必须在该组件使用之前被明确的调用

- 灵巧计数器，灵巧计数器是定义在组件头文件中虚拟对象的静态实例，保证在使用对象之前，初始化

- 每次检查，在需要初始化时即时初始化，

## 辅助类策略

- 在.h文件的文件作用域中

- 在一个单独的组件中

- 作为一个或多个主要类的隶属类

- 在组件的.c文件中

- 作为一个主要类的私有的（或公共的）嵌入类

- 辅助类的决策树

  > 辅助类的选择：
  >
  > x：辅助类是否需要直接测试
  > y:内联函数是否需要访问辅助类
  > z：组件是否被广泛使用
  >
  > ￼![](%E5%A4%A7%E8%A7%84%E6%A8%A1C++%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1.assets/%E8%BE%85%E5%8A%A9%E7%B1%BB%E7%9A%84%E5%86%B3%E7%AD%96%E6%A0%91.png)
  >
  > **直接可测试	影响全局名称空间 可用于内联体 物理耦合 可被隔离 可重用**
  >
  > A 文件作用域		yes yes yes yes no no
  > B 独立的组件		yes yes yes no yes yes
  > C 隶属类			no yes yes yes no no
  > D 局部类			no no* no yes yes no
  > E 嵌套类（私有）	no no yes yes no no 
> E' 嵌套类（共有） 	yes no yes yes no no

# 函数设计

## 函数接口说明

- 对于对应的二元运算符+和*，所返回的值既不是左边的参数，也不是右边的参数，而是一个派生于这两个值的新值，因此必须通过值来返回

- c++规定下列运算符为成员

  ```C++
  = 赋值
  [] 下标
  -> 类成员访问
  () 函数调用
  (T) 转换（“cast”）运算符
  new (静态)分配符
  delete (静态)分配符
  ```

- 在函数可能返回失败的情况下，值返回或返回引用不可选，可以通过指针或者参数来标识

- 对于返回一个错误状态的函数来说，为0的整数值应该总是意味着成功

- C++语言定义阐明指针可以为空，而引用不可以为空

## 在接口中使用基本类型

- 避免在接口中使用short类型，应使用int类型
- 避免在接口中使用unsigned类型，应使用Int类型
- 避免在接口中使用long类型，assert(sizeof(int) >= 4)并使用int类型或用户自定义的大整数类型
- 在接口中对于浮点类型，只考虑使用double类型，除非有无法控制的原因才使用float类型或long double类型
- 在实际出现的大多数情况下，为了在接口中能表达整数和浮点数，所需要的唯一基本类型为int和double类型。
- 在声明虚函数的类或者派生类中，把析构函数显式的声明为类中的第一个虚函数，并且非内联的定义它

# 对象实现

## 成员数据

- 许多常见的基于risc的微处理器，依赖基本类型实例的自然对齐，自然对齐意味着内置的类型实例，int、double、char*不能驻留在任意地址上，而是必须排列在N字节的地址界上，其中N是对象的大小
- 插装全局运算符New和delete，是在系统中理解和测试动态内存分配行为简单有效的方式
- 当插装全局的new和delete时，使用iostream会产生副作用。

# 设计模式

## 单例模式

设计要点：

- GetInstance（）方法即可以返回单例类的指针，也可以返回引用，当返回指针时，客户可以删除该对象，因此最好返回引用

- 将构造函数，析构函数，拷贝函数以及赋值操作符声明为私有或受保护的，可以实现单例。

- 常见的简单的做法：

  ```c++
  Singleton& Singletion::GetInstance()
  {
  	static Singleton instance;
  	return instance;
  }
  ```

  缺点：

  - 不是线程安全的。
  - 这种技术依赖于静态变量标准的后进先出式的销毁行为，如果单例在其析构函数中调用其他单例的情况，就可能导致单例在预期时间之前被销毁。比如：Clip实例化时，会调用Log，以便输出一些诊断信息，当程序退出时，由于Log是在Clip之后创建的，因此先销毁Log，再销毁Clip，但再Clip销毁的时候会尝试调用Log，记录它被销毁的事实，可是Log已经被销毁了，则可能导致程序退出时崩溃

- 双重检查锁定模式的方式

  ```c++
  Singleton& Singleton::GetInstance()
  {
  	static Singleton* instance = null;
  	if (!instance)	// 检查1
  	{
  		static Mutex mutex;
  		ScopeLock lock(&mutex);
  		if (!instance) // 检查2
  		{
  			instance = new Singleton();
  		}
  	}
  	return *instance;
  }
  ```

  缺点：

  - 不能保证再所有编译器和所有处理器内存模型下都能正常工作。例如，共享内存的对称多处理器通常突发式提交内存写操作，这会造成不同线程的写操作重新派粗。

- 如果线程安全的getintance()的性能对你来说要求很高，可以采用下面的方式

  - 静态初始化；这需要确保构造函数不依赖其他.cpp文件中的非局部静态变量。可以在singleton.cpp文件中添加以下静态初始化调用，以确保在main调用之前创建实例，这时假定程序还是单线程的。

    ```c++
    static Singleton& foo = Singleton::GetInstance();
    ```

  - 显式api初始化，如果之前不存在初始化例程，可以考虑向库中添加一个，这样就可以从GetInstance方法中移除互斥锁，而将单例的实例化作为库初始化的一部分，并在此处添加互斥锁。

    ```c++
    Static Mutex mutex;
    void ApiInit()
    {
    	ScopeLock(&mutex);
    	Singleton::GetInstance():
    }
    ```

    > 这样做的好处式，一旦遇到单依赖的问题。可以指定所有单例的初始化顺序，显然要求用户显式初始化一个库有些不优雅，但需要提供线程安全的api，这时唯一的必要条件。

## 工厂模式

构造函数的限制：

- 没有返回值

- 命名限制，例如两个构造函数不能同时具有一个整形参数

- 静态绑定创建。在构造对象时，必须指定编译时能确定的特定类型。没有运行时绑定的功能

- 不允许虚构造函数。

  工厂模式绕开了上述限制，它通常和继承一起使用，即派生类能够重写工厂方法，并返回派生类的实例。常见的做法为使用抽象基类。

常用做法：

```c++
// RenderFactory.h
class RenderFactory
{
public:
	typedef IRender* (* CreateCallback)();
	static void Regiser(const std::string& type, CreateCallback cb);
	static void UnRegister(const std::string& type);
	static IRender* CreateRender(const std::string& type);
	
private:
	std::map<std::string, CreateCallback> m_renders;
};

// IRender.h
class IRender
{
public:
	virtual ~IRender(){}
	virtual void update();
}

// UserRender.h
class UserRender : public IRender
{
public:
	~UserRender(){}
	void Update();
	static IRender* Create(){
		return new UserRender();
	}
}
```

## MVC模式

mvc模式要求业务逻辑（model，模型）独立于用户界面（view，视图），控制器（controller）接收是、用户输入并协调另外两者。有以下优点：

- 模型和视图组件的隔离，可以实现多个用户界面，并且公用业务逻辑
- 模型和视图的解耦，简化了核心业务层编写单元测试的工作
- 允许模型和视图开发者并行工作。

> 控制器->视图->模型 控制器->模型
>
> 视图可以调用模型代码（发现最新状态并更新UI），但是反之就不行；模型代码不应该获知任何视图代码的编译时信息（因为这样会把模型绑定在一个视图上）
>
> 控制器和视图都依赖于模型，但是模型不依赖于两者。

在简单的应用中，控制器能基于用户的输入来改变模型，并通知给视图更新UI；但在真实的应用中，通常需要模型状态的改变知道到视图层，但如刚才所说，模型不能静态绑定视图。这就要借助于观察者模型了。

观察者的设计：

```c++
class IObserver
{
    public:
    virtual ~IObserver(){}
    virtual void update(int msg) = 0;
}

class ISubject
{
    public:
    ISubject();
    virtual ~ISubject();
    virtual void Subscibe(int msg, IObserver* observer);
    virtual void Unsubscribe(int msg, IObserver* observer);
    virtual void Notify(int msg);
    
    private:
    map<int, vector<IObserver*>>m_observers;
};

class MySubject : public ISubject
{
public:
	ennum Msg{ADD, REMOVE};
};

class MyObserver : public IObserver
{
public:
	void Update(int msg)
	{
		//
	}
}

int main()
{
    MyObserver ob1;
    MyObserver obj2;
    MyObserver obj3;
    MySubject sub;
    
    sub.Subsribe(MySubject::ADD, &obj1);
    sub.Subsribe(MySubject::ADD, &obj2);
    sub.Subsribe(MySubject::REMOVE, &obj2);
    sub.Subsribe(MySubject::REMOVE, &obj3);
    
    sub.Notify(MySubject::ADD);
    sub.Notify(MySubject::REMVOE);
    
}
```

缺点：

- 在销毁观察者对象之前，必须先取消订阅此观察者对象，否则，下次通知会导致崩溃。

> 观察者的类型：
>
> - 基于推的观察者：所有消息时被推送给观察者，通过给Update传递参数。
> - 基于拉的观察者：update方式仅用于发送时间产生的通知，如果观察者要获得更多细节，就必须直接查询主题对象。
> - 基于推的方案可用于在通知中发送常用的小数据，而对于大数据，推的模式效率比较低，可以采用拉的方式。
>
> 例如：用户在文本输入框中按下回车，可将用户输入的实际文本作为update的参数推给观察者，或者观察者对象调用主题的GetText方法来获取它需要的信息（拉）