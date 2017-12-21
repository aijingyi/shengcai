#!/bin/bash


do_setup()
{
	netperf_tar="netperf-2.7.0.tar.gz"
	. $SHENGCAIROOT/testcases/common.sh
	setup
        cd $prog
	if [ ! -e netperf-2.7.0/src/netperf ]; then
        down $netperf_tar
        tar zxf $netperf_tar
        cd netperf-2.7.0
	if [ `arch` == 'mips64el' ]; then
		echo "configure ..."
        	./configure --build=mips64 >>/dev/null
	else
		echo "configure ..."  
		./configure >>/dev/null
	fi
	echo "make ..."
        make >>/dev/null
	echo "make install ..."
        make install >>/dev/null
	fi
	
	$prog/netperf-2.7.0/src/netperf -t TCP_STREAM -H $1 -l 10 >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "netserver is not worked!"
		scp $netperf_tar root@$1:/opt/
        	ssh root@$1 "cd /opt/ 
		if [ ! -e netperf-2.7.0/src/netperf ];then
		tar zxvf netperf-2.7.0.tar.gz
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

	rm -rf $results/netperf_s
	mkdir $results/netperf_s
	echo "netperf test start ..." | tee $results/netperf_s/netperf_s.log
	date | tee -a $results/netperf_s/netperf_s.log
	for i in `seq $2`
        do
		$prog/netperf-2.7.0/src/netperf -f M -H $1 -l $3 >> $results/netperf_s/netperf_result
        done

	cd $results
	tar zcf netperf_s.tar.gz netperf_s
	echo "netperf test end" | tee $results/netperf_s/netperf.log
	date | tee -a $results/netperf_s/netperf_s.log
	
}




clean_test()
{
	:
}

end_testcase()
{
	:
}

do_setup $1
do_test $@
clean_test
end_testcase
