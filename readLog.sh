# !/bin/bash                                 # 指定shell类型
# 第三版
# 参数-n的作用是不换行，echo默认换行

# 获取当前文件的路径
current_file_path=$(dirname $0)

echo "将文件拖入命令行后回车:"    
# 把键盘输入放入变量               
read -e file_path    


# 检查文件是否存在
if [ ! -f "$file_path" ]; then
    echo "文件${file_path} 不存在, 退出此次脚本"
	exit
fi

file_format=$(file -I $file_path)

# 获取传入文件的当前文件名称
file_name=$(basename "$file_path")
# 使用dirname命令获取传入文件的文件夹路径
folder_path=$(dirname "$file_path")

# 如果是utf-16le 的文件, 则转成 utf-8
if [[ "$file_format" == *utf-16* ]]; then
   	echo "需要转换文件: $file_format"
   	iconv  -f UTF-16LE -t UTF-8 ${file_path} > "${folder_path}/conv-utf-8-${file_name}"
   	file_path="${folder_path}/conv-utf-8-${file_name}"
fi


only_path=true 

egrep -i "(LogControl)" $file_path > ${file_path%/*}/LogControl
# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
# 打开对应的app
open -a "Visual Studio Code" "${file_path%/*}/LogControl"
open -a "Visual Studio Code" "$file_path"

# 使用dirname命令获取文件夹路径
folder_path=$(dirname "$file_path")

# 检查文件夹是否存在 ,进行删除
if [  -d "$folder_path/temp_log" ]; then
    # echo "temp_log 文件夹存在，将删除"
    rm -r "$folder_path/temp_log"
fi

string_tips="输入内容,规则 使用 | 分离,如 14532|flutter ; e 退出; r 重新拖入文件."

echo  "$string_tips"
while  read -e filter_name ; do
	
	only_path=false
    output_name=$filter_name

	if [ "$output_name" == "e" ] || [ "$output_name" == "exit"  ]; then
		echo "已经退出当前脚本"
   		exit
	fi

	if [ "$output_name" == "r" ]; then
   		sh $current_file_path/readLog.sh
   		echo
   		exit
	fi

	if ($only_path); then
   		open -a "Visual Studio Code" "$file_path"
	fi

	# 打开当前文件所在的文件夹
	if [[ "$output_name" == "open" ]] || [[ "$output_name" == "o" ]]; then
		# 检查文件夹是否存在 ,进行删除
		if [ ! -d "$folder_path/temp_log" ]; then
    		echo "temp_log 文件夹不存在，将创建"
    		mkdir "$folder_path/temp_log"
		fi

		# 复制当前文件到 "log-file" 文件夹下
		cp "$file_path" "$folder_path/temp_log/"

   		open $(dirname "$folder_path/temp_log/$output_name")

   		# open $(dirname "$file_path")
   		echo "$string_tips"
   		continue
	fi

    # 判断用户输入的字符串是否为空
	if [ -z "$output_name" ]; then
	    echo  "不能输入空的内容.\n"

	    continue
	else
	    echo "output_name= $output_name"
	fi

	
	output_name2=`echo $output_name | sed 's/[^a-zA-Z0-9]//g'`
	echo "output_name2= $output_name2"
	egrep -i "($filter_name)" $file_path > ${file_path%/*}/$output_name2
	# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
	# 打开对应的app
	open -a "Visual Studio Code" "${file_path%/*}/$output_name2"
	echo  "$string_tips"
	
done

#第三版
#echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#while  read filter_name && read output_name; do
#	#statements
#	if [[ ! -n "$output_name" ]]; then
#    	echo "output_name is empty"
#    	output_name=go
#	fi
#
#	echo "output_name= $output_name"
#	egrep -i "($filter_name)" $file_path > ${file_path%/*}/$output_name
#	# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
#	# 打开对应的app
#	open -a "sublime text" ${file_path%/*}/$output_name
#	echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#done
                            
# 第二版
# 参数-n的作用是不换行，echo默认换行
#echo -n "拖入文件:"    
# 把键盘输入放入变量               
#read  file_path    

#echo -n "Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#read  filter_name

#egrep -i "($filter_name)" $file_path > ${file_path%/*}/go

# 抽离字符串（将/ 前的str全部保留） {file_path%/*}

# 打开对应的app
#open -a "sublime text" ${file_path%/*}/go

# 再次使用过滤规则
#echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#read  filter_name

#egrep -i "($filter_name)" $file_path > ${file_path%/*}/go

# 抽离字符串（将/ 前的str全部保留） {file_path%/*}

# 打开对应的app
#open -a "sublime text" ${file_path%/*}/go

# echo ${file_path%/*}/go
# 返回一个零退出状态，退出shell程序
# exit 0  



## !/bin/bash                                 # 指定shell类型
# 第一版
## 参数-n的作用是不换行，echo默认换行
#echo -n "拖入文件:"    
## 把键盘输入放入变量               
#read  file_path    
#
#echo -n "Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#read  filter_name
#
#egrep -i "($filter_name)" $file_path > ${file_path%/*}/go
#
## 抽离字符串（将/ 前的str全部保留） {file_path%/*}
#
## 打开对应的app
#open -a "sublime text" ${file_path%/*}/go
#
## echo ${file_path%/*}/go
## 返回一个零退出状态，退出shell程序
#exit 0  






