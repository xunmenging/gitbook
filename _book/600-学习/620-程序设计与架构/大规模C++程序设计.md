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

### 命名规范

- 数据成员用m开头，如：m_data
- 静态数据成员用s开头，如：s_instance;
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

### 过程控制

把编译器的警告当错误处理，编译时使用诸如-Wextra和-Weffc++之类的额外检查

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

# 设计

## 设计的过程

- 分析：需求、用例、用户故事
- 设计：架构、类设计、方法设计
- 实现：编码、测试、文档

## 用例

用例模板

> 名字：用例的唯一标识，经常动词+名词的形式，如提取现金
>
> 版本号：用于区分用例的不同版本的数字
>
> 描述：简洁的综述，即对用例的总结
>
> 目标：描述用户想完成什么
>
> 参与者：参与者的作用时想要完成目标
>
> 利益相关者：对用例的产生非常有兴趣的个人或组织
>
> 基本过程：描述事件过程的步骤。
>
> 扩展：引起步骤变更的条件列表
>
> 触发器：触发用例的事件
>
> 前置条件：触发器成功执行所需条件的列表
>
> 后置条件：描述用例成功执行之后系统的状态。
>
> 注释：不适用于其他任何分类的附加信息。

用例实例

> 名字：输入密码
>
> 版本号：1.0
>
> 描述：用户输入密码验证其银行账户信息
>
> 目标：系统验证用户密码
>
> 利益相关者：
>
> 1. 用户要使用atm服务
> 2. 银行要验证用户的账户
>
> 基本过程：
>
> 1. 系统验证atm卡是否可以在该机器上使用
> 2. 系统提示用户输入密码
> 3. 用户输入密码
> 4. 系统检查木马的正确性
>
> 扩展：
>
> 1. 系统无法识别atm卡
>    - 系统显式错误信息，并退出该操作
> 2. 用户输入的密码无效
>    - 系统显式错误信息，并重试
>
> 触发器：用户将卡插入atm
>
> 后置条件：用户密码有效，可以进行金融交易

## api设计要点

### 架构设计

#### 开发api架构的步骤

- 收集用户需求
- 确定约束
- 创建关键对象
- 交流设计方案

#### 架构的约束

- 组织约束
  - 预算
  - 时间表
  - 团队大小及专业知识
  - 软件开发过程
  - 决定子系统是自己构建还是购买
  - 管理焦点
- 环境因素
  - 硬件（比如机顶盒或移动设备）
  - 平台（比如windows，Mac或linux）
  - 软件约束（比如使用其他api）
  - 客户端/服务器约束（比如构建web服务）
  - 协议约束（比如邮件客户端使用pop协议，还是imap协议）
  - 数据库约束（比如必须链接到远程数据库）
  - 开发工具
- 运行因素
  - 性能
  - 内存利用率
  - 可靠性
  - 可用性
  - 并发性
  - 可定制性
  - 可扩展性
  - 脚本功能
  - 安全性
  - 国际化
  - 网络带宽

#### 架构模式

- 结构化模式：分层模式，管道与过滤器模式和黑板模式
- 交互式系统：模型-视图-控制器模式，模型-视图-表示器模式，以及表示-抽象-控制模式
- 分布式系统：客户端/服务器模式，三层架构，点对点模式以及代理模式
- 自适应系统：微内核，反射模式

> 要避免api各个组件间的循环依赖

### 类的设计

> 要集中精力设计定义API 80%功能的20%类

#### 类设计选项

- 继承的使用；将类添加到现有的继承层级结构中是否合适？应该为公有继承，还是私有继承，应该支持多重继承码？

  - 避免使用深度继承树，多于两层或三层的继承层级已经很复杂了
  - 使用纯虚函数强制子类提供实现
  - 不要为现有接口增加新的纯虚函数
  - 不要过度设计
  - 组合优先于继承

  > 除非使用接口和mixin类，否则要必要多重继承

- 组合的使用；将一个关联的对象用作数据成员是否合理

- 抽象接口的使用；打算将该类设计为抽象基类以使子类重写各个纯虚函数码？

- 标准设计模式的使用；

- 初始化与析构模型；对象的创建和删除是让客户端通过New和delete实现，还是用工厂方法进行管理？是否要为自己的类重载New、delete定制内存分配行为？要使用智能指针？

- 定义复制构造函数和赋值操作符；如果这个类分配了动态内存，那么这两个都需要定义，当然析构也需要定义。

- 模板的使用；如果是一族类型的化，可以考虑

- const和explicit的使用；尽可能将参数，返回值，方法定义为const；对于单参数构造函数使用explicit关键字以避免以外的类型转换

- 定义操作符；定义类需要的操作符。如+，*=，==或者<<等

- 定义类型转换操作符；考虑是否希望设计的类自动转换为其他类型并声明适当的转换操作符

- 友元的使用；友元会破坏类的封装，友元的出现往往是设计变坏的征兆，不到万不得已不用

- 非功能性约束；像性能和内存使用情况这样的问题也会约束类的设计

> 迪米特法则指出，应该只调用自己类或者直接相关对象的函数，避免链式调用，比如：
>
> void MyClass::MyFun()
>
> {
>
> ​	mObjectA.GetObjectB()->DoAction();
>
> }

### 函数设计

#### 函数设计选项

自由函数

- 静态还是非静态函数
- 参数以值，引用，还是指针的形式传递
- 参数以常量，还是非常量的形式传递
- 是否通过默认值使用可选参数
- 结果以值，引用，还是指针的形式返回
- 结果以常量还是非常量形式返回
- 使用操作符函数还是以非操作符函数
- 异常规格说明的使用

成员函数

- 虚函数，还是非虚函数
- 纯虚函数，还是非
- const成员函数，还是非const
- 成员函数的访问权限是public,protect,还是private
- 对于非默认构造函数是否使用explicit关键字
- 友元函数非友元
- 内联函数还是非内联

#### 函数命名

常见的互补术语

> add/remove, begin/end,create/destroy,enable/disable,insert/delete,lock/unlock.
>
> next/previous,open/close,push/pop,send/receive,show/hide,source/target

#### 错误处理

- 返回错误码

  > 如果希望函数即返回一个错误码，又返回一个结果，那么典型的解决方法是将错误码作为函数的返回值，再使用一个输出参数让函数去填充结果值

- 抛出异常

  - 从std::exception类派生自己的异常，并定义what()方法来描述失效信息
  - 考虑使用RAII技术来维护异常安全行，也就是确保再抛出异常时资源能够正确清理
  - 确保再函数的注释中将它可以排除的所有异常文档化
  - 为坑内遇到的逻辑错误创建异常，而不是为你发起的每个个别的物理错误单独创建的异常。
  - 如果你时再自己的代码中处理异常，那么你应该以引用的方式捕获异常，这样就可以避免调用抛出对象的拷贝构造函数。同样应该避免使用catch(...)语法，因为又的编译器再出现编程错误时也会抛出异常，比如assert或段错误
  - 如果一个异常是从多个异常基类继承而来，应该使用虚继承来避免客户代码捕获异常时的二义性和微妙错误

  > 异常的使用是个”要么全有，要么全无“的命题，不能部分使用，部分不使用

