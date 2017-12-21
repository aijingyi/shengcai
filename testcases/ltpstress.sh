#!/bin/bash

 lip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" |grep -v "122.1"
`


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
	log "install softwares required..."
	yum -y install xinetd rsh rsh-server numactl numactl-devel  >/dev/null 2>&1
	if [ $? != 0 ]; then
                echo "rpm install failed!"
                exit 1
        fi
	
	grep rsh /etc/securetty >/dev/null || echo "rsh" >>/etc/securetty
        grep rlogin /etc/securetty >/dev/null || echo "rlogin" >>/etc/securetty
        grep rexec /etc/securetty >/dev/null || echo "rexec" >>/etc/securetty

	grep "root" /root/.rhosts >/dev/null || echo "localhost root" >/root/.rhosts
	grep "`hostname`" /etc/hosts >/dev/null || echo "$lip `hostname`" >>/etc/hosts

	which systemctl
	if [ $? = 0 ]; then
	{
	setenforce 0
	systemctl enable rsh.socket
	systemctl restart rsh.socket
	systemctl enable rlogin.socket
	systemctl restart rlogin.socket
	systemctl enable rexec.socket
	systemctl restart rexec.socket
	systemctl stop firewalld
	systemctl restart nfs 
	}
	else
	{
	sed -i "s/yes/no/g" /etc/xinetd.d/rsh
        sed -i "s/yes/no/g" /etc/xinetd.d/rlogin
	service xinetd restart
	chkconfig xinetd on
	service iptables stop
	#chkconfig iptables off
	service nfs start
	#chkconfig nfs on
	}
	fi
	ltpinstall()
	{
		cd $prog
        	down ltp-full-20160920.tar.bz2
        	tar jxf ltp-full-20160920.tar.bz2
        	cd ltp-full-20160920
        	if [ $arch==mips64el ]
		then
			log "configure..."
                	./configure --build=mips64el  >/dev/null 2>&1
		else
			log "configure..."
                	./configure  >/dev/null 2>&1
        	fi
		log "make..."
       	 	make  >/dev/null 2>&1
		log "make install ..."
        	make install  >/dev/null 2>&1
	}	
	[ -e /opt/ltp/bin/ltp-pan ] || ltpinstall
	ln /usr/sbin/exportfs /bin/
	ln /usr/sbin/rpc.nfsd /bin/
}

do_test()
{

	export LTP_TIMEOUT_MUL=10 

	lip1=`echo $lip | awk -F . '{ print $1 }'`
        lip2=`echo $lip | awk -F . '{ print $2 }'`
        lip3=`echo $lip | awk -F . '{ print $3 }'`
        lip4=`echo $lip | awk -F . '{ print $4 }'`
        export RHOST=${RHOST:-"$lip"}
        rip4=`echo $RHOST | awk -F . '{ print $4 }'`

        export PASSWD=${PASSWD:-"abc123"}

        # Set first three octets of the network address, default is '10.0.0'
        export IPV4_NETWORK=${IPV4_NETWORK:-"$lip1.$lip2.$lip3"}
        # Set local host last octet, default is '2'
        export LHOST_IPV4_HOST=${LHOST_IPV4_HOST:-"$lip4"}
        # Set remote host last octet, default is '1'
        export RHOST_IPV4_HOST=${RHOST_IPV4_HOST:-"$rip4"}
        # Set the reverse of IPV4_NETWORK
        export IPV4_NET_REV=${IPV4_NET_REV:-"$lip3.$lip2.$lip1"}


	cd /opt/ltp
	normal()
	{
	
		rm -rf /tmp/sar.out /tmp/stress.log /tmp/stress.out  /tmp/ltpstress* 
		rm -rf $results/ltpstress
		mkdir $results/ltpstress
		log "testing ..."
		./testscripts/ltpstress.sh -d /tmp/sar.out -l /tmp/stress.log -p -q -b /dev/$1 -B ext4 -t $2 -S >/tmp/stress.out
		cd $results
		log "test completed!"
		cp /tmp/sar.out /tmp/stress.log /tmp/stress.out  /tmp/ltpstress* ltpstress/
		tar zcf ltpstress.tar.gz ltpstress

	}
	debug()
	{
		./runltp -f kevin
	}
	normal $@
	#debug
}

clean_test()
{
	:
}

end_testcase()
{
	:
}

do_setup
do_test $@
clean_test
end_testcase
