#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
	cd $prog
	if [ ! -e /opt/isoft-ltp/bin/ltp-pan ];then
		down isoft-ltp2016.tar.gz
		tar zxf isoft-ltp2016.tar.gz
		cd isoft-ltp2016
		sh setup
	fi
}

do_test()
{
	rm -rf $results/isoftltp
	mkdir $results/isoftltp
	cd /opt/isoft-ltp2016
	echo "starting test..." | tee -a results/isoft.log
	date | tee -a results/isoft.log
	./runltp -o isoft_ltp.out -l isoft_ltp.log -C failcmdfile -d /tmp -S skipfile -g isoft_ltp.html
	date | tee -a results/isoft.log
	echo "test end." | tee -a results/isoft.log
	cp  results/* $results/isoftltp
	cp  output/* $results/isoftltp
	cd $results
	tar zcf isoftltp.tar.gz isoftltp


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
