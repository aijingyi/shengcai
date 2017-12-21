#!/usr/bin/python
#coding:utf-8
result_new="result_20170608.tconf"
result_old="result_20170428.tconf"

f1 = open(result_new)

for i in f1:
	f2 = open(result_old)
	if i not in f2:
		print i
	f2.close()
f1.close()

