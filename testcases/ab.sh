#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
	url="http://192.168.32.102"
        rm -rf $results/ab
        rm -rf $results/msg.log
        mkdir $results/ab
	curl $url >/dev/null 2>&1 || \
	{ 
	log "Server is not working!" 
	exit 1 
	}
}

do_test()
{
   	cd $results
        log "Apache Benchmark test is starting......"
	url_ab=$url/ab.html
	curl $url_ab | grep "hello world" 
	if [ $? == 0 ]; then
		for i in 20 50 100 200 300 500
			do
			ab -n 20000 -c $i ${url_ab} >>ab/ab_output
			done
	else
		log "html server is not working!"
		exit 1
	fi
	url_php=$url/ab.php
	curl $url_php | grep "hello world" 
	if [ $? == 0 ]; then
		for i in 20 50 100 200 300 500
			do
			ab -n 20000 -c $i ${url_php} >>ab/php_output
			done
	else
		log "php server is not working!"
		exit 1
	fi
        log "The test is successful!"
	mv msg.log ab/
	tar zcf ab.tar.gz ab
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
