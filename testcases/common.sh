#!/bin/bash


#配置安装软件、收集结果的目录，设置环境变量

setup()
{
	which gcc >/dev/null 2>&1 || yum -y install gcc >/dev/null 2>&1
	url_base="http://192.168.32.102/testtools/"	
	url_out="https://github.com/aijingyi/testtools/blob/master/"
	prog="$SHENGCAIROOT/prog"
	[ -d "$prog" ] || mkdir $prog

	HOST=`hostname`
	results="$SHENGCAIROOT/results"
	[ -d "$results" ] || mkdir $results
	

	basepath=$(cd `dirname $0`; pwd)
	
}


#性能测试工具下载，先检测本地是否有软件包，没有的话就去
#指定地址下载
down()
{
	cd $prog
	
	if [ ! -e $1 ]; then
	
		curl http://192.168.32.102/testtools/ >/dev/null 2>&1
		if [ $? == 0 ]; then
			wget ${url_base}$1 >/dev/null 2>&1
		else
			case $1 in
			UnixBench5.1.3.tgz)
			wget http://github.itzmx.com/1265578519/unixbench/master/5.1.3/UnixBench5.1.3.tgz -O UnixBench5.1.3.tgz;;

			

			esac
		fi
	fi
}


log()
{
	echo ` date +"%Y-%m-%d %H:%M:%S"`  $1 | tee -a $results/msg.log
}


welcome()
{
	echo "--------------------------"
	echo "欢迎使用生菜自动化测试工具"
	echo "--------------------------"

}
	

welcome
