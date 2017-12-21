#!/bin/bash

#测试环境生成脚本

envdir="/opt/isoft.env"
mkdir -p $envdir

cp /proc/cpuinfo $envdir
cp /proc/meminfo $envdir
cp /root/install.log $envdir
cp /root/install.log.syslog $envdir
cp /proc/cgroups $envdir
cp /var/log/boot.log $envdir
cp /etc/securetty $envdir
cp /var/log/secure $envdir
chkconfig --list >$envdir/chk.isoft
cp /etc/sysctl.conf $envdir
gcc -v >$envdir/gcc-v  2>&1
