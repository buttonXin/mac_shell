#!/bin/bash

# adb shell logcat -v threadtime >> ~/capture-log-file/log_$(date +%Y%m%d_%H%M%S).log

# devices_result="$(adb  devices)"

# echo "---$devices_result"
# # 通过空格分割字符串
# array=(${devices_result// /})

# length=${#array[*]}



# func(){
# 	# 长度大于2表示已经连接有设备，获取第一个设备就行
# 	if [ $length -gt 2 ]
# 	then
# 		connect_device=${array[1]}
# 		echo "start load $connect_device logcat 
# 		\nwait 8 second or Longer ( command/ctrl + z ) auto open log \nwait\n"	
# 		adb -s $connect_device shell logcat -v threadtime >> $log_name
# 	else
# 		echo "no devices connected"
# 	fi
# }

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


file_path=~/capture-log-file/log_$(date +%Y%m%d_%H%M%S).log

func(){
	echo "start load $connect_device logcat 
		\nwait $sleepTime second or Longer ( command/ctrl + z ) auto open log \nwait\n"	

	adb -s $connect_device shell logcat -v threadtime >> $file_path
}

# 参数-n的作用是不换行，echo默认换行
echo  "输入抓取logcat的时间多少秒，不输入回车，默认15秒:"    
# 把键盘输入放入变量               
read  sleepTime  
echo  "输入抓取 $sleepTime" 
if [[ $sleepTime -eq 0 ]]; then
	sleepTime=15
fi
 
func & sleep $sleepTime

# 将正常停止设备上所有正在运行的logcat进程。
adb -s $connect_device shell killall -2 logcat

# 打开对应的app
open -a "sublime text" "$file_path"

echo "\nAgain Enter 过滤规则 使用 | 分离,如 14532|flutter ; 输入e / exit 则退出当前脚本"
while  read filter_name ; do
	#statements

    output_name=$filter_name
	
	if [ "$output_name" == "e" ] || [ "$output_name" == "exit"  ]; then
		echo "已经退出当前脚本"
   		exit
	fi
	
	echo "output_name= $output_name"
	output_name2=`echo $output_name | sed 's/[^a-zA-Z0-9.]//g'`
	echo "output_name2= $output_name2"
	egrep -i "($filter_name)" $file_path > ${file_path%/*}/$output_name2
	# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
	# 打开对应的app
	open -a "sublime text" "${file_path%/*}/$output_name2"
	echo "Again Enter 过滤规则 使用 | 分离,如 14532|flutter ; 输入e / exit 则退出当前脚本"
done





