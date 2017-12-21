#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
	yum -y install perl-Time-HiRes >/dev/null
	unixbench_tar="UnixBench5.1.3.tgz"
	cd $prog
	down $unixbench_tar
	rm -rf UnixBench
	tar zxf $unixbench_tar
	cpucount=`cat /proc/cpuinfo |grep processor |wc -l`
}

do_test()
{
	rm -rf $results/unixbench
	rm -rf $results/msg.log
	mkdir $results/unixbench
        log "start unixbench test....." 
        for i in `seq $1`
        do
        log "$i test..."
        cd $prog/UnixBench/
	sed -i '1332s/next/#next/g' Run
        ./Run -c 1 -c $cpucount
        sleep 60
        done
        log "Test end."
	cp -r results/* $results/unixbench/
	cd $results
	mv msg.log unixbench/
	tar zcf unixbench.tar.gz unixbench

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
