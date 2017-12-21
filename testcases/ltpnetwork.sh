#!/bin/bash
#############################
#ltp network test scripts
#powered by kai.liang
#date:2017.06.21
############################

lip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" |grep -v "122.1"
`

do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
	conf()
	{
	yum -y install xinetd rusers rusers-server telnet telnet-server \
	rsh rsh-server finger finger-server >/dev/null
        yum -y install expect rwho libtirpc-devel rdist ftp dhcp vsftpd >/dev/null
	if [ $? != 0 ]; then
		echo "rpm install failed!"
		exit 1
	fi
	grep rsh /etc/securetty >/dev/null || echo "rsh" >>/etc/securetty
        grep rlogin /etc/securetty >/dev/null || echo "rlogin" >>/etc/securetty
	rshpam=`grep pam_securetty.so /etc/pam.d/rsh`
	grep "#$rshpam" /etc/pam.d/rsh >/dev/null || sed -i "s/$rshpam/#$rshpam/g" /etc/pam.d/rsh
	rloginpam=`grep pam_securetty.so /etc/pam.d/rlogin`
	grep "#$rloginpam" /etc/pam.d/rlogin >/dev/null || sed -i "s/$rloginpam/#$rloginpam/g" /etc/pam.d/rlogin
        sed -i "s/yes/no/g" /etc/xinetd.d/rsh
        sed -i "s/yes/no/g" /etc/xinetd.d/rlogin

        sed -i 's/userlist_enable=YES/userlist_enable=NO/g' /etc/vsftpd/vsftpd.conf
        grep "#root" /etc/vsftpd/ftpusers >/dev/null || sed -i 's/root/#root/g' /etc/vsftpd/ftpusers
        grep "#auth \[user" /etc/pam.d/login >/dev/null || sed -i 's/auth \[user/#auth \[user/g' /etc/pam.d/login
        sed -i 's/yes/no/g' /etc/xinetd.d/telnet
        for i in `seq 0 10`
        do
                grep "pts/$i" /etc/securetty >/dev/null || echo pts/$i>>/etc/securetty
        done
	grep "root" /root/.rhosts >/dev/null || echo "$lip root" >/root/.rhosts
	grep "`hostname`" /etc/hosts >/dev/null || echo "$lip `hostname`" >>/etc/hosts
	#sed -i "s/#RPCNFSDARGS/RPCNFSDARGS/g" /etc/sysconfig/nfs
	}
	server6()
	{
	service iptables stop
	chkconfig xinetd on
        chkconfig finger on
        chkconfig echo-stream on
        chkconfig echo-dgram on
        chkconfig rstatd on
        chkconfig rusersd on

        service rwhod restart
        service nfs restart
        service vsftpd restart
        service xinetd restart
	}
	server7()
	{
	systemctl enable xinetd
	systemctl enable finger
	systemctl enable echo-stream 
	systemctl enable echo-dgram
	systemctl enable rstatd
	systemctl enable rusersd
	
	systemctl stop firewalld
	systemctl restart rwhod
	systemctl restart nfs
	systemctl restart vsftpd
	systemctl restart xinetd
	}
	ltpinstall()
	{
	cd $prog
        down ltp-20150903.tar.gz
        tar zxf ltp-20150903.tar.gz
        cd ltp-20150903
	make autotools >/dev/null
        if [ $arch==mips64el ]
        then
                ./configure --build=mips64el --prefix=/opt/ltp2015 >/dev/null  2>&1
        else
                ./configure --prefix=/opt/ltp2015 >/dev/null 2>&1
        fi
        make >/dev/null 2>&1
        make install >/dev/null 2>&1
	}
	conf
	which systemctl >/dev/null 2>&1
        if [ $? = 0 ];then
		server7
        else
		server6
	fi

	server
	[ -e /opt/ltp2015/bin/ltp-pan ] || ltpinstall
}

do_test()
{
	
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

	echo $PATH | grep ltp2015 >/dev/null || export PATH=/opt/ltp2015/testcases/bin/:$PATH
	grep ltp2015 /etc/bashrc || echo "PATH=$PATH:/opt/ltp2015/testcases/bin" >>/etc/bashrc
	source /etc/bashrc
	
	cd /opt/ltp2015/testscripts/
	normal()
	{
		rm -rf $results/ltpnetwork
		mkdir $results/ltpnetwork
		rm -rf /tmp/netpan.log /tmp/netpan.out

		grep "netpan.out" networktests.sh|| sed -i "108s%-S%-o /tmp/netpan.out -S%g" networktests.sh
		./networktests.sh 
		cp /tmp/netpan.log /tmp/netpan.out $results/ltpnetwork/
		cd $results
		tar zcf ltpnetwork.tar.gz ltpnetwork
	}
	debug()
	{
		grep "netpan.out" networktests.sh && sed -i "108s%-o /tmp/netpan.out%%g" networktests.sh
		./networktests.sh -S

	}
	normal
	#debug
}

clean_test()
{
	export PATH=$(echo $PATH | sed s#/opt/ltp2015/testcases/bin/:##)
	grep ltp2015 /etc/bashrc && sed -i '$d' /etc/bashrc
	source /etc/bashrc
	#sed -i '/rsh/d' /etc/securetty
        #sed -i '/rlogin/d' /etc/securetty
        #sed -i "s/#auth       required     pam_securetty.so/auth       required     pam_securetty.so/g" /etc/pam.d/rsh
        #sed -i "s/#auth       required     pam_securetty.so/auth       required     pam_securetty.so/g" /etc/pam.d/rlogin
        #sed -i 's/userlist_enable=NO/userlist_enable=YES/g' /etc/vsftpd/vsftpd.conf
        #sed -i 's/#root/root/g' /etc/vsftpd/ftpusers
        #sed -i 's/#auth \[user/auth \[user/g' /etc/pam.d/login
        #sed -i 's/no/yes/g' /etc/xinetd.d/telnet
}

end_testcase()
{
	:
}

do_setup
do_test
clean_test
end_testcase