- 终止程序

# 风格

## 纯C API

> 因为C没有namespace关键字，要避免与其他库的名字发生冲突，所有公开的函数和数据结构应该使用一个公共的前缀

- 模拟C++风格

  ```c
  typdef struct stack* stackPtr;
  stackPtr stackCreate();
  void stackDestroy(stackPtr stack);
  int stackPop(stackPtr stack);
  ```

- 将C API包装再extern "C"构造块中

  ```c
  #ifdef __cplusplus
  extern "C" {
  #endif
  
      // C api 声明
      
  #ifdef __cplusplus
  }
  #endif
      
  ```

## 面向对象的C++ API

## 基于模板的API

可参考的几个基于模板的api的示例，

- 标准模板库 stl
- boost
- loki，《现代C++设计》实现了各种设计模式，如访问者模式，单例模式，抽象工厂模式。该库的设计非常的优雅，是基于模板的api设计的极佳典范

```C++
模板的案例：
template<typename T> class stack
{
  public:
    void Push(T val);
    
   private:
    	std::vector<T>mStack;
};
可以使用宏来实现：
#define DECLARE_STACK(Prefix,T)\
class Prefix##Stack \
{\
public:\
	void Push(T val);\
private:\
	std::vector<T>mStack;\
};
DECLARE_STACK(Int, int);
```

模板的优点：可以定制实现

```c++
template <>
void Stack<int>::Push(int val)
{}
```

模板的缺点：

- 类模板的定义通常必须出现再公开的头文件中，会暴露细节

  > 可以使用显式实例化技术将模板的实现隐藏再cpp文件中。

- 出现错误时，编译器的报错信息冗长且令人困惑

  > 可以使用BD公司的STLFilt实用工具

## 数据驱动型API

- func(obj, a, b, c)=纯C风格的函数
- obj.func(a, b, c)=面向对象的C++函数
- send("func", a, b, c)=带参数的数据驱动型函数
- send("func", dict(arg1=a,arg2=b,arg3=c))=带有命名参数组成的词典表的数据驱动型函数（伪代码）

优点：

- 程序的业务逻辑可以通过抽象到由人拉编辑的数据文件之中

- 对于apii将来可能发生的变化，它的容错力更强

  ```c++
  s = new stack();
  s->command("push", ArgList().Add("val", 10).Add("val2", 12));
  Result r = s->Command("Top");
  int top = r.toInt(); // top = 3
  ```

- 适用于数据通信接口，如web服务或客户端、服务器间的消息传递。

缺点：

- 运行开销
- 头文件无法反映逻辑接口

# C++用法

## 命名空间

- 给所有的公有api添加唯一前缀。其优势在于c函数，如：png_read_row()、glCreate()

- 使用C++的namespace关键字。如：

  ```c++
  namespace MyApi
  {
  	class String
  	{
  	//
  	}
  };
  ```

## 构造函数和赋值

### 拷贝构造函数调用时机

  - 对象以值传递的方式或返回
  - 对象使用MyClass a=b初始化
  - 对象位于在花括号中的初始化列表内
  - 对像在异常中被抛出或捕获

### 赋值操作符的实现原则

  - 为右侧操作符数使用const引用
  - 以引用方式返回*this，以支持操作符链
  - 在设置新状态前销毁已存在的状态
  - 通过比较this和&rth检测自赋值（a=a）

### 控制编译器生成的函数

  ```C++
  生成默认的函数：
  class MyClass
  {
  public:
  	virtual ~MyClass()=default;
  	
  private:
  	MyClass()=default;
  };
  
  禁用函数：
  class noncopy
  {
    public:
      	noncopy()=defult;
      	noncopy(const noncopy&)=delete;
      	noncopy & operator=(const noncopy&)=delete;
  };
  以上特性为C11特性
  ```

##   const正确性

- 方法的const正确性

- 参数const正确性

  > 尽可能早的将函数和参数声明为const，过后修正api的const正确性会耗时又麻烦。

- 返回值的const正确性

  > 这种情况下，还要考虑返回的指针或引用是否会比类存在得更久，如果又这个可能，就应该考虑返回一个引用计数指针，比如share_ptr
  >
  > 首选传值方式，而不是const引用的方式返回函数的结果，因为既不用担心客户在对象被销毁以后仍继续持有引用，也不会因为返回const引用而破坏封装性。

## 模板

### 隐式实例化api

意味着编译器必须找到一个合适的位置插入代码，并保证只有一份代码实例存在，以避免重复符号链接错误。会使代码膨胀，延长编译和连接期；

常用做法：将所有的模板实现细节包含在单独的实现头文件中，该头文件被主要公有头文件包含，以stack模板为例

```c++
// stack.h
template <typename T>
class Stack
{
  public: 
    void Push(T val);
    
  private:
    std::vector<T>mStack;
};
#include "stack_priv.h"

// stack_priv.h
template <typename T>
void Stack<T>::Push<T val>
{
	//
}

```

> boost库采用上述技巧

### 显式实例化

允许将模板实现移入cpp文件，以使对用户隐藏。

```c++
// stack.h
template <typename T>
class Stack
{
  public: 
    void Push(T val);
    
  private:
    std::vector<T>mStack;
};
typedef Stack<int> IntStack;
typedef Stack<Double> DoubleStack;
typedef Stack<std::string> StringStack;

// stack.cpp
template <typename T>
void Stack<T>::Push<T val>
{
	//
}
// 显式模板实例化
template class Stack<int>;
template class Stack<double>;
template class Stack<std::string>;
```

> 该风格降低了#include与API的耦合度，同时减少了客户程序因为包含api而必须每次编译的额外代码
>
> 如果只需要一些确定的特化集合，那么尽量选择显式模板实例化，这样就可以隐藏私有细节并降低构建时间。
>
> gnu c++和Intel icc编译器设置-fno-implicit-templates选项来关闭隐式实例化功能
>
> C++11中添加了对extern模板的支持，也就是可以使用extern关键字阻止编译器在当前编译单元中实例化一个模板。

## 操作符重载

c++标准将下列操作符声明为成员方法，以确保它们接收左值（指代对象的表达式），作为第一个操作数：

- =赋值
- []下标
- ->类成员访问
- ->*指针成员选择
- ()函数调用
- (T)类型转换，即C风格的转换
- New/delete

其余的可重载操作符即可以定义为自由函数，也可以定义为类的成员函数。建议尽量选择自由函数，而不是成员函数，原因如下：

- 操作符对称性，如果将\*定义为成员函数，只允许编写curreny\*2表达式，不能编写2\*curreny表达式
- 降低耦合性

> 除非操作符必须访问私有成员函数，或者受保护的成员，或他是=、[]、->、->*、()、（T）、new、delete中的一个，否则应该将其声明为自由函数。

### 操作符及其在api中的声明语法

