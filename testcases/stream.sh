#!/bin/bash


do_setup()
{
	. $SHENGCAIROOT/testcases/common.sh
	setup
        rm -rf $results/stream
        rm -rf $results/msg.log
        mkdir $results/stream
	log "Download if not exists."
        down "stream-5.9.tar.gz"  >/dev/null 2>&1
        tar zxf stream-5.9.tar.gz
        cd stream-5.9
	log "make ..."
        make >/dev/null
}

do_test()
{
        log "Test is starting......"
        for threads in 8 16 32
        do
                #sync
                #echo 3>/proc/sys/vm/drop_caches
                export OMP_NUM_THREADS=$threads
                for i in `seq 6`
                do
                        ./stream_5.9_gcc >> $results/stream/stream_output_$threads
                        sleep 1;
                done
        done
        log "The test is successful!"
	cd $results
	mv msg.log stream/
	tar zcf stream.tar.gz stream
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
