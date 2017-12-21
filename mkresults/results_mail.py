#!/usr/bin/python
#coding:utf-8


#Automatically email test results
#created by kai.liang@i-soft.com.cn
#date: 20170802



from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.MIMEBase import MIMEBase
import smtplib
from email import Encoders
import time
import sys



#mail_to = "kai.liang@i-soft.com.cn"
results_dir = sys.argv[1]
mail_to = sys.argv[2]
test_name = sys.argv[3]

def automail_result():
	test_tar = test_name + ".tar.gz"
	result_tardir = "%s%s" % (results_dir, test_tar)
	testresultfilename = test_tar

	msg = MIMEMultipart()
	text='''
	Hi:
	  %s!
	  Your test of %s is output, please check it in attach!
   

	  your best wishes!
	  shengcai
	'''  % (mail_to, test_name)

	part1 = MIMEText(text,'plain')
	msg.attach(part1)
	part=MIMEBase('application','octet-stream')
	part.set_payload(open('%s'%result_tardir, 'rb').read())
	Encoders.encode_base64(part)
	part.add_header('Content-Disposition', 'attachment; filename=%s'%testresultfilename)
	msg.attach(part)

	mailto_list=[mail_to]
	msg['from'] = 'admin@aijingyi.com'
	msg['subject'] = 'Performance test data of %s' % test_name

	try:
		server = smtplib.SMTP()
		server.connect('smtp.mxhichina.com')
		server.login('admin@aijingyi.com','DaBeiZhou3344')
		server.sendmail(msg['from'], mailto_list, msg.as_string())
		server.quit
		print 'Send mail succeed!'
	except Exception, errormessage:  
		print str(errormessage) 

automail_result()