```c++
赋值：x=y	T1& T1::operator=(const T2&y);
解引用：*x	T1& operator *(T1& x);
引用：&x	T1* operator &(T1& x);
类成员访问：x->y	T2* Top1::operator ->();
指针成员选择：x->*y	T2 T1::operator->*(T2 T1::*);
数组下标：x[n]	T2& T1::operator [](unsigned int n);
				T2& T1::operator [](const std::string &s);
函数调用：x()  void T1::operator()(T2& x);
				T2 T1::operator()（）const;
C风格转换：(y)x	T1::operator T2()const;
一元正号：+x	T1 operator +(const T1& x);
加：x+y	T1 operator +(const T1&x, const T2&y);
加后赋值：x+=y T1& operator +=(T1&x, const T2& y);
前置自增：++x T1& operator ++(T1& x);
			T1& T1::operator ++();
后置自增：x++ T1 operator ++(T1& x, int);
			T1 T1::operator ++(int);
相等：x==y bool operator ==(const T1& x, const T2& y);
		bool T1::operator ==(const T2& y)const;
逻辑非：!x  bool operator !(const T1& x);
			bool T1::operator !()const;
左移：<< T1 operator <<(const T1& x, const T2& y);
			ostream& operator <<(ostream &, const T1& x);
			T1 T1::operator <<(const T2& y)const;
按位取反：~x T1 operator ~(const T1& x);
			T1 T1::operator ~()const;
分配对象：new void* T1::operator new(size_t n);
分配数组：new[] void* T1::operator new[](size_t n);
释放对象：delete void T1::operator delete(void* x);
释放数组：delete[] void T1::operator delete[](void* x);
```

## 函数参数

### 引用和指针参数

> 尽量在可行的地方为输入参数使用const引用，而非指针。对于输出参数，考虑使用指针而不是非const引用，以便显式的向客户表明它们可能被修改。

### 默认参数

> 当默认值会暴露实现中的常量时，尽量选择函数重载，而不是默认参数，
>
> 如果默认参数时一个无效值或空值，那么这种做法不太可能在多个api版本之间发生变化，就没必要重载了，

### 尽量避免使用#define定义常量

> 使用静态const数据成员而非#define表示类常量
>
> 使用enum

## 导出符号

> 使用内部链接以便隐藏cpp文件内部的，具有文件作用域的自由函数和变量，使用static关键字，或匿名命名空间

导出和编译器有关：

- vs2xxx；dll中的符号不可访问，可以使用\_\_desclspec(dllexport)导出符号，客户使用\_\_desclspec(dllimport)才能访问相同的符号
- gnu c++编译器：动态库中具有外部链接的符号默认为可见的。不过可以通过\_\_attribute\_\_可见性修饰符显式隐藏一个符号。gnuc++4.0编译器引入了\_\_fvisibility_hidden标记，它强制所有声明在默认情况下隐藏可见性，个别符号可以通过\_\_attribute\_\_((visiblitity)("default"))显式导出。这更像windows的行为，使用\_\_fvisibility_hidden标记还可以显式提升动态库的加载性能，并生成更小的库。

可以使用DLL_PUBLIC宏，显式导出符号，定义DLL_HIDDEN宏，隐藏符号，例如：

```c++
#if defined _WIN32 || defined __CYGWIN__
	#ifdef __EXPORTING // 生成dll时定义它
		#ifdef __GNUC__
			#define DLL_PUBLIC __attribute__((dllexport))
		else
            #define DLL_PUBLIC __declspec(dllexport)
        #endif
    #else
        #ifdef __GNUC__
			#define DLL_PUBLIC __attribute__((dllimport))
		#else
			#define DLL_PUBLIC __declspec((dllimport))
		#endif
	#endif
	#define DLL_HIDDERN
#else
	#if __GNUC__ >= 4
		#define DLL_PUBLIC __attribute__((visibility("default")))
		#define DLL_PUBLIC __attribute__((visibility("hidden")))
	#else
		#define DLL_PUBLIC
		#define DLL_HIDDERN
	#endif
#endif
 
例如：导出api中的一个类或者函数，可以这样做：
DLL_PUBLIC void MyFunction();
class DLL_PUBLIC MyClass;
```

> 应该显式导出公有api的符号，以便维持对动态库中类，函数，和变量访问行的直接控制，对于gnuC++，可以使用\_\_fvisibility\_\_hidden选项

# 性能

> 为优化api，应使用工具收集代码在真实运行实例中的性能数据，然后把优化精力集中在实际的瓶颈上，不要猜测性能瓶颈的位置

性能优化的几个方面

- 编译时速度
- 运行时速度
- 运行时内存开销
- 库的大小
- 启动时间

## 通过const引用传递输入参数

> 引用可以避免创建和销毁对象的临时副本，及副本中所有的成员和继承对象的内存与性能开销
>
> 这条规则对于int, bool, float， double,char等内置类型不适用。它们已经很小了，能够放进cpu寄存器
>
> 此外，对于stl迭代器和函数对象也是采用值传递的方式，也不适用

## 最小化#include依赖

### 避免“无所不包型”头文件

### 前置声明

- 不需要知道类的大小。如果包含的类要作为成员变量或者打算从包含类派生子类，那么编译器需要知道类的大小
- 没有引用类的任何成员方法。引用类的成员方法需要知道方法原型，及参数和返回值类型。
- 没有引用任何成员变量，

> 一般来说，只有在自己的类中，将某个类的对象作为数据成员使用时，或者需要继承某个类时，才应该包含那个类的头文件。
>
> 头文件应该#include或者前置声明其所有的依赖项

### 冗余的#Include警戒语句

```c++
#ifndef INCLUDE_SRC_H
#define INCLUDE_SRC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#endif
```

## 声明常量

> 应使用extern声明全局作用域的常量，或者在类中以静态const 方式声明常量，然后再.cpp文件中定义常量值，这样就可以减少了包含这些头文件的模块的目标文件大小，更可取的方法是将这些常量隐藏再函数调用的背后。

```C++
class MyApi
{
public:
    static int GetMaxNameLen();
    static std::string GetLogFileName();
};
```

> 缺点：不能再编译时计算const表达式的值，因为实际的值隐藏再cpp文件中了。
>
> C++11引入了constexpr关键字，可以解决这个问题；
>
> constexpr int GetTableSize(int elem){return elem * 2;}

## 初始化列表

> 使用构造函数初始化列表，从而为每个数据成员较少一次调用构造函数的开销，这些应该再cpp文件中声明，以便隐藏实现细节。

注意事项：

- 初始化列表中的变量顺序必须和类中指定的顺序一致
- 不能再初始化列表中指定数组。
- 如果声明的时派生类，那么每个基类的默认构造函数都会被隐式调用，如果指定了非默认构造函数，必须再调用任何成员变量之前调用基类构造函数。
- 如果把成员变量声明为引用或const，那么就必须通过初始化列表来初始化它

## 内存优化

- 根据类型聚集成员变量
- 除非比较，不要添加虚方法
- 使用大小明确的类型，比如int32_t，int64_t

