#!/bin/bash


do_setup()
{
	netperf_tar="netperf-2.7.0.tar.gz"
	. $SHENGCAIROOT/testcases/common.sh
	setup
	rm -rf $results/msg.log
        cd $prog
	if [ ! -e netperf-2.7.0/src/netperf ]; then
        down $netperf_tar
        tar zxf $netperf_tar
        cd netperf-2.7.0
	if [ `arch` == 'mips64el' ]; then
		log "configure ..."
        	./configure --build=mips64 >>/dev/null
	else
		log "configure ..."  
		./configure >>/dev/null
	fi
	log "make ..."
        make >>/dev/null
	echo "make install ..."
        make install >>/dev/null
	fi
	
	$prog/netperf-2.7.0/src/netperf -t TCP_STREAM -H $1 -l 10 >/dev/null 2>&1
	if [ $? != 0 ]; then
		log "netserver is not worked!"
		scp $netperf_tar root@$1:/opt/
        	ssh root@$1 "cd /opt/ 
		if [ ! -e netperf-2.7.0/src/netperf ];then
		tar zxf netperf-2.7.0.tar.gz
		cd /opt/netperf-2.7.0 
		if [ `arch` == 'mips64el' ]; then
        		./configure --build=mips64 >>/dev/null
		else
			./configure >>/dev/null
			fi
        	make >>/dev/null
        	make install >/dev/null
		which systemctl >/dev/null
		if [ $? = 0 ];then
			systemctl stop firewalld 
		else
			service iptables stop
		fi
		 /opt/netperf-2.7.0/src/netserver
		fi"
	fi

}

#netperf下载安装

#netperf四种场景测试
do_test()
{

	rm -rf $results/netperf
	mkdir $results/netperf
	log "netperf test start ..." 
	for para in TCP_STREAM UDP_STREAM TCP_RR TCP_CRR
	do		
		log "$para test ..."
		for i in `seq 3`
		do 
		$prog/netperf-2.7.0/src/netperf -t $para -H $1 -l 60 >> $results/netperf/$para
		sleep 10
		done
	done
	cd $results
	log "netperf test end."
	mv msg.log netperf/
	tar zcf netperf.tar.gz netperf
	
}




clean_test()
{
	:
}

end_testcase()
{
	:
}

do_setup $@
do_test $@
clean_test
end_testcase
