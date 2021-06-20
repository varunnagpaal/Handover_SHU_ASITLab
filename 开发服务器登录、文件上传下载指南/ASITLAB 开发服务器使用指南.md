
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [1. 服务器资源](#1-服务器资源)
- [2. 如何登录服务器](#2-如何登录服务器)
  - [2.1 接入校内网](#21-接入校内网)
  - [2.2 接入安全服务器](#22-接入安全服务器)
  - [2.3 接入ServerA~D](#23-接入servera~d)
- [3. 修改密码](#3-修改密码)
  - [3.1 修改安全服务器的密码](#31-修改安全服务器的密码)
  - [3.2 修改ServerA~D的密码](#32-修改servera~d的密码)
- [4. 文件的上传、下载](#4-文件的上传-下载)
  - [4.1 文件的上传](#41-文件的上传)
  - [4.2 文件的下载](#42-文件的下载)
- [5. 一些其他信息](#5-一些其他信息)

<!-- /code_chunk_output -->


# 1. 服务器资源

实验室目前有 4 台开发服务器 ServerA ~ D，另有一台安全服务器，使用 A ~ D 服务器时必须通过安全服务器登录。

![image.png](https://i.loli.net/2020/09/11/hw59BIJTVd3i6lN.png)

**配置：**

ServerA/B: 2 核 6 线程、32G 内存、500G 存储空间

ServerC/D: 2 核 20 线程、64G 内存、4T 存储空间



# 2. 如何登录服务器 

需要用到客户端程序 ZS-ISP Client：

https://10.0.64.59/download


注意：只能在学校网络中使用服务器，外网须通过 VPN 连入校内网再使用。

需要用到 **2 组** 账号-密码，注意区分。

## 2.1 接入校内网

这一步是针对校外的情况，已在校园网环境的可跳过。

在外网使用 EasyConnect 通过 VPN 接入校内网，基本流程参考学校教程：http://vpn.shu.edu.cn/index/SSLVPN/Windows_Linux_MacOS1.htm


## 2.2 接入安全服务器

下载、安装、运行 ZS-ISP Client，如下填写登录信息。

**ZS-ISP Host：**`10.0.64.59`

**Domain Name：**`local`

**User Name：**`qhlin`（名的拼音首字母 + 姓的拼音，无分割符）

**Password：**`老师告诉你们的安全服务器密码`（建议修改初始密码，修改方式后附）

![image.png](https://i.loli.net/2020/09/11/smnFxibJUpL9Akd.png)

点击 `Desktop` 进入安全服务器的桌面。

此处的账号-密码是 **安全服务器的账号-密码**，注意与后述 **ServerA~D 的账号-密码** 区分。

注：**安全服务器的账号-密码** 由老师管理，出现账号问题需要经由老师操作。

## 2.3 接入ServerA~D

点击安全服务器桌面任务栏第2个图标打开 Linux 终端，使用 SSH 接入 ServerA~D。

```shell
# 4台服务器的地址，任选一台登录，建议使用C/D：
# ServerA：192.168.1.10
# ServerB：192.168.1.11
# ServerC：192.168.1.12
# ServerD：192.168.1.13
#
# ssh命令格式：
# ssh 用户名@服务器地址

ssh qhlin@192.168.1.13
```

输入初始密码 `123456`（Linux 下输入密码不会出现提示符 "*"；另外第一次连接时可能会询问"是否接受主机的密钥"，填写 "yes" 即可）。

此处的账号-密码是 **ServerA~D 的账号-密码**，注意与前述 **安全服务器的账号-密码** 区分。请修改初始密码，修改方式后附。

![image.png](https://i.loli.net/2020/09/11/eAdYanXxcv1I7UO.png)

终端的用户由 `qhlin@localhost` 变为 `qhlin@ServerD` 表示登录成功。



# 3. 修改密码

使用服务器用到了两组账号-密码：**安全服务器的账号-密码** 和 **ServerA~D的账号-密码**。

## 3.1 修改安全服务器的密码

运行 ZS-ISP Client，在 Option → Password 选项卡可设置新密码。

![Snipaste_2020-09-11_20-39-42.jpg](https://i.loli.net/2020/09/11/pJFXwyQuaAPE6qW.jpg)

## 3.2 修改ServerA~D的密码

ServerA/B/C/D 可设置 4 个不同的密码，初始密码均为 `123456`。

根据第二部分的操作接入要修改密码的服务器，运行指令：

```
passwd
# 输入原密码、输入新密码、确认新密码
```

接入另外3台服务器，重复上述操作，更改所有4台服务器的密码。



# 4. 文件的上传、下载

文件出、入服务器都需要通过管理员（导师）审批。

## 4.1 文件的上传

运行 ZS-ISP Client，点击 `SFTP` 登录到文件传输系统。

![image.png](https://i.loli.net/2020/09/11/Cg4OxGi1bLKm38u.png)

根目录下能看到`export`和`import`两个文件夹，把想要导入到服务器内的文件拖放到`import/process_*`文件夹内。

这一操作将提交一条申请给管理员，通知导师进行审批。

等待审批通过后，运行 ZS-ISP Client，使用 `Desktop` 登录到安全服务器桌面。运行任务栏第 3 个程序 FileZilla。

![image.png](https://i.loli.net/2020/09/11/3lTUNXpYMjQoyrS.png)

填入Host、Username、Password接入想要放入文件的服务器。

```
# Host格式：
# sftp://服务器ip
# 例如sftp://192.168.1.13
# 账号密码同ServerA~D账号-密码
```

左半侧窗口为安全服务器的文件目录，定位到 `/IO/import` 路径下；右半侧窗口为接入的服务器的文件目录。

审批通过后，`/IO/import` 文件夹内有上传的文件，下载到 ServerA~D 本地即可在服务器上使用。

## 4.2 文件的下载

和上传过程相反。

同样运行 FillZilla，登录待导出文件所在的服务器。

左侧窗口（安全服务器文件目录）定位到 `/IO/export/process_*`，将待导出文件拖拽到左侧窗口即可。

这一操作同样会提交一条申请，通知导师审批。

审批通过后，再次运行ZS-ISP Client，登录 `SFTP`。在根目录下能看到 `export` 文件夹，将待导出文件下载到本地即可。



# 5. 一些其他信息

ServerB 上有一通过 NFS 共享的 `/export` 目录，四台服务器都可访问，目录下有设计软件等。鉴于 ServerB 存储空间紧张，不建议再在 ServerB 上存放过多数据。

个人工作环境主要通过配置 `~/.bashrc` 完成，`/export/Wares/README` 目录下有说明文档和一份 `.bashrc` 样例供参考。