## 除非需要，勿用内联

- 暴露实现细节

- 再客户应用程序中嵌入代码

  api头文件的内联代码会直接编译进客户端应用，这意味着只要发布对内联代码的修改，客户端就必须重新编译其代码

- 代码膨胀

- 调试复杂化

> 避免再公有头文件中使用内联代码，除非证明代码会导致性能问题，并确认内联可以解决改问题。
>
> boost头文件通常约定使用detail子命名空间（比如boost::tuples::detail）包含所有私有代码。这是从公有头文件中进一步分离私有代码的良好编程风格

## 性能分析

### 典型的分析工具

- intel VTune：它包含二进制测量特性，基于时间和事件的采样，计数监控以及其他各种工具
- gprof：是gnu的分析器，它使用二进制测量工具记录调用的次数和每一个函数花费的时间，它集成再gnu C++编译器中，可以使用-pg命令行选项激活。运行待测量的二进制文件时，当前目录下会生成一份数据文件，可以用gprof文件对齐分析。（mac os x下使用satrun应用程序）
- OProfile：这时linux下的一款开源性能工具。
- AMD CodeAnalyst：来自amd的免费分析器，适配windows和linux。基于OProfile
- Open SpeedShop：这是一款linux上的开源性能测量工具。基于sgi的irix speedshop。支持并发和多线程程序，
- sysprof：linux开源性能分析器。
- CodeProphet Profile：免费的工具使用二进制测量机制
- callgrind：他是Linux和mac 上valgrind的一部分。独立的KCachegrind工具可以用于可视化分析数据，可选的缓存模拟器可用于分析内存访问行为。

### 基于内存的分析

- ibm rational purify：商业的内存调试器，检测C++内存访问错误
- valgrind：这个工具已有若干前端GUI程序（比如vakkyrie，alleyoop）可用于浏览器输出文件
- Parasoft Insure++：商业的内存调试器
- Coverity：静态分析工具，它能够检测源码而不必实际运行程序，他将所有潜在的编码错误记录到数据库中，并提供web界面，用来查看静态分析结果。

### 多线程分析

- Intel Thread Checker：window和Linux下的商业线程分析工具，用于发现逻辑线程错误，比如死锁，
- Intel Parallel Studio：用来检查线程和内存错误的检查其工具，以及针对并行程序的性能分析工具
- intel thread profile：
- Helgrind和drd：valgrind测试框架下的模块，检测Pthread应用程序的同步错误。

# 版本控制

## 版本号

### 版本号的意义

- 主版本号：版本号的第一位，主版本号的修改表明api进行了重大修改
- 次版本号：版本号的第二位，通常再主版本发布后设置为0，每当添加较小的特性或修正重大错误时这个数会增加，次版本号通常不应该涉及任何补钱荣的api修改。用户能够升级到新的次版本，而不必对自己的软件做任何的改动。
- 补丁版本号（可选的）：第三个整数。每当发布对中欧广大错误或安全问题的修复补丁后这个数会增加，补丁版本号暗示现有的api接口没有修改，也就是只有api的行为有所改变。
- 通常可以再版本号后添加一个符号来表明软件开发过程中的相关阶段，例如；1.0.0a是指alpha发布，1.0.0b是指beta发布，而1.0.0rc是指候选发布版。

> 在苦命中包含api的主版本号时良好的编程实践，尤其时在做了一些不向后兼容的修改时，例如libFoo.so、libFoo2.so、libFoo3.so

### 提供api的版本信息

通用的做法：

```C++
// version.h
#define API_MAJOR 1
#define API_MINOR 2
#define API_PATCH 0

class Version
{
    public:
    	static int GetMajor();
    	static int GetMinor();
    	static int GetPatch();
    	static std::string GetVersion();
    	// 允许用户执行版本对比，比如检查正在编译的api版本号是否大于某个版本
    	static bool IsAtLeast(int major, int minor, int patch);
   		// 指示某个特性是否存在
    	static bool HasFeature(const std::string& name);
}
```

## 软件分支策略

### 分支策略

- 每个项目都需要一条主干，项目源码的持久存储库

- 每次版本发布，可由主感代码派生出分支

- 如果需要为一个版本发布紧急补丁，可以为特定的“热修复补丁”（hotfix）创建新分支

  ![](%E5%A4%A7%E8%A7%84%E6%A8%A1C++%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1.assets/%E5%88%86%E6%94%AF%E7%AD%96%E7%95%A5.PNG)

  > 只在必要时再分支，尽量延迟创建分支的时机，尽量使用分支代码路线而非冻结代码路线，尽早且频繁的合并分支

### api和并行分支

- 制定开发分支的目标
- 经常合并到主干中。
- 审查过程

## 兼容性级别

### 向后兼容性

是指一个api不需要用户做出任何改变就能完全取代上一版本的api，那么它就是向后兼容的。

向后兼容性包括：

- 功能兼容性
- 源代码兼容性
- 二进制兼容性

数据导向的兼容性包括：

- 客户、服务器端兼容性
- 文件格式的兼容性
- 通信协议的兼容性
- 数据库模式的兼容性

> 向后兼容性意味着使用第N版本的api的客户代码能够不加修饰的升级到第N+1版本。

### 功能兼容性

> 功能兼容性意味着第N+1版本的api的行为和第N版本一致。

### 源代码兼容性

> 源代码兼容性意味着用户使用第N版本的api编写的代码可以使用第N+1版本进行编译，而不用修改源代码

### 二进制兼容性

> 二进制兼容性意味着使用第N版本api编写的应用程序可以仅通过替换或重新连接api的新动态连接库，就可以升级到第N+1版本。

二进制不兼容的api修改

- 移除类，方法或函数
- 增加，移除类中的成员变量，或者重新排序成员变量
- 增加或移除一个类的基类
- 修改稿任何成员变量的类型
- 以任何方式修改已有方法的签名
- 增减，移除模板参数，或者重新排序模板参数
- 把非内联方法改为内联方法
- 把非虚方法改成虚方法，反之亦然
- 改变虚方法的顺序
- 给没有虚方法的类增加虚方法
- 增加新的虚方法（对于有些编译器，如果只是在已有的虚函数的后面添加，则可以兼容）
- 覆盖已有的虚方法（这在某些情况下时可行的，但最哈哦避免这样做）

二进制兼容的修改：

- 增加新的类，非虚方法，或函数
- 给类增加新的静态变量
- 移除私有静态变量（前提时它们从来没有在内联方法中引用）
- 移除非虚私有方法（前提时它们从来没有在内联方法中调用）
- 修改内联方法的实现（要使用新的实现就必须重新编译）
- 把内联方法修改为非内联（如果实现也被修改，则必须重新编译）
- 修改方法的默认参数（要使用新的默认参数，则必须重新编译）
- 给类增加或移除友元声明
- 给类增加新的枚举
- 给已存在的枚举增加新的枚举量
- 使用位域中未声明的余留位

