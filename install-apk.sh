#!/bin/bash
#install

#  新版本增加选择功能
echo

# 使用dirname命令获取文件夹路径
folder_path=$(dirname $0)
# echo "当前文件路径：$folder_path"

temp_file="/temp"
# 原始文件的路径
apk_list_file="$temp_file/_apk_list_content"
# copy原始文件到本地的路径
apk_list_copy_file="$temp_file/_apk_list_copy_content"
# 检查文件夹是否存在,并创建
if [ ! -d "$folder_path/temp" ]; then
    # echo "文件夹不存在，将创建它"
    mkdir "$folder_path/temp"
fi

# 检查文件夹是否存在,并创建
if [ ! -d "$folder_path$apk_list_file" ]; then
    # echo "文件夹不存在，将创建它"
    echo "" >> "$folder_path$apk_list_file"
fi

if [ ! -d "$folder_path$apk_list_copy_file" ]; then
    # echo "文件夹不存在，将创建它"
    echo "" >> "$folder_path$apk_list_copy_file"
fi


# string_origin=`cat "$folder_path$apk_list_file"`

# echo "原始数据: $string_origin \n"


# 使用 while read 逐行读取文件 ; 读取原始文件
while IFS= read -r line; do
        # 判断是否为空行
    if [ -n "$line" ]; then
        # echo "非空行: $line"
        input_list_origin+=("$line")
    fi
    
done < "$folder_path$apk_list_file"


# 使用 while read 逐行读取文件; 读取copy文件
while IFS= read -r line; do
        # 判断是否为空行
    if [ -n "$line" ]; then
        # echo "非空行: $line"
        input_list_origin_copy+=("$line")
    fi
    
done < "$folder_path$apk_list_copy_file"


# 新的集合
input_list=()
input_list_copy=()

# 倒序输出到新集合
for ((i=${#input_list_origin[@]}-1; i>=0; i--)); do
    input_list+=("${input_list_origin[i]}")
done

for ((i=${#input_list_origin_copy[@]}-1; i>=0; i--)); do
    input_list_copy+=("${input_list_origin_copy[i]}")
done

# 打印集合中的内容
# for item in "${input_list[@]}"; do
#     echo "集合数据: $item"
# done

# for item in "${input_list_copy[@]}"; do
#     echo "集合数据copy: $item"
# done


# 参数-n的作用是不换行，echo默认换行
echo  "拖入文件 或 回车选择之前的文件路径:"    
# 把键盘输入放入变量               
read  -e input_file_path    


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
            final_file_path_copy=${input_list_copy[$selected_index]}
            echo "选择的文件名: $final_file_path"
            echo "选择的文件名copy: $final_file_path_copy"
            break;
            ;;
    esac
}



if [[ -n "$input_file_path" ]];then
    # 不为空,则选择用户输入的路径
    final_file_path=$input_file_path
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
if [ ! -f "$final_file_path_copy" ]; then
    echo "copy文件不存在: $final_file_path_copy"
    # 检查文件是否存在
    if [ ! -f "$final_file_path" ]; then
        echo "文件不存在: $final_file_path"
        exit 1
    else
        install_apk=$final_file_path
        echo "使用原始的路径:$final_file_path"
    fi

else
    install_apk=$final_file_path_copy
    echo "使用本地copy的路径:$final_file_path_copy"
fi


adb -s $connect_device install -r -t -d "$install_apk"

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
    # 获取文件名
    file_name=$(basename "$final_file_path")
    # 构建目标路径
    target_path="$folder_path$temp_file/$file_name"
    # echo "copy目标路径:$target_path"
    # 复制当前文件到 "log-file" 文件夹下
    cp "$final_file_path" "$target_path"
    input_list_origin_copy+=("$target_path")
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

# copy的集合
if [ "${#input_list_origin_copy[@]}" -gt "$max_elements" ]; then
    start_index=$((${#input_list_origin_copy[@]} - $max_elements))
    save_to_list_copy=("${input_list_origin_copy[@]:$start_index}")

    delete_apk_list=("${input_list_origin_copy[@]:0:$start_index}")

    # 打印集合中的内容,并进行删除
    for item in "${delete_apk_list[@]}"; do
        echo "删除集合数据: $item"
        rm -r $item
    done

else
    save_to_list_copy=("${input_list_origin_copy[@]}")
fi



# 写入文件
for ((i=0; i<${#save_to_list[@]}; i++)); do
    # echo "开始存入文件 -- ${save_to_list[i]}"
    if [ $i -eq 0 ]; then
        echo "${save_to_list[i]}" > "$folder_path$apk_list_file"
    else
        echo "${save_to_list[i]}" >> "$folder_path$apk_list_file"
    fi
done

# 写入文件-copy
for ((i=0; i<${#save_to_list_copy[@]}; i++)); do
    # echo "开始存入文件 -- ${save_to_list[i]}"
    if [ $i -eq 0 ]; then
        echo "${save_to_list_copy[i]}" > "$folder_path$apk_list_copy_file"
    else
        echo "${save_to_list_copy[i]}" >> "$folder_path$apk_list_copy_file"
    fi
done

echo









