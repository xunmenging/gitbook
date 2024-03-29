# 网络编程

## TLS/SSL 协议背后的算法

TLS/SSL 协议包含以下一些关键步骤：

- 传输的数据必须具有机密性和完整性，一般采用对称加密算法和HMAC 算法，这两个算法需要一系列的密钥块C key_block ），比如对称加密算法的密钥、H MAC算法的密钥，如果是AES- 128 ” CBC-PKCS#7 加密标准，还需要初始化向量。

- 所有的加密块都由主密钥（ Master Secret ）生成，主密钥就是第l 章中讲解的会话密钥，使用密码衍生算法（本章后续会讲解－〉将主密钥转换为多个密码快。

- 主密钥来自预备主密钥（ Premaster Secret ），预备主密钥采用同样的密码衍生算法转换为主密钥，预备主密钥采用RSA 或者DH CEC DH ）算法协商而来。不管采用哪种密钥协商算法，服务器必须有一对密钥（可以是RSA 或者EC DSA 密钥〉，公钥发给客户端，私钥自己保留。不同的密钥协商算沽，服务器密钥对的作用也是不同的。

- 通过这些关键步骤，好像TLS/SS L 协议的任务已经结束，但这种方案会遇到中间人攻击，这是TLS / SSL 协议无法解决的问题，必须结合PKI 的技术进行解决，PKI 的核心是证书，证书背后的密码学算法是数字签名技术。对于客户端来说，需要校验证书，确保接收到的服务器公钥是经过认证的，不存在伪造，也就是客户端需要对服务器的身份进行验证。

TLS / SSI 协议核心就三大步骤： 认证、密钥协商、数据加密

### 密钥协商算法

不管采用哪种密钥协商算法，客户端和服务器端最终会协商出预备主密钥（ PremasterSec ret ），预备主密钥转换为主密钥，主密钥最终再转换为密钥块。
预备主密钥有几个特点：

- 每个客户端和服务器端初始化连接的时候生成预备主密钥，每次的值都是不一样的。
- 预备主密钥在会话结束后（连接关闭后），会自动释放， 这是很关键的特性，预备主密钥不会持久保存。
- 预备主密钥必须保证是机密的，确保攻击者无法解密出预备主密钥，也无法猜测出预备主密钥。

### 中间人攻击

所谓中间人攻击就是服务器传递给客户端的公钥可能被攻击者替换，这样安全性就荡然无存了。

客户端向服务器端发起连接请求，期望获取服务器的RSA 公钥，攻击者劫持了这个请求。

- 攻击者自己生成一对RSA 密钥对，然后将攻击者的RSA 公钥发送给客户端。
- 攻击者然后再向服务器端发送请求，服务器生成RSA 密钥对，将RSA 公钥发送给客户端，实际上是发送给攻击者。
- 客户端通过攻击者的公钥加密密钥块并发送给服务器，实际上是发送给攻击者。
- 攻击者用自己的RSA 私钥解密了密钥块A，然后自己生成一个密钥块B ，用服务器的RSA 公钥加密后发送给服务器端。
- 服务器端接收到请求后，用自己的RSA 私钥解密出攻击者的密钥块B 。
- 客户端使用攻击者的密钥块A，采用AES 算法加密数据并发送给服务器端，实际上是发送给攻击者。
- 攻击者使用自己的密钥块A、采用AES 算法解密出明文，客户端相当于泄露了隐私，攻击者使用密钥块B ，采用AES 算法加密明文后发送给服务器。
- 服务器使用密钥块B ，采用AES 算法加密数据并发送给攻击者。
- 攻击者使用密钥块B ，采用AES 算法解密出明文数据，此时客户端和服务器端的加密数据被成功破解。

这就是中间人攻击者，在TLS/SSL 协议中，客户端无法确认服务器端的真实身份，客户端访问https: //www.example.com ，接收到一个服务器公钥，但是无法确认公钥是不是真正属于www.example.como 。