实现二进制兼容性的进阶技巧：

- 不要给已有的方法增加参数，可以定义改方法新的承载版本，着确保原有符号继续存在，同时也提供新的调用约定，在cpp文件中，老的方法实现可以直接调用新的重载方法
- pimpl模式可以用来帮助保持接口的二进制兼容性，因为实现细节再cpp文件中
- 采用纯c风格的api可以更容易的获得二进制兼容性，c不提供诸如继承，可选参数，重载，异常，模板等特性，为了利用c和C++的优势，可以选择使用面向对象的C++风格开发api，然后用纯C风格封装C++ api
- 如果确实需要做二进制不兼容的修改，那么可以考虑为新的换个不同的名字，这样就不会破坏已有的应用程序。libz库采用这种方式，zlib.dll、zlib1.dll，其中1代表api的主版本号

### 向前兼容性

向前兼容意味着用户可以降级到之前的发布版本，代码无需修改，仍然能够正常工作。

向前兼容的方法：

- 如果你知道将来会给方法添加一个参数，那么可以使用前面第一个例子给出的技巧，也就是说，甚至可以再功能实现之前就添加参数，然后将参数标注为未使用
- 如果预计将来会改用一种不同的内置类型，那么可以使用不透明的指针或typedef，二不要直接使用内置类型，如果，未float类型创建别名Real的typedef，这样就可以再api的未来版本中把typedef改为double，而不会告知api变化。
- 数据驱动风格本来就是向前兼容的，仅接收arglist可变容器的方法再运行时本来就允许传入任何实参的集合，因为这种实现可以添加新的命名实参，而不必修改函数签名

> 向前兼容意味者使用第N版本的api客户代码可以不加修改的降级到n-1版本

## 怎样维护向后兼容性

### 添加功能

> 再api初始化版本发布后，不要为抽象基类添加新的纯虚函数

### 修改功能

- 再新同名函数的后面添加"Ex"后缀
- 新函数引入另外一个名字。

### 弃用功能

- 在文档中进行标注，同时说明可以取代它的新功能
- 使函数使用时产生警告信息，大多数编译器提供将类，方法或变量标记为“已弃用”方法，只要带上该标签，就会输出编译时警告

```C++
// deprecated.h

#ifdef __GNUC__
	#define DEPRECATED __attribute__((deprecated))
#elif defined(__MSC_VER)
	#define DEPRECATED __declspec(deprecated)
#else
	#define DEPRECATED
	#pragma message("DEPRECATED is not defined for this compiler")
#endif

// MyClass.h
class MyClass
{
public:
	DEPRECATED std::string GetName();
	int GetAge();
};
```

除了提供编译时警告，还可以编写在运行时给出弃用警告的代码，这样就可以在警告信息中提供更多的信息，比如说明可以替代方式，例如，可以声明下面的函数，把它作为每一个需要弃用函数的第一条语句；

```c++
void Deprecated(const std::string oldFun, const std::string newFun="");
...
std::string MyClass::GetName()
{
	Deprecated("MyClass::GetName", "MyClass::GetFullName");
	...
}
Deprecated的实现可以维护一个std::set，其中包含所有已经输出过警告的函数名，它支持在第一次调用的时候才输出警告，Noel Llopis在它的Game Gem中描述了类似的技巧，只不过它的解决方案还记录了不重复的调用点数量，并在程序执行结束时把警告批量输出到独立的报告文件中。
```

## api审查

### api审查的目的

- 维护向后兼容性
- 维护设计一致性
- 对修改加以控制
- 支持未来改进
- 重新审视解决方案

### api预发布审查

审查会议的参与者

- 产品拥有者：是指对产品计划总体负责并代表客户提出需求的人。
- 技术领导者：审查会提出诸如为什么添加特定的修改，修改是否以最佳方式实现之类的问题
- 文档领导者：api不仅仅时代码，它也包括文档。

api审查过程中应该关注交付的接口，而不是代码的细节，可以使用工具报告当前api和上一版本之间的区别，比如api Diff（apidiff.com）不过已经弃用了

对于每一处的修改，审查委员会都应该询问的问题：

- 破坏了向后兼容性码？
- 是否破坏了二进制兼容性？（如果需要确保二进制兼容性）
- 这项修改的文档齐全码？
- 这项修改可以用更不易过时的方法实现码？
- 这项修改对性能有负面影响码？
- 这项修改破坏了架构模型码？
- 这项修改遵循api编码规范码？
- 这项修改会在代码中引入循环依赖码？
- api修改是否应该包含升级脚本，以帮助客户更新代码和数据文件？
- 对修改后的代码有没有现存的自动化测试，已验证功能兼容性有没受到影响
- 修改需要自动化测试码？是否已经编写
- 这项修改时我们想发布给客户的码
- 用于演示新api的样例代码存在码？

### api预提交审查

api预提交审查会议是最后一道防线，以确保非预期的修改不会发布给用户。

变更请求的流程：

- 描述变量内容及其必要性
- 分析对api所有客户的影响
- 给出api新版本的迁移指南
- 更新向后兼容性测试用例

这随后架构委员会将进行审查，它们可以批准或拒绝变更请求，并给出做出决定的基本理由，一旦批准，开发者就可以提交对代码，文档以及测试的更新了。

# 文档

## 编写文档的理由

### 定义行为

api是一种功能规范，它应该定义怎样使用接口，以及接口的行为是怎样的，仅仅查看头文件，就知道参数的数目，类型以及返回值的类型，但是它没有说明该方法的行为。

### 为接口契约编写文档

主要原理包括：

- 前置条件：在调用函数之前，客户负责保证满足函数所需的前置条件，如果前置条件没有得到满足，函数就不能正常执行
- 后置条件：函数保证在工作完成后满足特定的条件，如果后置条件没有满足，那么函数就没有正确完成工作/
- 类的不定式：类的每个实例必须满足的约束条件，它定义了那些根据类的设计，在执行时必须保持为真的状态。

例如：平方根函数的前置条件时输入数字必须为整数或零。后置条件时函数结果的平方应该等于输入的数字（允许适当的误差）

```c++
/// 
/// \brief 计算浮点数的平方值
/// \pre value >= 0
/// \post fabs((result * result) - value ) < 0.001
///
double SquareRoot(double value);
```

> 契约编程意味者为函数的前置条件，后置条件，以及类的不变式编写文档

### 告知行为的改变

```C++
/// 返回层次结构中的子节点列表
///
/// \return 以nuLl结尾的子节点列表
/// 如果不存在子节点，则返回null
///
const Node* GetChildren()const;
```

根据文档说明，如果层次结构中没有子节点则返回Null指针，这种行为就要求客户检查返回值。

### 文档涉及的内容

一个特别贴切的例子时每n秒调用一次客户代码的计时器类，你可能在文档中说明时间间隔的单位是秒，但还应该说明以下客户关心问题。

- 时间是指真实世界的时间（钟表时间），还是处理时间？
- 计时器的准确性如何？
- api的其他操作会影响到计时器的准确性码？会阻塞计时器码？
- 计时器会随着时间的推移发生偏移码？它总是相对于起始时间触发码？

