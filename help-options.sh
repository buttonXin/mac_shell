#!/bin/bash


has_device=false
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
		current_brand_info=$(adb -s "$connect_device" shell getprop |egrep "(ro.product.name|ro.product.model|ro.product.brand|ro.boot.hardware]|market|ro.soc.model)")
		echo "\n设备信息:\n${current_brand_info}"
		echo "\n当前连接的 device: $connect_device \n"	
		
		has_device=true
	else
		connect_device=""
		echo "请先连接设备"
		has_device=false
	fi
}
func_device


func_help_desc(){
	echo """
	请输入\n
	0 	:再次查看说明;
	a 	:执行 apk-parse.sh 脚本, 打开解析apk的应用
	am 	:adb启动应用的说明,启动到指定的display;
	c 	:执行 connect.sh 脚本, 读取ifconfig连接设备
	-c 	:执行 adb logcat -c 
	d 	:查看所有 display 的id; scrcpy --list-display ; scrcpy --display 476 显示对应的屏幕id
	-d	:执行 disconnect
	i 	:执行 install-apk.sh 脚本, 安装apk
	input xxx	:执行 adb shell input text/keyevent  ....
	l 	:执行 laogao_logcat.sh 脚本,读取设备里的logcat并生成文件
	n 	:打开一个新的 Terminal 窗口
	o or open 	: 打开当前文件所在的文件夹
	r 	:执行 readLog.sh 脚本, 读取Log文件并进行过滤;
	s 	:执行 scrcpy 脚本
	"""
}

func_help_desc

# echo  "输入数字:"    
# # 把键盘输入放入变量               
# read  curNum

# 获取当前文件的路径
current_file_path=$(dirname $0)

while  read -e -p "查看说明输入0,请输入:" curNum ; do
	func_device
	if [ "$curNum" == "0" ]; then
   		func_help_desc
   		continue
	fi

	if [ "$curNum" == "n" ]; then
   		echo 'tell application "Terminal" to do script "this is new Terminal"' > open_terminal.scpt
		osascript open_terminal.scpt
		rm open_terminal.scpt
   		continue
	fi

	if [[ "$curNum" == *open* ]] || [[ "$curNum" == "o" ]]; then
   		open "$(dirname "$0")"
   		echo
   		continue
	fi

	if [ "$curNum" == "r" ]; then
   		sh $current_file_path/readLog.sh
   		echo
   		continue
	fi


	# 下面的脚本需要连接设备才能执行
	if [ ! $has_device ]; then
   		continue
	fi

	if [ "$curNum" == "a" ]; then
   		sh $current_file_path/apk-parse.sh
   		echo
   		continue
	fi

	if [ "$curNum" == "am" ]; then
   		echo  " adb shell am start -n ai.nreal.nebula.mainland/ai.nreal.nebula.MainActivity --display 157 可以指定到对应的display里" 
   		# echo  " adb shell input keyevent 4 -d 157   在display id是 157 的屏幕执行返回键"
   		echo  
   		continue
	fi

	if [ "$curNum" == "c" ]; then
   		sh $current_file_path/connect.sh
   		echo
   		continue
	fi

	if [ "$curNum" == "-c" ]; then

		if [ "$connect_device" == "" ]; then
   			continue
		fi

   		adb -s "$connect_device" logcat -c
   		echo
   		continue
	fi

	if [ "$curNum" == "d" ]; then
   		echo  " 所有display -->\n$(adb -s "$connect_device" shell dumpsys display | grep "  Display ")" 
   		echo  "scrcpy info: $(scrcpy --list-display)"
   		echo
   		continue
	fi

	if [ "$curNum" == "-d" ]; then
   		echo  " disconnect -->\n$(adb disconnect)" 
   		echo
   		continue
	fi	

	if [ "$curNum" == "i" ]; then
   		sh $current_file_path/install-apk.sh
   		echo
   		continue
	fi

	if [[ "$curNum" == *input* ]]; then
   		adb -s "$connect_device" shell  "$curNum"
   		echo
   		continue
	fi	

	if [ "$curNum" == "l" ]; then
   		sh $current_file_path/laogao_logcat.sh
   		echo
   		continue
	fi	

	if [ "$curNum" == "s" ]; then
   		echo 'tell application "Terminal" to do script "scrcpy"' > open_terminal.scpt
		osascript open_terminal.scpt
		rm open_terminal.scpt
   		echo
   		continue
	fi




done