公钥只是一串数字，需要有一种手段去认证公钥的真正主人，解决方案就是PKI 。公开密钥算法中，所有的网络通信都会存在中间人攻击，这是务必要记住的一点，在HTTPS 协议中必须引入PKI 技术解决身份验证的问题， PKI 技术的核心就是证书。

### PKI

首先明确一点， PKI 技术不是TLS / SSL 协议的一部分，但是在HTTPS 中，必须引入PKI 技术才能保证安全。简单地说， PKI 技术能够确保客户端接收到的服务器公钥（比如www.examp l e.com 网站的公钥〉确实是www.example.com 网站的公钥。

比如SSH 协议，它也可以引入TLS/SSL 协议，从而保护数据传输安全，但SSH 协议没有HTTPS 中的身份验证机制，使用者使用SSH 客户端连接到SSH 服务器端， SSH 服务器端向SSH 客户端发送服务器公钥， SSH 客户端是无法自动确认服务器的真实身份的，只能由操作者自行判断该公钥是不是属于该服务器，如果操作者疏忽，信任了攻击者发送的公钥，那么SSH 客户端后续其实是和中间人在通信。

回到PKI 技术上， PKI 是一个很宽泛的概念，为了保障双方安全的通信，必须依赖于PKI 技术。PKI 由多个不同的组织构成，组织必须基于一定的信任基础，主要由以下几部分组成。

#### pki的组成

- 服务器实体：公民相当于服务器实体，服务器实体就是HTTPS 网站的提供者。
- 客户端（浏览器） ： 银行相当于客户端（浏览器）。
- CA 机构：在HTTPS 中，国家相当于CA 机构， CA 机构会向服务器实体签发一张证书（身份证）。和身份证一样， CA 机构会签发一张证书（可以理解为就是一张身份证），证书中包含
  了一些关键信息，比如服务器的主机、服务器的公钥。

浏览器基于对CA 机构的信任，有方法校验服务器的身份，和身份证不一样的是，互联网上的证书就是普普通通的文件，客户端如何校验证书呢？如何确认用户的身份呢（银行校验身份证的技术）？解决方案就是数字签名技术。

CA 机构也拥有一个密钥对，比如RSA 密钥对（与服务器的RSA 密钥对没有任何关系），它用私钥对证书进行数字签名，将签名的证书发送给服务器。浏览器再连接服务器，服务器发送证书给浏览器，浏览器拥有CA 机构的公钥（内嵌在浏览器中〉， 然后校验证书的签名， 一旦校验成功，就代表这个证书是可信的CA 机构签发的。

成功验证签名只能表示该证书是CA 机构签发的，并不代表确认了身份，浏览器会继续校验， 比如用户访问的网址是https: //www.example.com ，浏览器接收到服务器发送过来的证书，验证签名后，发现证书包含的域名也是www.example.com ，代表校验身份成功，最后浏览器从证书中获取服务器的公钥，用来进行密钥协商。

聪明的读者会想，浏览器为了校验签名， 需要CA 机构的公钥，这个公钥如何获取？会不会遇到中间人攻击， 其实浏览器集成了CA 机构的根证书，根证书包含了验证签名的公钥，如果CA 机构的根证书没有集成在浏览器中，那么浏览器就不会信任该证书，无法进行签名验证，这就是信任基础，浏览器会信任CA 机构（确切地说是信任CA 机构的公钥）。

PKI 技术的核心是证书，获取证书的过程很严谨， CA 机构务必严格校验服务器实体的身份。如果攻击者伪造了服务器实体（ 比如www.example.com ）的身份，以www.examp l e.com 的名义向CA 机构申请证书， 一旦CA 机构没有充分校验申请者的真实身份，给攻击者签发了www.examp l e.com 主机的证书，带来的危害是极大的，受害者不仅仅是服务器，也包括CA 机构本身， CA 机构的品牌就是浏览器对它的信任， 一旦失去信任基础，这个CA 机构也就失去了生存基础，浏览器就会取消该CA 机构的根证书。

#### 申请证书流程是非常复杂的，大体流程如下：

