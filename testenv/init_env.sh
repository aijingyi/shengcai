#!/bin/bash
#初始化系统环境
#调整系统时间、硬件时间
#ssh支持root登录


set_time()
{
	echo "同步系统时间"
	ntpdate ntp.api.bz
	echo "同步硬件时间"
	clock -w
}

set_sshroot()
{
	SSHD="/etc/ssh/sshd_config"
	echo "设置ssh支持root登录"
	grep "PermitRootLogin no" $SSHD && sed -i "s/PermitRootLogin no/PermitRootLogin yes/g" $SSHD
	grep "#PermitRootLogin yes" $SSHD && sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" $SSHD
	service sshd restart
}

set_time
set_sshroot
