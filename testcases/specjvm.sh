#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
        rm -rf $results/specjvm
        rm -rf $results/msg.log
        mkdir $results/specjvm
	cd $prog
	log "Download if not exists."
        if [ ! -e SPECjvm2008/SPECjvm2008.jar ] ; then
		down "SPECjvm2008-1.01.tgz"  >/dev/null 2>&1
        	tar zxf SPECjvm2008-1.01.tgz 
	fi
}

do_test()
{
        cd SPECjvm2008
	rm -rf results/*
        log "Spec JVM test is starting......"
        for i in 1 2 3
        do
        	java -Xms512M -Xmx2048M -jar SPECjvm2008.jar -peak -ikv
	done
        log "The test is successful!"
	cp -r results/* $results/specjvm/
	cd $results
	mv msg.log specjvm/
	tar zcf specjvm.tar.gz specjvm
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