定义这些额外的特性有助于用户确定改类是否适用于它们的任务，例如，对于只需近似每秒执行一些琐碎工作的空闲任务，用户并不关心是在1.0秒还是1.1秒后唤醒，然而在同样的条件下，对于一个模拟时钟，如果每次调用时都走值，那么它很快就会显式错误的时间

在创作类和函数的文档时，应该考虑以下问题：

- 类是对什么东西的抽象？
- 有效的输入是什么？例如，可以传入null指针码？
- 有效的返回类型是什么？例如，什么时候返回真或假
- 需要检查哪些错误条件？例如，是否检查文件存在与否
- 是否具有前置条件，后置条件和副作用？
- 是否具有未定义的行为？比如，sqrt(-1,0)?
- 是否抛出任何异常
- 是线程安全的码？
- 各个参数的单位是什么？
- 空间复杂度，时间复杂度如何？例如，O(log n)，还是O(n~2)？
- 内存所有权模型是什么？例如，是调用者负责删除所有返回对象？
- 虚方法是否调用类中的其他方法？也就是说，当客户在派生类中覆盖方法时，应该调用哪些方法？
- 有没有相关函数需要交叉引用？
- 某特性时在api的哪个版本中添加的？
- 某方法是否已被弃用，如果是，替代方式是什么？
- 某特性是否存在已知的编程错误？
- 是否希望分享未来的改进计划？
- 能否提供任何示例代码？
- 文档是否带来了额外的价值或见解？

> 文档的品质包括：
>
> - 完整
> - 一致
> - 易于访问
> - 没有重复
>
> 为api的每个公有元素编写文档

## 文档的类型

### 自动生成的api文档

> 使用自动生成文档的工具，从头文件注释中提取api文档

很多工具可以根据C++源码的注释创建api文档，它们通常生成不同格式的输出，比如html,pdf

- AutoDuck
- CcDoc
- CppDoc
- Doc-O-Matic
- Doc++
- Ooxygen
- GenHelp
- HeaderDoc
- Help Genarator
- KDOC
- ROBODoc
- TwinText

### 概述文档

除了自动生成的api文档外，还应该人工编写提供有关api更高层次信息的文档，这通常包括api能够做什么，用户为什么应该关注它，这类概述性文档涵盖：

- api高层次的概念视图：api解决什么问题？他是如何工作的？如果可能，使用图表效果会很好
- 关键概念，特性和术语
- 使用api的系统需求
- 如何下载，安装和配置软件
- 如何提供反馈信息，报告错误
- 对api声明周期各个阶段的阐述，例如预发布，维护，稳定性和弃用

### 示例和教程

包括的内容：

- 简短的示例；提供简短的代码片段，以便展示api的关键功能，这些代码通常不能通过编译，它们省略了所有相关样本代码，只关注api调用方法
- 可运行的演示；他是一个完整的，现实世界的例子
- 教程和演练；教程展示了解决问题的步骤，而不是仅给出最终结果，
- 用户贡献；用户可能会提供一些很好的示例，应该鼓励，将其添加到演示代码集合中，这些代码可以放置在专门的contirb目录下，表示你不对它们提供支持/
- 常见问题（FAQ）；让用户快速而容易获知api是否满足其需求

### 发布说明

首次发布以后，买俄格版本都应该包含发布说明，他告诉用户自上次发布以来，有哪些改动，发布说明通常是一份间接的文档，主要包括：

- 发布概述，包括对新特性以及改版本关注点的描述，例如，只修复了一些错误
- 指向改发布版本位置的连接
- 指出相比上次发布版本有何源代码或二进制不兼容之处
- 改发布版修复的错误列表
- 弃用或移除的特性列表
- 针对api中所有修改的迁移提示，比如怎样是哟个发布版本中提供的升级脚本
- 所有已知问题，包括在改版本中引入的问题，以及之前版本遗留的问题
- 针对已知问题的解决方法提示
- 有关用户如何发送反馈和错误报告的信息

### 授权信息

授权分类

| 授权协议名          | 描述                                                         |
| ------------------- | ------------------------------------------------------------ |
| 无授权信息          | 用户无权合法使用api，除非向你请求授权                        |
| GNU GPL             | 意味着任何衍生作品也必须是GPL授权分发的，因此开源的GPL库不能用于专有产品 |
| GNU LGPL            | 允许把开源的api以二进制的形式连接到专有代码，衍生作品可以在，某些特定条件下分发，比如提供修改或未修改的LPGL库源码，以及其他约束 |
| BSD                 | 连接了BSD授权的专有代码可以自由分发                          |
| MIT/X11             | 可以自由分发                                                 |
| Mozilla公共授权协议 | 允许使用开源库构建专有软件，任何修改过的代码必须以MPL授权重新分发 |
| apache授权          | 允许分发基于apache授权代码的专有软件                         |

## 文档可用性

涵盖的内容：

- 索引页
- 一致的视图和体验
- 代码示例
- 图表
- 搜索
- 面包屑导航
- 术语解释

## 使用Doxygen

支持c、C++、oc、java、python、C#、php

doxygen是开源的，包括windows，mac，linux

### 配置文件

基于键值对格式的ascii文本唔见，可以通过-g命令行参数运行Doxygen生成默认配置文件，通常配置的条目如下：

```c
PROJECT_NAME=<NAME OF YOUR PROJECT>
FULL_PATH_NAMES=NO
TAB_SIZE=4
FILE_PATTERNS=*.h *.hpp *.dox
RECURSIVE=YES
HTML_OUTPUT=apidocs
GENERATE_LATEX=NO
```

完成这些初始化配置后，就可以在源码目录下运行Doxygen了，Doxygen会在哪里创建apidocs目录

### 注释风格和命令

注释风格如下：

```c++
/**
 * ...文本...
 */
 
 ///
 ///...文本...
 ///
 
 等，///风格比较好用
```

常用的命令：

- \file [文件名]
- \class <类名>[<头文件>] [<头文件>]
- \brief <简要说明>
- \author <作者列表>
- \data <日期描述>
- \param <参数名> <描述>
- \param[in] <输入参数名> <描述>
- \param[out] <输出参数名> <描述>
- \param[in,out] <输入/输出参数名> <描述>
- \return <返回结果描述>
- \code <代码块> \endcode
- \verbatim <字面文本块> \endverbatim
- \exception <异常对象> <描述>
- \deprecated <解释及替代品>
- \attention <需要注意的消息>
- \warning <警告消息>
- \since <新实体加入后的日期或api版本号>
- \version <版本字符串>
- \bug <缺陷描述>
- \see <对其他方法或类的交叉引用>

除了这些命令，Doxygen还支持多种格式化命令，用来改变下一个单词的风格，包括\b（粗体）、\c（打印体）、\e（斜体）。还可以使用\n强制换行，使用\\\\输入反斜杠字符，使用\@输入@

### api注释

