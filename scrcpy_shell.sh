#!/bin/bash


# 获取 Display ID 信息
output="$(scrcpy --list-displays)"
# 获取有--display-id=的一行
display_ids=()
while IFS= read -r line; do
    if [[ $line =~ [[:space:]]*--display-id=([0-9]+) ]]; then
        # display_ids+=("${BASH_REMATCH[1]}")
        display_ids+=("$line")
    fi
done <<< "$output"


for i in "${!display_ids[@]}"; do
    echo "${display_ids[$i]}"
done

# 获取数组长度
display_count=${#display_ids[@]}

# 判断数组的长度
if [[ "$display_count" -eq 1 ]]; then
    echo "只有一个 Display ID，直接执行 scrcpy"
osascript <<EOF
tell application "Terminal"	
		do script "scrcpy   \n osascript -e 'tell application \"Terminal\" to close first window' &>/dev/null \n exit 0"	
end tell
EOF
    exit 1
fi

# 在数组中增加 "exit" 选项
display_ids+=("    exit")

# 获取终端的行数和列数
rows=$(tput lines)
cols=$(tput cols)

# 初始化变量
selected_index=0

# 函数：显示菜单
function display_menu() {
    clear
    for i in "${!display_ids[@]}"; do
        if [ "$i" -eq "$selected_index" ]; then
            echo  "\033[7m${display_ids[$i]}\033[0m"
        else
            echo "${display_ids[$i]}"
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
            ((selected_index < ${#display_ids[@]} - 1)) && ((selected_index++))
            ;;
        '')   # 回车键
			display_line=${display_ids[$selected_index]}

            if [[ "$display_line" == "exit" ]]; then
                echo "退出当前操作."
                break;
            fi
            
            if [[ "$display_line" =~ [[:space:]]*--display-id=([0-9]+) ]]; then
                final_display_id="${BASH_REMATCH[1]}"
                echo "选择的display id: $final_display_id" 
            fi
            break;
            ;;
    esac
}

# 主循环
while true; do
    display_menu
    handle_key
done

# # **检查选择的行是否为空**
if [[ -z "$final_display_id" ]]; then
    echo "退出当前操作."
    exit 1
fi

# 每一行只能这样操作,否则命令行不识别次操作.
# \n osascript -e 'tell application \"Terminal\" to close first window' &>/dev/null \n exit 0 表示执行完后 关闭窗口.
osascript <<EOF
tell application "Terminal"	
		do script "scrcpy --display-id $final_display_id  \n osascript -e 'tell application \"Terminal\" to close first window' &>/dev/null \n exit 0"	
end tell
EOF


