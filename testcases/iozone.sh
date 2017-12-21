#!/bin/bash

#iozone下载、安装、测试

do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
	iozone_tar="iozone3_465.tar"
	rm -rf $results/msg.log
}

#iozone下载、安装、测试
do_test()
{
        cd $prog
	log "Downlaod if not exists."
	down "$iozone_tar"
	if [ ! -f "iozone3_465/src/current/iozone" ]; then 
        	tar xf $iozone_tar
        	cd iozone3_465/src/current
		log "make..."
		make linux >/dev/null
	fi

	if [ ! -e /iotest ]; then
		mkdir /iotest
	fi
	rm -rf $results/iozone
        mkdir $results/iozone
	log "start iozone test....." 
	for i in `seq $1`
	do 	
	log "The ${i}st test" 
	$prog/iozone3_465/src/current/iozone -Rb $results/iozone/iozone_res_$i.xls -i 0 -i 1 -i 2 -I -f /iotest/iozone_io.file -r ${2} -s ${3}g >>$results/iozone/raw_iozone
	sleep 100
	done
	date | tee -a $results/iozone/iozone.log
	log "iozone end." 
	cd $results
	mv msg.log iozone/
	tar zcf iozone.tar.gz iozone
}


clean_test()
{
	pass
}

end_testcase()
{
	pass
}

do_setup
do_test $@