还支持\mainpage注释未整个api制定概述文档，这些描述会生成在文档的首页，通常把这些注释保存在单独的文件中，比如overview.dox（需要更新doxygen配置文件中的FILE_PATTERNS字段，使之包含*.dox）

如果概述文件中的文本很长，可以使用\section、\subsection命令引入小节，甚至可以为api的特定部分创建包含更详细描述的独立页面，这可以通过\page命令完成。

同时，可以为文件处理，容器，日志，版本，等类及其所属文件分别创建分组，可以通过\defgroup声明分组。然后使用\ingroup将任意制定元素加入分组

下面的注释综合了这些特性，为一个api提供了概述文档，它分为3个小节，并且交叉引用了两个其他页面以提供更详细的描述，页面包含了一个连接，可以查看所有被标记为特定分组的api元素

```c++
///
/// \mainpage API Documention
/// 
/// \section sec_Contents Contents
/// 
/// \li \ref sec_Overview
/// \li \ref sec_Detail
/// \li \ref sec_SeeAlso
///
/// \section sec_Overview Overview
///
/// 这里是概述文本
/// 
/// \section sec_Detail Detaild Description
///
/// 这里是更详细的描述
///
/// \section sec_SeeAlso See Also
///
/// \li \ref page_Logging
/// \li \ref page_Versioning
///
///
/// \page page_Logging The Logging System
///
/// 日志功能描述
/// 
/// \link group_Loggine View All Logging Classes \endlink
///
///
/// \page page_Versioning API Versionning
///
/// API版本描述
///
/// \link group_Versioning View All Versionning Classes \endlink
///

/// \defgroup group_Logging Diagnostic logging features
// Sed \ref page_Logging for a detaled description.

/// \defgroup group_Versioning Versionning System
/// Sedd \ref page_Versioning for a detaled description.

```

### 文件注释

可以在每个头文件的顶部放置一些注释，作为整个模块的文档。示例：

```c++
///  
/// \file <文件名>
///
/// \brief <简要描述>
///
/// \author <作者姓名列表>
/// \date <日期描述>
/// \since <添加本模块时的api版本>
///
/// <模块描述>
///
/// <授权和版本信息>
///

```

如果希望改文件巴汗已定义的分组功能，那么可以在注释中再添加\ingroup命令

### 类注释

头文件中的每个类也可以有注释，描述类的整体目标。示例如下，如果类属于已定义的分组，可以包含\ingroup命令；如若类已废弃，可以用\deprecated命令。如果提供一些示例代码，可以使用\code...\endcode命令

```c++
/// 
/// \clss <类名> [头文件] [头文件名]
///
/// \brief <简要说明>
///
/// <详细说明>
///
/// \author <作者、姓名列表>
/// \date <日期描述>
/// \since <添加本类时的api版本>
/// 
```

### 方法注释

```
/// 
/// \brief <简要说明>
///
/// <详细说明>
///
/// \param[in] <输入参数名> <描述>
/// \param[out] <输出参数名> <描述>
/// \return <返回值描述>
/// \since <添加本方法时的api版本>
/// \see <参考(see also )方法列表>
/// \note <关于本方法的可选说明>
///
```

如果类中有多个方法属于一个或多个逻辑分组，那么可以告知Doxygen，使之把相关的方法归入一个具名的小节。这样就可以更加合理的组织类成员，例如：

```C++
class Test
{
public:
	/// \name <组1名称>
	//@{
	void Method1InGroup1();
	void Method12InGroup1();
	//@}
	
	/// \name <组2名称>
	//@{
	void Method1InGroup2();
	void Method12InGroup2();
	//@}
	
};
```

### 枚举类型

```C++
/// 
/// \brief <简要描述>
/// 
/// <详细秒时>
///
enum MyEnum{
	ENUM_1, /// <枚举值1的描述>
	ENUM_2, /// <枚举值2的描述>
	ENUM_3, /// <枚举值3的描述>
}
```

### 带有文档的示例头文件

```c++
/// -*- tab-width: 4; c-basic-offset: 4; indent-tabs-mode: t -*-
///
/// \file    version.h
///
/// \brief   Access the API's version information.
///
/// \author  Martin Reddy
/// \date    2010-07-07
/// \since   1.0
/// \ingroup group_Versioning
///
/// Copyright (c) 2010, Martin Reddy. All rights reserved.
///

#ifndef VERSION_H
#define VERSION_H

#include <string>

///
/// \class Version version.h API/version.h
///
/// \brief Access the version information for the API
///
/// For example, you can get the current version number as
/// a string using \c GetVersion, or you can get the separate
/// major, minor, and patch integer values by calling
/// \c GetMajor, \c GetMinor, or \c GetPatch, respectively.
///
/// This class also provides some basic version comparison
/// functionality and lets you determine if certain named
/// features are present in your current build.
///
/// \author Martin Reddy
/// \date   2010-07-07
/// \since 1.0
///
class Version
{
public:
	/// \name Version Numbers
	//@{
	///
	/// \brief Return the API major version number.
	/// \return The major version number as an integer.
	/// \since 1.0
	///
	static int GetMajor();

	///
	/// \brief Return the API minor version number.
	/// \return The minor version number as an integer.
	/// \since 1.0
	///
	static int GetMinor();

	///
	/// \brief Return the API patch version number.
	/// \return The patch version number as an integer.
	/// \since 1.0
	///
	static int GetPatch();

	///
	/// \brief Return the API full version number.
	/// \return The version string, e.g., "1.0.1".
	/// \since 1.0
	///
	static std::string GetVersion();
	//@}

	/// \name Version Number Math
	//@{
	///
	/// \brief Compare the current version number against a specific
	///        version.
	///
	/// This method let's you check to see if the current version
	/// is greater than or equal to the specified version. This may
	/// be useful to perform operations that require a minimum
	/// version number.
	///
	/// \param[in] major The major version number to compare against
	/// \param[in] minor The minor version number to compare against
	/// \param[in] patch The patch version number to compare against
	/// \return Returns true if specified version >= current version
	/// \since 1.0
	///
	static bool IsAtLeast(int major, int minor, int patch);
	//@}

	/// \name Feature Tags
	//@{
	///
	/// \brief Test whether a feature is implemented by this API.
	///
	/// New features that change the implementation of API methods
	/// are specified as a "feature tag". This method lets you 
	/// query the API to find out if a given feature is available.
	///
	/// \param[in] name The feature tag name, e.g., "LOCKING"
	/// \return Returns true if the named feature is available.
	/// \since 1.0
	///
	static bool HasFeature(const std::string &name);
	//@}
};

#endif

```

# 测试

## 编写测试的理由

- 增加信心
- 确保向后兼容性
- 节约成本
- 编写用例
- 合规保证

## api测试的类型

- 白盒测试：代码级别的
- 黑盒测试：基于产品说明进行的
- 灰盒测试：前两者的组合
- 系统测试：再完整的集成系统上进行的测试，假定测试对象为用户运行的真实的应用

常用的非功能性测试：

