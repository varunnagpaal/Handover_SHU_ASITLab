统一回复：
1、why don't work setting EXPIRE 12-dec-2050 ?? EXPIRE Wrong
答：只支持到31-dec-2020，表问我为啥，我也不造

2、工具的SECRET DATA栏输出的字符用来干什么？还有，NOTICE那一栏可以不可以变？ ISSUER那一栏可不可以自由填写。楼主给个图文教程吧。
答：SECRET DATA只是给你看看的，你改了也没用，还是会自动计算；不建议修改NOTICE和ISSUER，改了有可能lic起不来，因为scl会检查这2个字段

3、支持带点的feature吗 ？
答：支持

4、laker 是後来才被 synopsys 收..那  可吗??
答：没用过laker，要不你试试？

5、能提供.src文件吗？
答：已经提供了src文件。程序目录里没有Synopsys.src文件的话，程序会自动释放，如果有就直接使用

6、我测试一下以前的efa，不能加入AUTH，你这个EFA改了哪里，能不能把avantd也加进去，谢谢
答：这个程序是我自己写的，不是修改的EFA。能支持AUTH是因为我使用的flexlm11.4的SDK，但是不支持avantd的daemon，因为我没破解那个

7、This package can not be setup correctly by this src and tool, Please check! Thanks!
答：你这个是DW的lic，安装的时候需要一个叫做Project ID的东西，对应的feature需要在VENDOR_STRING中有PID=（一堆数）的声明才可以。程序里提供的src就包含这个PID，但是PID明文要私信我

8、what version of SCL this tool supports?  i tried 11.9 and it fails
答：使用程序自带的src可以支持SCL11.9，如果修改了src就要注意feature冲突，因为SCL11.9要检查lic里是否有重复的feature（不区分大小写）如果有重复的，则lic失败。

9、IP的支持？这个出来了就很给力了！希望楼主解决啊!
答：参见7