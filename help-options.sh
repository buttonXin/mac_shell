#!/bin/bash


func_device(){
	devices_result="$(adb  devices)"

	echo "---$devices_result"
	# 通过空格分割字符串
	array=(${devices_result// /})

	length=${#array[*]}
	# 长度大于2表示已经连接有设备，获取第一个设备就行
	if [ $length -gt 2 ]
	then
		connect_device=${array[1]}
		echo "\n当前连接的设备是  < $connect_device >\n"	
		
	else
		echo "no devices connected"
	fi
}
func_device


func_help_desc(){
	echo """
	输入数字即可\n
	0 :再次查看说明;
	1 :查看所有 display 的id;
	2 :adb启动应用的说明,启动到指定的display;
	3 :执行 readLog.sh 脚本, 读取Log文件并进行过滤;
	4 :执行 connect.sh 脚本, 读取ifconfig连接设备
	5 :执行 laogao_logcat.sh 脚本, 读取连接设备里的logcat并生成文件
	6 :执行 apk-parse.sh 脚本, 打开解析apk的应用
	"""
}

func_help_desc

# echo  "输入数字:"    
# # 把键盘输入放入变量               
# read  curNum


while  read -p "查看说明输入0,请输入数字:" curNum ; do
	echo
	if [ "$curNum" == "0" ]; then
   		func_help_desc
   		continue
	fi

	if [ "$curNum" == "1" ]; then
   		echo  " 所有display -->\n$(adb -s "$connect_device" shell dumpsys display | grep "Display Id")" 
   		echo
   		continue
	fi

	if [ "$curNum" == "2" ]; then
   		echo  " adb shell am start -n ai.nreal.nebula.mainland/ai.nreal.nebula.MainActivity --display 157 可以指定到对应的display里" 
   		# echo  " adb shell input keyevent 4 -d 157   在display id是 157 的屏幕执行返回键"
   		echo  
   		continue
	fi

	if [ "$curNum" == "3" ]; then
   		sh ./readLog.sh
   		echo
   		continue
	fi

	if [ "$curNum" == "4" ]; then
   		sh ./connect.sh
   		echo
   		continue
	fi

	if [ "$curNum" == "5" ]; then
   		sh ./laogao_logcat.sh
   		echo
   		continue
	fi

	if [ "$curNum" == "6" ]; then
   		sh ./apk-parse.sh
   		echo
   		continue
	fi


done







