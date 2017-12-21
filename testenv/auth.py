#!/usr/bin/env python
#coding:utf-8

####################
#公司访问外网认证脚本
#update by kai.liang@i-soft.com.cn
###################

import urllib, urllib2, getpass

#name = raw_input('请输入用户名：')
name = '梁凯' # 在本行输入您的名字
url = 'http://172.16.1.3/webAuth/index.htm'

def auth():
	page = 0
	parameters = {'password':passwd,'pwd':passwd,'secret':'true','username':name} 
	#提交的数据参数
	data = urllib.urlencode(parameters)  #对参数进行编码
	req = urllib2.Request(url, data) #形成url请求
	try:
		response = urllib2.urlopen(req) #发送请求
		response = urllib2.urlopen(req) #发送请求
		response = urllib2.urlopen(req) #发送请求
		page = response.read() #读取返回的页面
	except Exception, e:
		print '登录失败，请重新登录!' #修复HTTPError错误
	if page:
		if "认证成功" in page or "该IP已登录" in page:
			print '恭喜您，登录成功，您现在可以访问外网了！'
		else:
			print '账号或密码错误，请重新登录！'

if __name__ == '__main__':
	print "####################################"
	print "#公司访问外网认证脚本              #"
	print "#初次使用请将脚本12行替换为您的名字#"
	print "####################################"
	print '用户名：%s' %name
	passwd = getpass.getpass('请输入密码：')
	auth()
