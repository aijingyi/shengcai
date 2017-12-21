#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
}

#lmbench执行完make results后再执行两次的make rerun脚本
do_test()
{
	
        rm -rf $results/msg.log
        rm -rf $results/lmbench
        mkdir $results/lmbench
        cd $prog
        rm -rf lmbench-3.0-a9
	log "Download if not exists."
        down "lmbench-3.0-a9.tgz"
        tar xf lmbench-3.0-a9.tgz
        cd lmbench-3.0-a9
	log "fix scripts."
        ARCH=`arch`
        if [ $ARCH == 'mips64el' ]; then
                sed -i "19a\OS=mips64el" scripts/os
                sed -i "18s/10/25/g" src/memsize.c

        fi
        sed -i "201s/read TMP/TMP=$1/g" scripts/config-run
        sed -i "661s/tty/null/g" scripts/config-run
        sed -i "683s/no/yes/g" scripts/config-run
        sed -i "686s/yes/no/g" scripts/config-run
        #第一次测试
	log "Test start..."
	log "1st test..."
        yes ""|make results  >/dev/null 2>&1
        sleep 100
        #第二次测试
	log "2nd test..."
        make rerun >/dev/null 2>&1
        sleep 100
        #第三次测试
	log "3rd test..."
        make rerun >/dev/null 2>&1
        #出结果
        make see >/dev/null 
	log "test end."
        cp -ru results/* $results/lmbench
	cd $results
	mv msg.log lmbench/
	tar zcf lmbench.tar.gz lmbench
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
