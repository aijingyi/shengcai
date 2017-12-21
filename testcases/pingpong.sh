#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
        rm -rf $results/pingpong
        rm -rf $results/msg.log
        mkdir $results/pingpong
	cd $prog
	log "Download if not exists."
        if [ ! -e pingpong/RunTest.sh ] ; then
		down "pingpong.tar.gz"  >/dev/null 2>&1
        	tar zxf pingpong.tar.gz
	fi
}

do_test()
{
        cd pingpong
	rm -rf results
        log "Pingpong test is starting......"
	./RunTest.sh 
        log "The test is successful!"
	cp -r results/pingpong_results*/* $results/pingpong/
	cd $results
	mv msg.log pingpong/
	tar zcf pingpong.tar.gz pingpong
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