- 性能测试：验证api的功能满足最低运行速度或最小内存使用的要求
- 负载测试：给系统增加需求或压力，并测试系统处理这些负载的能力，通常指同时又很多并发用户，或者每秒执行很多api请求的测试。有时也称为压力测试
- 可扩展性测试：确保系统能处理潘达的复杂生产数据的输入
- 浸泡测试：尝试长期持续运行软件，以满足客户对软件健壮性的需求（比如没有内存泄漏，计数器溢出，或计数器相关的错误）
- 安全行测试：比如保密性，身份认证，授权，完整性和敏感信息的可获取行
- 并发测试：验证代码的多线程行为，确保它能够正确执行而不死锁

> api测试应该组合使用单元测试和集成测试，也可以适当运用非功能性技术测试，比如性能测试，并发测试和安全性测试

### 单元测试

> 单元测试时一种百盒测试技术，用于独立验证函数和类的行为

如果测试的方法或对象依赖系统的其他资源，比如磁盘，数据库中的记录或远程服务器上的软件，则引发了对单元测试的不同两种观点：

- 测试固件设置：再每个单元运行测试前，初始化一个一致的环境或测试固件
- 桩/模拟对象：创建桩对象或模拟对象代表单元之外的依赖性，将待测试的代码同系统其他部分隔离开。例如：如果需要和数据库通信，那么可以创建数据库桩对象来接收单元生成的查询子集，然后由桩对象再响应中返回封装的数据，而不是真正的与数据库进行连接。因此这时一个完全独立的测试，不受数据库问题，网络，文件系统权限的影响

### 集成测试

> 集成测试一种黑盒技术，用于验证几个组件的交互过程，它们时站在客户的角度编写的。

## 编写良好的测试

### 良好测试的特征

- 快速；测试套件应该运行得非常快，以便能够迅速获得测试失败的反馈

- 稳定；测试应该时可重复的，独立的以及一致的。每次运行特定版本的测试，应该得到相同的结果。

- 可移植性；如果api再多个平台实现，那么测试应该也能再所有这些平台工作。一个常见的差异时浮点数的比较，舍入的误差，架构差异和编译器差异会导致数学运行再不同平台产生略微不同的结果。

  > 浮点数比较应该允许微小的偏差，而非精度的比较。偏差应该基于涉及数据的量级和所使用的浮点类型的精度而定。例如，单精度浮点数只有6-7位小数的精度。因此在比较的数字诸如1.234567时，偏差为0.000001时合适的，但是比较的数字诸如123456.7时，偏差为0.1更合适。

- 高编码标准；测试代码应该遵循和api其他部分相同的编码标准。
- 错误可重现；如果测试失败，应该能很容易重现错误

### 测试对象

测试api关键的技术

- 条件测试；确保代码中的所有可能路径都被测试过
- 等价类；时一组具有相同预期行为的测试输入。
- 边界测试；参数测试
- 返回值断言
- getter和setter对
- 操作顺序；由助于发现api调用是否包含没有写在文档中的副作用，而这些api依赖某些副作用完成特定的工作流程
- 回归测试；尽量与api的早期版本保持向后兼容。应该保有实时数据文件和遗留数据文件
- 负面测试；构造错误条件，查看代码如何应对非预期情况
- 缓冲区溢出；
- 内存所有权；任何返回动态分配内存的api调用都应该再文档中写明api是否拥有内存，或客户端是否要负责释放内存
- 空输入；比如空指针

## 编写可测试的代码

### 测试驱动开发

> 测试驱动开发指首先编写单元测试，然后编写代码使得测试通过。

### 桩对象和模拟对象

- 伪对象；对象具有所需的功能行为，但是使用简化的实现辅助测试，例如，模拟与本地磁盘交互的内存文件系统
- 桩对象；指返回准备号的对象或封装号响应的对象。例如，readFileAsString()桩对象返回硬编码字符串作为文件内容，而非读取磁盘上的指定文件的内容。
- 模拟对象：这时一种可测试的对象。具有预先编排好的行为，可以验证方法的调用顺序，例如，模拟对象（mock）可以指定GetValue函数的前两次返回10，之后的调用返回20，它也可以验证某个函数被调用的次数（比如正好3次或5次），或者以给定的顺序调用类中的函数

> 模拟对象和桩对象都返回封装好的响应，但是模拟对象还会验证调用行为。

### 测试私有代码

比如一个名为MyClass的类，它能够通过以下方式来实现覆盖所有私有方法；

- 成员函数；声明公有的MyClass::SelfTest()方法
- 友元方法；创建普通函数MyClassSelfTest()方法，并再MyClass中将其声明为友元函数。

> SelfTest()方法可以再单元测试中直接调用，用于执行不同私有方法的额外验证。尽管这种方法存在不良品质，但对测试而言，它很方便。
>
> 如果希望为C语言的API提供自测函数，可以再.c文件中定义外部连接SelfTest函数，即在window上调用_declspec(dllexport)修饰的非静态函数，但不在.h文件中提供函数原型。

### 使用断言

> 编译时断言（只存在于C++11）
>
> static_assert(sizeof(void*)) == 4， “this code only work on 32bit platforms”

### 契约编程

### 记录并重放功能

测试的功能之一时记录api调用顺序并按需要进行重放，记录和重放工具再应用程序和GUI测试中相当常见。

> 为api添加健壮的记录和重放功能的任务十分艰巨，但考虑到它有利于加速测试自动化，并使客户能轻松捕获并重现错误，给出缺陷报告，这分开销通常使值得的。

### 支持国际化

一些库提供了国际化和本地化的功能，你可以选用某个库向客户返回本地化字符串，并允许客户对api返回的字符串指定它们偏好的区域设置。例如GNU gettext库提供的gettext函数用于查询字符串的翻译结果，返回字符串再当前区域设置下的值（前提是已经提供了翻译）

## 自动化测试工具

### 自动化测试框架

- cppunit
- Boost Test
- google Test
- TUI，小型且可以移植的C++单元测试框架，因为它只包含头文件，所以不需要链接或部署库

### 代码覆盖率工具

- 函数覆盖
- 行覆盖
- 语句覆盖
- 基本快覆盖
- 判定覆盖条件覆盖

优秀的工具：

- Bullseye Coverage
- 支持多平台
- Rational PureCoverage
- Intel Code-Coverage Tool；该工具包在intel编译器中，并运行在由这些编译器生成的检测文件上。
- Gcov；开源的GNU GCC编译器集的一部分。它运行使用-fprofile-arcs和-ftest-coverage选项的g++生成的代码基础上。gcov支持函数覆盖，行覆盖，分支覆盖。它以文本格式输出报告，借助于lcov脚本，gcov能输出html格式的结果报告
- Vs的code coverage工具

> 可以设置代码覆盖率的目标，指定所有代码必须达到特定的阈值，例如75%、90%、100%。较为可信的代码覆盖率目标使100%的函数覆盖，90%的行覆盖或75%的条件覆盖。

### 缺陷跟踪系统



持续构建系统

