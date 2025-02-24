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
# 		echo "start load logcat  device -->  $connect_device 
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

# 获取当前文件的路径
current_file_path="$(readlink -f "$0")"

# 使用dirname命令获取文件夹路径
folder_path=$(dirname "$file_path")


# 检查文件夹是否存在,并创建
if [ ! -d "$folder_path/capture-log-file" ]; then
    echo "capture-log-file文件夹不存在，将创建它"
    mkdir "$folder_path/capture-log-file"
fi

# 判断文件夹是否大于1G ,大于就删除里面全部内容

# 获取目录的大小（以字节为单位）
# capture_log_size=$(du -sb "$folder_path/capture-log-file" | cut -f1)
capture_log_size_kb=$(du -sk "$folder_path/capture-log-file" | cut -f1)
capture_log_size=$((capture_log_size_kb * 1024))

# 1G  = byte
one_gb=1073741824
# 判断目录大小是否大于1GB
if [ "$capture_log_size" -gt "$one_gb" ]; then
    echo "缓存文件大小超过 1 GB，将删除缓存文件的内容..."
    rm -rf "$folder_path/capture-log-file"/*
    echo "目录内容已删除。"
fi



# 检查文件夹是否存在 ,进行删除
if [  -d "$folder_path/capture-log-file/temp_log" ]; then
    echo "capture-log-file/temp_log 文件夹存在，将删除"
    rm -r "$folder_path/capture-log-file/temp_log"
fi

logcat_name=log_$(date +%Y%m%d_%H%M%S).log
file_path="$folder_path/capture-log-file/$logcat_name"

func(){
	echo "\nstart load logcat : device is --> $connect_device 
		\nwait $sleepTime second or stop ( control + c ) auto open log"	

	adb -s $connect_device shell logcat -v threadtime >> $file_path
}

trap "echo '检测到 SIGINT, 退出脚本'; exit 0" SIGINT

# 参数-n的作用是不换行，echo默认换行
echo  "输入抓取logcat的时间，默认500秒:"    
# 把键盘输入放入变量               
# read  -e sleepTime  
# echo  "输入抓取 $sleepTime"
sleepTime=500 

if [ "$sleepTime" == "e" ] || [ "$sleepTime" == "exit"  ]; then
	echo "已经退出当前脚本"
  	exit
fi

if [[ $sleepTime -eq 0 ]]; then
	sleepTime=500
fi


# 定义一个处理函数，用于处理 捕获 SIGINT (Ctrl+C) 信号
handle_sigint() {
    echo "捕获到 SIGINT 信号(command + c)"
    # 这里可以添加你希望执行的其他操作
	handle_log_file
}

# 使用 trap 命令捕获 SIGINT 信号，并指定处理函数
trap handle_sigint SIGINT

# 处理抓取的log文件
handle_log_file(){

	# 将正常停止设备上所有正在运行的logcat进程。
	adb -s $connect_device shell killall -2 logcat

	# 打开对应的app
	echo "抓取的文件路径: $file_path"
	open -a "Visual Studio Code" "$file_path"

	trap "echo '检测到 SIGINT, 退出脚本'; exit 0" SIGINT
	
	echo "\nAgain Enter 过滤规则 使用 | 分离,如 14532|flutter ; \n输入 e / exit 则退出当前脚本"
	while  read -e filter_name ; do
		#statements

		output_name=$filter_name
		
		if [ "$output_name" == "e" ] || [ "$output_name" == "exit"  ]; then
			echo "已经退出当前脚本"
			exit
		fi
		
		# 打开当前文件所在的文件夹
		if [[ "$output_name" == "open" ]] || [[ "$output_name" == "o" ]]; then
			# 检查文件夹是否存在 ,进行删除
			if [ ! -d "$folder_path/capture-log-file/temp_log" ]; then
				echo "capture-log-file/temp_log 文件夹不存在，将创建"
				mkdir "$folder_path/capture-log-file/temp_log"
			fi

			# 复制当前文件到 "log-file" 文件夹下
			cp "$file_path" "$folder_path/capture-log-file/temp_log/"

			open $(dirname "$folder_path/capture-log-file/temp_log/$logcat_name")
			echo "请输入内容"
			continue
		fi

		# 判断用户输入的字符串是否为空
		if [ -z "$output_name" ]; then
			echo "请输入内容"
			continue
		fi
		
		echo "output_name= $output_name"
		output_name2=`echo $output_name | sed 's/[^a-zA-Z0-9.]//g'`
		echo "output_name2= $output_name2"
		egrep -i "($filter_name)" $file_path > ${file_path%/*}/$output_name2
		# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
		# 打开对应的app
		open -a "Visual Studio Code" "${file_path%/*}/$output_name2"
		echo "Again Enter 过滤规则 使用 | 分离,如 14532|flutter ; 输入e / exit 则退出当前脚本"

	done
}

func & sleep $sleepTime

handle_log_file




