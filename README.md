生菜自动化测试工具v20171101
=============================
仅以此工具献给我们逝去的青春

功能：下载、安装、运行测试、收集测试结果、发送邮件到指定邮箱
创建者：梁凯 kevinlaung@sina.com
时间：2017-11-01
版本：20171101
新增常用软件包
修复ltpstress测试
新增初始化环境工具

时间：2017-09.07
版本：20170907
新建版本信息
英文名称：shengcai

安装：
本工具主要基于shell和python编写，无需安装，加压后即可使用。

用法：
./runtest + 参数
例如stream测试：./runtest stream
详情请使用./runtest -h获取帮助信息

可以编辑runtest文件，修改测试参数

目前实现的测试功能有：
iozone
unixbench
lmbench
stream
sysbench memory
sysbench cpu
sysbench mysql
pingpong
spec jvm
Apache Benchmark
LTP内核功能测试
LTP网络功能测试
LTP压力性能测试
isoft-ltp功能测试
netperf性能测试
netperf稳定性测试
hwc硬件信息收集

目录文件简介：
runtest文件，执行测试的主文件。
testcase目录，存放通用测试和各个测试工具的脚本。
testenv目录，存放收集系统硬件信息和软件信息的脚本。
prog目录，存放测试工具源程序。
results目录，存放测试结果。
mkresults目录，存放处理结果的脚本。
list文件，批量执行测试的文件。
README，说明文件。

关于测试工具包：
测试工具本身自带部分测试工具，
对于没有的：
本工具的默认下载地址为内网地址：
http://192.168.32.102/testtools
外网用户请去网盘：http://pan.baidu.com/s/1hr9LYWO
testtools下载所需测试工具，放入工具prog目录下

或者去：http://www.aijingyi.com/blog/155
查看博客文章，获取下载地址