- 服务器实体希望发布一个HTTPS 网站（ https: //www. example.com ） 。

- 服务器实体生成公开密钥算法的一对密钥，比如一对RSA 密钥。

- 服务器实体生成一个CSR ( Cerificate Signing Request ）文件， CSR 是证书签名请求文件，其中包含的重要信息是网站的域名（ www.example.com ）、RSA 密钥对的公钥、营业执照，然后将CSR 文件发送给CA 机构申请证书。

- CA 机构收到CS R 文件后，核实申请者的身份，最简单的核实就是校验域名C www.examp l e.com ）的拥有者是不是证书申请者。

- 一旦审核成功， CA 机构用自己的密钥对（比如ECDSA 密钥对〉的私钥签名CSR文件的内容得到签名值，然后将签名值附在CSR 文件后面得到证书文件，证书文件中除了包含申请者的信息，还包括CA 机构的信息，比如包括CA 机构采用的签名算法（本例中就是ECDSA 签名算法）、CA 机构的名称。

- 最终CA 机构将证书文件发送给服务器实体。

#### 接下来看看客户端如何校验证书，大体流程如下：

- 浏览器向服务器端发送连接请求https :/ /www.examp le.com 。
- 服务器接收到请求后，将证书文件和RSA 密钥对的公钥发送给浏览器。
- 浏览器接收到证书文件，从中判断出是某CA 机构签发的证书，并且知道了证书签名算法是ECDSA 算法，由于浏览器内置了该CA 机构的根证书，根证书包含了CA 机构的ECDSA 公钥，用于验证签名。
- 浏览器一旦验证签名成功，代表该证书确实是合法CA 机构签发的。
- 浏览器接着校验证书申请者的身份，从证书中取出RSA 公钥（注意不是CA 机构的公钥〉和主机名，假设证书包含的主机也是www.examp le .com ，且连接阶段接收到的RSA 公钥等同于证书中包含的RSA 公钥，则表示浏览器成功校验了服务器的身份，连接的服务器确实是www.example . com 主机的拥有者。

## HTTPS 总结

握手层在加密层的上层，握手层提供加密层所需要的信息（密钥块），对于一个HTTPS 请求来说， HTTP 消息在没有完成握手之前，是不会传递给加密层的， 一旦握手层处理完毕， 最终应用层所有的HTTP 消息交由加密层进行加密。

### 握手层

客户端和服务器端交换一些信息， 比如协议版本号、随机数、密码套件（密码学算法组合）等，经过协商，服务器确定本次连接使用的密码套件，该密码套件必须双方都认可，客户端通过服务器发送的证书确认服务器身份后，双方开始密钥协商，最终双方协商出预备主密钥、主密钥、密钥块，有了密钥块，代表后续的应用层数据可以进行机密性和完整性保护了，接下来由加密层处理。

### 加密层

加密层有了握手层提供的密钥块，就可以进行机密性和完整性保护了，加密层相对来说逻辑简单明了，而握手层在完成握手之前客户端和服务器端需要经过多个来回才能握手完成，这也是TLS / SSL 协议缓慢的原因，增加了网络延迟。

### 握手

握手这个称呼很形象，客户端和服务器端互相传数据之前，需要互相协商，达成一致后才能进行数据的加密和完整性处理，那么握手包含哪些关键步骤和概念呢？

- 认证
  客户端在进行密钥交换之前，必须认证服务器的身份，否则就会存在中间人攻击，而服务器实体并不能自己证明自己，所以需要通过CA 机构来进行认证，认证的技术解决方案就是签名的数字证书。证书中会说明CA 机构采用的数字签名算法，客户端获取到证书后，会采用相应的签名算法进行验证， 一旦验证通过，则表示客户端成功认证了服务器端的身份。后续章节会重点介绍证书，在本章读者只要明白证书的作用，即为了避免中间人攻击，客户端需要对服务器发送的证书进行认证，最终从证书中获取服务器实体的公钥。

- 密码套件协商
  密码套件（ CipherSuite ）是TLS/SSL 协议中最重要的一个概念，理解了密码套件，就相当于理解了TLS /SSL 协议，客户端和服务器端需要协商出双方都认可的密码套件，密码套件决定了本次连接客户端和服务器端采用的加密算法、HMAC 算法、密钥协商算法等各类算法。

  密码套件协商过程有点类似于客户采购物品的过程，客户（客户端〉在向商家（服务器端）买东西之前需要告知商家自己的需求、预算，商家了解用户的需求后，根据用户的具体情况（比如客户愿意接受的价格，客户期望物品的使用年限）给用户推荐商品，只有双方都满意了，交易才能完成。对于TLS/SSL 协议来说，只有协商出密码套件，才能进行下一步的工作。

  HTTP 是没有握手过程的，完成一次HTTP 交互，客户端和服务器端只要一次请求／响应就能完成。而一次HTTPS 请求，客户端和服务器端需要进行多次交互才能完成，交互的过程就是协商，比如客户端告知服务器端其支持的密码套件，服务器端从中选择一个双方都支持的密码套件。

### 获取证书有三种途径：

- 向收费的CA 机构申请证书。

- 向免费的CA 机构申请证书，最著名的免费CA 机构就是Let ’s Encrypt ， 在第7章会重点讲解Let ’s Encrypt 。

- 生成自签名的证书，简单地说自签名证书就是服务器实体自己生成的证书， 浏览器不会信任自签名证书，

  - 自建证书是自己签发的（表示用户就是－ 个CA 机构），浏览器一般不会集成私有CA机构的根证书，从中也可以看出，即使是具备一定规模的CA 机构想将根证书集成到各个浏览器中也并不容易。
  - 由于浏览器没有集成自签名证书的根证书，当浏览器发现一张自签名证书，并不会立刻中断TLS/SSL 握手，会提示用户该证书可能是伪造的，存在中间人攻击可能性，用户可以选择信任该证书或者拒绝该证书， 一旦拒绝该证书， 则整个握手失败，如果用户信任该证书，贝lj 进行后续完整的TLS/SSL 握手，和正常的握手并无两样，也就是说用户一旦信任自签名证书，后续的数据通信也是处于加密保护的。
  - 自签名证书的用途还是很广泛的，对于一些企业内部系统，由于购买证书需要成本，可以生成自签名证书，企业内部系统的用户一般运行在同一个局域网下，由防火墙保护，风险相对可控，当浏览器提示用户自签名证书存在风险时，用户可以选择信任自签名证书，等同于访问了一个HTTPS 网站。

  讲解如何获取自签名证书，主要包含两步。

  - 生成私钥对和CSR
  - 生成自签名证书

### 部署和配置HTTPS 网站

现在主流的Web 服务器，比如Ng in x 和Apache 都支持HTTPS, Web 服务器都有很多指令配置HTTPS ， 主要包含两部分指令：

- 证书、密钥对配置指令，这是最重要的。
- 其他指令是为了更好地配置HTTPS 网站， 比如密码套件、TLS/SSL 协议版本的配置。

### 全站HTTPS 策略

全站HTTPS 实施策略主要是针对开发者来说的，对于一个网站来说， 部署HTTPS 网站并不代表绝对的安全， H TTP S 只是保证某个连接上请求数据的安全性，但Web 页面由很多元素构成， 主页面仅仅支持HTTPS 是不够的，所有引用的元素也必须支持HTTPS ， 否则就会引发We b 安全风险，接下来通过一个例子来描述非全站HTTPS 策略带来的风险。

比如网站www.ex a mpl e .com 提供了两个页面：

- https: //www . exa mple . com /i ndex.html ， 基础主页面，引用了一张图片http ://w w w.
  ex ample.com/ lo go .pn g o

- https: // www. 巳xa mple . com /a dm i n.php ，管理页面，只有登录用户才能访问该页面，
  网站使用Cooki e 技术认证用户登录权限。

接下来看看攻击者是如何攻击的：

- 攻击者不会直接攻击https :// www . example.com /index . html 和https ://www.e xampl e .
    com/admin.php ，因为数据都是被加密保护的。

- 攻击者发现ind ex .html 引入了一个非HTTPS 的图片，攻击者就拦截http: //www. ex ample.com 的请求。

- 恰好拦截的请求包含了Cooki e 验证信息，表示被拦截的用户具备登录权限， 可以进行很多管理操作。

- 由于Cookie 是明文的，攻击者将C ookie 内容保存到攻击者计算机的Cookie 文件中。然后攻击者直接在浏览器中访问https: //www. exa mpl e.co m/ admin.php ， 由于本地有对应的Cooki e 信息，请求会携带Cookie 进行传输。

- 服务器接收到请求后，由于该请求和正常请求并无不同之处，服务器认为会话用户具有管理权限， 此时攻击者可以以被攻击者用户的身份进行更多隐私管理操作，代表攻击成功。

总结，为保证Web 应用的绝对安全，应该全面实施全站HTT PS 策略， 主要包括：

- 网站涉及的域名必须都配置证书，并启用HTTPS o
- 网站引用的所有元素，必须支持HTTPS o
- 暴露在互联网上的HTTP URL 地址，比如来自搜索引擎的HTTP 请求，必须重定向到HTTPS 请求上。

## 从用户的角度看HTTPS

### 绿色小锁图标

从技术层面来说，小锁图标代表的含义很丰富：

- 该页面使用的是HTTP S 。
- 览器确认了服务器的合法身份。
- 该页面引用的所有元素也是安全的，都以HTTPS 的方式提供服务。

### TLS/SSL 握手失败

浏览器访问HTTPS 网站的时候，在握手阶段可能会存在错误，比如证书的有效期过期、证书是自签名证书、客户端和服务器端无法协商出一致的密码套件，遇到类似的情况，浏览器会出现一个错误页面，告知用户存在的问题。

## 测试HTTPS

### Curl 命令行

使用下列的命令测试某个网站是否支持HTTPS ， 一verbose 参数能够了解详细的信息，包括TLS / SSL 握手的详细信息：

```shell
$ curl ” https : //www.example . com”--verbose
```

### C h rome 开发者工具

对于开发者来说，另外一种测试HTTPS 网站的工具就是Chrome 开发者工具，该工具可以显示三部分信息：

- HTTPS 网站的证书信息。

- 协商出的密码套件、TLS/SSL 协议版本等信息。

- 页面是否实施全站HTTPS 策略。

使用Chrome 浏览器打开一个HTTPS 页面，按F8 键打开Chrome 开发者工具，选择【Security 】菜单， 可以了解详细的信息， 具体如图5-1 所示。

## 301 重定向

### 新构建的HTTPS 网站

对于新构建的HTTPS 网站来说，可以关闭网站的80 端口，强制用户只能使用HTTPS的网站。但存在一个问题需要注意，很多用户在手动输入网站域名时，浏览器并不知道服务器是否支持HTTPS ， 默认使用HTTP 访问，由于服务器没有开启HTTP 服务，浏览器会提示错误，造成很不好的体验。为了缓解这个错误，可以开放HTTP 80 端口，通过301 规则强制用户访问HTTPS 的网站。为了支持301 重定向，修改Web 服务器的配置，以Nginx 服务器为例，修改／巳tc/nginx/sites-enabled/default 文件，增加下列指令即可：

```json
server {
	listen 80 ;
	server name www. example . com;
	rewrite https : //$server name;
}
```

一旦服务器接收到HTTP 请求，不管请求的URL 地址是什么， 一律将原有地址重定向到HTTPS 网站首页。

Web 性能优化中有一个重要的规则就是减少301 重定向，主要是带来了额外的请求。对于安全性， 301 重定向请求完成之前，到达服务器的HTTP 请求是没有加密保护的，攻击者可以获取HTTP 请求中的明文信息（ 比如Cookie 信息〉， 然后访问HTTPS 网站，由于访问的时候会携带截获的C ookie 值，最终攻击者可以获取用户的隐私数据。

### API 接口的重定向

API 接口主要是供手机APP 调用， A PP 可以通过升级的方式切换到HTTPS API ，如果用户强制不升级APP 的版本，调用的还是旧HTTPAPI 接口，此时也可以使用301 重定向策略。需要注意的一点是， HTTP GET 请求可以进行301 重定向，而HTTP POST 接口无法进行301 重定向。

# 证书

## PKI 组成

根据PKI X.509 标准， PKI 组成如图6-1 所示。

- 服务器实体（ end entity ），就是需要申请证书的实体，比如www.example.com 域名的拥有者可以申请一张证书，证书能够证明www .example.com 域名所有者的身份。
- CA 机构， CA 是证书签发机构，在审核服务器实体的有效身份后，给其签发证书，证书是用CA 机构的密钥对（比如RSA 密钥对）对服务器实体证书进行签名。
- RA 机构，注册机构， 主要审核服务器实体的身份， 一般情况下，可以认为CA机构包含了RA 机构。
- 证书仓库， CA 机构签发的证书全部保存在仓库中，证书也可能过期或者被吊销，CA 机构吊销的证书称为证书吊销列表CRL (Certificate Revocation List ） 。
- 证书校验方（ relying party ），校验证书真实性的软件，在Web 领域，读者最熟悉的证书校验方就是浏览器。在本书中，浏览器、客户端、证书校验方可以认为是同一个概念。为了进行校验，证书校验方必须充分信任第三方CA 机构，证书校验方集成了各个CA机构的根证书。

## 证书内容的核心部分

- version
- serialNumber：每个证书都有唯一的编号，对于不同的C A 机构来说，编号是无法预测的，CertificateSeria!Number 是一个整型类型
- signature：签名算法包含两个部分， 分别是摘要算法和签名算法。
- issuer：代表CA 机构的名称
- validity：在证书中包括了证书的有效期，证书校验方需要校验证书有效期，如果证书有效期失效，表明证书不能代表服务器实体身份。
- subject：代表服务器实体的名称
- subjectPublicKeylnfo：服务器实体申请证书的时候，包含的一个重要属性就是服务器公钥，该公钥对应的算法就是公开密钥算法。

# tls协议分析

## TLS 记录层协议

### 连接状态

客户端和服务器端会构建一条TCP 连接，每条连接都是一个会话，会话有不同的状态，状态贯穿了整个TLS/SSL 协议处理流程。

# 抓包

## tcpdump抓包

```shell
$ tcpdump -s 0  -i eth1  port 443 and host 10.235.173.30 -w https.pcap 
```

- -i eth 1 ：抓取特定网卡的流量， 一般情况下是外网访问的网卡地址。
- port 443 and host 10.235 . 173.30 ： 表示仅仅抓取443 端口的流量，同时仅仅捕获特定IP 的流量，这个host 一般是某个客户端的IP ，该表达式可以过滤很多不关心的流量。
- -w https.pcap ：可以将抓取的流量保存到文件中，然后供Wireshark 分析。

## 解密H TTP S 流量

HTTPS 的流量分为两部分：

- 握手协议消息， Wireshark 会明文显示所有的握手子消息。

- TLS 记录层的加密数据。

一般情况下，读者使用Wireshark 分析HTTPS ，更关注握手协议的含义，如果需要明
文查看应用层数据，可以使用下列方法：
。通过配置SSLKEYLOGFILE 环境变量指定一个外部文件， Chrome 和Firefox 会将
HTTPS 访问过程中的会话密钥保存到这个外部文件。
© Wireshark 会读取SSLKEYLOGFILE 环境变量指定的外部文件，其中包含会话密
钥，有了会话密钥， Wireshark 就能解密所有的加密流量。
接下来看看如何配置SSLKEYLOGFILE 环境变量和Wireshark，再次强调下，即使不
配置， 也不影响读者分析TLS/ SSL 协议。