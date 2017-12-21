#!/bin/bash

#ltp内核功能测试

#controllers test_controllers.sh
do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup

	yum -y install expect mkisofs numactl-devel libaio \
	libaio-devel libcap-devel libattr-devel keyutils-libs-devel
        if [ $? != 0 ]
        then
                echo "rpm packages install failed!!"
                exit 1
        fi
        cd $prog
        down ltp-full-20160920.tar.bz2
        tar jxf ltp-full-20160920.tar.bz2
        cd ltp-full-20160920
        if [ $arch==mips64el ]
        then
                ./configure --build=mips64el >/dev/null
        else
                ./configure >/dev/null
        fi
        make >/dev/null
        make install >/dev/null
}

do_test()
{
	rm -rf $results/ltpkernel
	mkdir $results/ltpkernel
	LTPKERNEL=$results/ltpkernel
	today=`date +%Y%m%d`
	export PATH=/opt/ltp/testcases/bin:$PATH
        export PASSWD=abc123
        export LANG=C
        export LHOST_IFACES=eth0
        /etc/init.d/ksmtuned  stop
	cd /opt/ltp/
	echo "controllers test_controllers.sh" > skipfile
	date >$LTPKERNEL/result_${today}.date
	./runltp -p -S skipfile -l $LTPKERNEL/result_${today}.log -o $LTPKERNEL/result_${today}.out -C $LTPKERNEL/result_${today}.fail -T $LTPKERNEL/result_${today}.tconf -d /tmp
	date >$LTPKERNEL/result_${today}.date
	cd $results
	tar zcf ltpkernel.tar.gz ltpkernel
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
do_test
clean_test
end_testcase
