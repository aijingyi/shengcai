#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
	rm -rf $results/msg.log
	rpm -q mysql-devel >/dev/null || yum -y install mysql-devel >/dev/null
	sysbench_tar="sysbench-0.4.12.tar.gz"

	if [ $1 == "mysql" ]; then
		rpm -q mysql-server || yum -y install mysql-server
		service mysqld restart
		mysqladmin -uroot password abc123 

		cd $prog
		if [ ! -e sysbench/drivers/mysql/Makefile ];then
			log "down sysbench tarball."
        		down $sysbench_tar >/dev/null
        		tar zxf $sysbench_tar
       			cd sysbench-0.4.12
		./autogen.sh
        	if [ `arch` == 'mips64el' ]; then
                	log "configure ..."
                	./configure  --build=mips64 --with-mysql-includes=/usr/include/mysql --with-mysql-libs=/usr/lib64/mysql >>/dev/null
        	else
		log "configure ..."  
                	./configure  --with-mysql-includes=/usr/include/mysql --with-mysql-libs=/usr/lib64/mysql >>/dev/null
        	fi
        	log "make ..."
        	make LIBTOOL=/usr/bin/libtool >>/dev/null
        	log "make install ..."
        	make LIBTOOL=/usr/bin/libtool install >>/dev/null
        	fi
            
	else
		cd $prog
        	if [ ! -e sysbench-0.4.12/sysbench/sysbench ]; then
			log "down sysbench tarball."
        		down $sysbench_tar >/dev/null
        		tar zxf $sysbench_tar
       			cd sysbench-0.4.12
			./autogen.sh
        		if [ `arch` == 'mips64el' ]; then
                		log "configure ..."
                		./configure --build=mips64 --without-mysql >>/dev/null
        		else
				log "configure ..."  
                		./configure --without-mysql >>/dev/null
        		fi
        		log "make ..."
        		make LIBTOOL=/usr/bin/libtool >>/dev/null
        		log "make install ..."
        		make LIBTOOL=/usr/bin/libtool install >>/dev/null
        	fi
	fi
	
}

do_test()
{
	rm -rf $results/sysbench$1
        mkdir $results/sysbench$1
	cd $prog/sysbench-0.4.12

	log "Test starting ..."
	if [ $1 == "mysql" ]; then

	for i in 1 2 3
	do
		log "${i}st testing ..."
		for num in 4 8
		do 
		echo "create database sbtest;" | mysql -uroot -pabc123
		log "prepare..."
		./sysbench/sysbench --test=oltp --mysql-user=root --mysql-host=localhost --mysql-socket=/var/lib/mysql/mysql.sock --mysql-password=abc123 --mysql-table-engine=innodb --oltp-table-size=10000 prepare		
		log "test..."
		./sysbench/sysbench  --mysql-db=sbtest  --test=oltp --mysql-engine-trx=yes \
--mysql-table-engine=innodb --oltp-table-size=10000 --db-ps-mode=disable  \
--mysql-user=root --mysql-host=localhost --mysql-socket=/var/lib/mysql/mysql.sock\
  --mysql-password=abc123 --num-threads=$num  run >> $results/sysbenchmysql/raw_output_${num}_$i
		log "cleanup data."
		./sysbench/sysbench --test=oltp --mysql-user=root --mysql-host=localhost --mysql-socket=/var/lib/mysql/mysql.sock --mysql-password=abc123 --mysql-table-engine=innodb --oltp-table-size=10000 cleanup
		echo "drop database sbtest;" | mysql -uroot -pabc123
		done
	done
	fi

	if [ $1 == "mem" ]; then
	for i in 1 2 3
	do
		log "${i}st testing ..."
		for num in 4 8
		do 
		./sysbench/sysbench --test=memory --num-threads=$num --memory-block-size=8192 --memory-total-size=4G run >> $results/sysbenchmem/raw_output_${num}_$i
		done
	done
	fi
	
	if [ $1 == "cpu" ]; then
	for i in 1 2 3
	do
		log "${i}st testing ..."
		for prime in 10000 20000 30000
		do 
		./sysbench/sysbench --test=cpu --cpu-max-prime=$prime run >> $results/sysbenchcpu/raw_output_${prime}_$i
		done
	done
	fi
	
	log "Test end."
	cd $results
	mv msg.log sysbench$1/
	tar zcf sysbench$1.tar.gz sysbench$1
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
