#!/usr/bin/python
#encoding:utf-8
#powered by kai.liang@i-soft.com.cn

import xlrd
import xlwt

data_file1="iozone_res_1.xls"
data_file2="iozone_res_2.xls"
data_file3="iozone_res_3.xls"   #原始数据

results_file="iozone_res.xls"    #输出文件名

def read_excel(data_file):
	#读取数据文件到列表
	data_list = []
	data = xlrd.open_workbook(data_file,encoding_override='utf-8')
	table = data.sheet_by_name(u'Sheet 1')
	B6 = table.cell(5,1).value
	B9 = table.cell(8,1).value
	B12 = table.cell(11,1).value
	B15 = table.cell(14,1).value
	B18 = table.cell(17,1).value
	B21 = table.cell(20,1).value
	data_list = [B6,B9,B12,B15,B18,B21]
	return data_list

def set_style(name, height):  
	style = xlwt.XFStyle()   #初始化样式   
	font = xlwt.Font()       #为样式创建字体  
	font.name = name  
	font.color_index = 4  
	font.height = height  
	
	style.font = font  
	return style

def write_excel(results_file,row1,row2,row3):  
	#创建文件
	workbook = xlwt.Workbook(encoding='utf-8')    
	#创建sheet  
	data_sheet = workbook.add_sheet('orig_data')    
	row0 = [u'Writer', u'Re-writer', 'Reader', 'Re-reader', 'RandomRead', 'RandomWrite']  
	
	#生成数据
	for i in range(len(row0)):  
		data_sheet.write(0, i, row0[i], set_style('Times New Roman', 220))  
		data_sheet.write(1, i, row1[i], set_style('Times New Roman', 220))  
		data_sheet.write(2, i, row2[i], set_style('Times New Roman', 220))  
		data_sheet.write(3, i, row3[i], set_style('Times New Roman', 220))  
	
	#保存文件  
	workbook.save(results_file)     


if __name__ == "__main__":
	data_list1 = read_excel(data_file1)
	data_list2 = read_excel(data_file2)
	data_list3 = read_excel(data_file3)
	write_excel(results_file,data_list1,data_list2,data_list3)
	print "生成iozone结果数据成功！"
