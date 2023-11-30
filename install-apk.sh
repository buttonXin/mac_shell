#!/bin/bash
#install

#  新版本增加选择功能
echo

# 使用dirname命令获取文件夹路径
folder_path=$(dirname $0)
# echo "当前文件路径：$folder_path"

# 检查文件夹是否存在,并创建
if [ ! -d "$folder_path/temp" ]; then
    # echo "文件夹不存在，将创建它"
    mkdir "$folder_path/temp"
fi


# 检查文件夹是否存在,并创建
if [ ! -d "$folder_path/temp/_save_apk_list" ]; then
    # echo "文件夹不存在，将创建它"
    echo "" >> "$folder_path/temp/_save_apk_list"
fi


# string_origin=`cat "$folder_path/temp/_save_apk_list"`

# echo "原始数据: $string_origin \n"


# 使用 while read 逐行读取文件
while IFS= read -r line; do
        # 判断是否为空行
    if [ -n "$line" ]; then
        # echo "非空行: $line"
        input_list_origin+=("$line")
    fi
    
done < "$folder_path/temp/_save_apk_list"


# input_list_origin=(${string_origin/\n\n/})

# 新的集合
input_list=()

# 倒序输出到新集合
for ((i=${#input_list_origin[@]}-1; i>=0; i--)); do
    input_list+=("${input_list_origin[i]}")
done

# 打印集合中的内容
# for item in "${input_list[@]}"; do
#     echo "集合数据: $item"
# done



# 参数-n的作用是不换行，echo默认换行
echo  "拖入文件 或 回车选择之前的文件路径:"    
# 把键盘输入放入变量               
read  -e file_path    


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
		echo "connect_device  $connect_device \n"	
		
	else
		echo "no devices connected"
	fi
}
func_device


# 获取终端的行数和列数
rows=$(tput lines)
cols=$(tput cols)

# 初始化数组
# input_list=("nebula.apk" "nebula2.apk" "nebula3.apk")


# 初始化变量
selected_index=0

# 函数：显示菜单
function display_menu() {
    clear
    for i in "${!input_list[@]}"; do
        if [ "$i" -eq "$selected_index" ]; then
            echo  "\033[7m${input_list[$i]}\033[0m"
        else
            echo "${input_list[$i]}"
        fi
    done
}

# 函数：处理按键
function handle_key() {
    read -rsn1 key
    case "$key" in
        'A')  # 上箭头
            ((selected_index > 0)) && ((selected_index--))
            ;;
        'B')  # 下箭头
            ((selected_index < ${#input_list[@]} - 1)) && ((selected_index++))
            ;;
        '')   # 回车键
			final_file_path=${input_list[$selected_index]}
            echo "选择的文件名: $final_file_path"
            break;
            ;;
    esac
}



if [[ -n "$file_path" ]];then
    final_file_path=$file_path
else
    if [ "${#input_list[@]}" -eq 0 ]; then
    	echo "没有历史记录."
    	exit
    
	else
	    # 主循环
		while true; do
		    display_menu
		    handle_key
		done
	fi	

fi




if [[ "$final_file_path" == *.apk* ]]; then
	echo  
else
	echo "请使用 .apk 的安装包"
	exit 	
fi

# 检查文件是否存在
if [ ! -f "$final_file_path" ]; then
    echo "文件不存在: $final_file_path"
    exit 1
fi


adb -s $connect_device install -r -t -d "$final_file_path"

# echo "$final_file_path" > _install-apk_pre_info
# 打印集合中的内容


# 判断集合中是否包含 final_file_path
has_finla_apk=false
for item in "${input_list_origin[@]}"; do
    if [ "$item" == "$final_file_path" ]; then
        has_finla_apk=true
        break
    fi
done

# 如果不存在相同的数据，则添加
if ! $has_finla_apk; then
    input_list_origin+=("$final_file_path")
fi


# 设置存入文件的最大元素数量
max_elements=10

# 如果集合大小大于5，则保留最后的5个元素
if [ "${#input_list_origin[@]}" -gt "$max_elements" ]; then
    start_index=$((${#input_list_origin[@]} - $max_elements))
    save_to_list=("${input_list_origin[@]:$start_index}")
else
    save_to_list=("${input_list_origin[@]}")
fi


# 写入文件
for ((i=0; i<${#save_to_list[@]}; i++)); do
	# echo "开始存入文件 -- ${save_to_list[i]}"
    if [ $i -eq 0 ]; then
        echo "${save_to_list[i]}" > "$folder_path/temp/_save_apk_list"
    else
        echo "${save_to_list[i]}" >> "$folder_path/temp/_save_apk_list"
    fi
done

echo



# 最简单的
# echo

# pre_file_path=`cat _install-apk_pre_info`
# echo "上一个文件路径：$pre_file_path"

# # 参数-n的作用是不换行，echo默认换行
# echo -n "拖入文件或者回车使用上一个文件路径:"    
# # 把键盘输入放入变量               
# read  -e file_path    


# func_device(){
# 	devices_result="$(adb  devices)"

# 	echo "---$devices_result"
# 	# 通过空格分割字符串
# 	array=(${devices_result// /})

# 	length=${#array[*]}
# 	# 长度大于2表示已经连接有设备，获取第一个设备就行
# 	if [ $length -gt 2 ]
# 	then
# 		connect_device=${array[1]}
# 		echo "connect_device  $connect_device \n"	
		
# 	else
# 		echo "no devices connected"
# 	fi
# }
# func_device


# if [[ -n "$file_path" ]]
# then
#     final_file_path=$file_path
# else
#     final_file_path=$pre_file_path
# fi

# if [[ "$final_file_path" == *.apk* ]]; then
# 	echo  
# else
# 	echo "请使用 .apk 的安装包"
# 	exit 	
# fi



# adb -s $connect_device install -r -t -d "$final_file_path"

# echo "$final_file_path" > _install-apk_pre_info

# echo









